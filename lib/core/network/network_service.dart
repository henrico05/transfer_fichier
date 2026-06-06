import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../domain/entities/transfer_file.dart';
import '../constants/app_constants.dart';

class NetworkService {
  static const int discoveryPort = 5000;
  static const int transferPort = 5001;
  static const int chunkSize = 64 * 1024; // 64KB chunks

  WebSocketChannel? _channel;
  ServerSocket? _serverSocket;
  List<Socket> _clients = [];
  RawDatagramSocket? _udpSocket;

  // Découverte des appareils sur le réseau
  Future<List<Map<String, dynamic>>> discoverDevices() async {
    List<Map<String, dynamic>> devices = [];

    try {
      final networkInfo = await _getNetworkInfo();
      final localIp = networkInfo['ip']!;
      final subnet = networkInfo['subnet']!;

      // Création du socket UDP pour l'écoute des réponses
      _udpSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        discoveryPort,
      );
      _udpSocket!.broadcastEnabled = true;

      // Écoute des réponses
      _udpSocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final Datagram? datagram = _udpSocket!.receive();
          if (datagram != null) {
            try {
              final message = utf8.decode(datagram.data);
              final data = jsonDecode(message);

              if (data['type'] == 'RESPONSE') {
                final device = {
                  'id': data['device']['id'],
                  'name': data['device']['name'],
                  'ipAddress': datagram.address.address,
                  'port': data['device']['port'] ?? transferPort,
                  'lastSeen': DateTime.now().toIso8601String(),
                };

                // Éviter les doublons
                if (!devices.any((d) => d['id'] == device['id'])) {
                  devices.add(device);
                }
              }
            } catch (e) {
              print('Erreur parsing message UDP: $e');
            }
          }
        }
      });

      // Envoi du message de découverte en broadcast
      final discoverMessage = jsonEncode({
        'type': 'DISCOVER',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'device': {
          'id': await _getDeviceId(),
          'name': Platform.localHostname,
          'ip': localIp,
          'port': transferPort,
        },
      });

      final encodedMessage = utf8.encode(discoverMessage);

      // Envoyer en broadcast sur tous les appareils du réseau
      for (int i = 1; i <= 254; i++) {
        final targetIp = '$subnet.$i';
        if (targetIp != localIp) {
          try {
            final targetAddress = InternetAddress(targetIp);
            _udpSocket!.send(encodedMessage, targetAddress, discoveryPort);
          } catch (e) {
            // Ignorer les erreurs pour les IPs inaccessibles
          }
        }
      }

      // Attendre 3 secondes pour recevoir toutes les réponses
      await Future.delayed(const Duration(seconds: 3));

      // Fermer le socket UDP
      _udpSocket?.close();
    } catch (e) {
      print('Erreur découverte UDP: $e');
      _udpSocket?.close();
    }

    return devices;
  }

  // Envoi de fichier avec chunks
  Future<void> sendFile(
    String targetIp,
    TransferFile file,
    Function(int sent, int total) onProgress,
    Function(double speed) onSpeedChange,
  ) async {
    Socket? socket;

    try {
      socket = await Socket.connect(
        targetIp,
        transferPort,
        timeout: Duration(seconds: AppConstants.connectionTimeout),
      );

      final fileObj = File(file.path);
      final fileSize = await fileObj.length();
      int sentBytes = 0;
      DateTime startTime = DateTime.now();
      DateTime lastProgressTime = DateTime.now();
      int lastProgressBytes = 0;

      // Envoi des métadonnées
      final metadata = jsonEncode({
        'type': 'FILE_METADATA',
        'id': file.id,
        'name': file.name,
        'size': fileSize,
        'fileType': file.type,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      socket.write('$metadata\n');
      await socket.flush();

      // Envoi du fichier par chunks
      final inputStream = fileObj.openRead();

      await for (var chunk in inputStream) {
        socket.add(chunk);
        sentBytes += chunk.length;
        onProgress(sentBytes, fileSize);

        // Calcul de la vitesse toutes les 500ms
        final now = DateTime.now();
        if (now.difference(lastProgressTime).inMilliseconds >= 500) {
          final elapsedSeconds = now.difference(startTime).inSeconds;
          if (elapsedSeconds > 0) {
            final speed = sentBytes / elapsedSeconds / 1024; // KB/s
            onSpeedChange(speed);
          }

          // Calcul de la vitesse instantanée
          final instantSpeed =
              (sentBytes - lastProgressBytes) /
              now.difference(lastProgressTime).inSeconds /
              1024;
          if (instantSpeed > 0) {
            onSpeedChange(instantSpeed);
          }

          lastProgressTime = now;
          lastProgressBytes = sentBytes;
        }

        // Permettre à l'UI de respirer
        await Future.delayed(Duration.zero);
      }

      await socket.flush();
      socket.close();
    } catch (e) {
      print('Erreur envoi: $e');
      socket?.close();
      rethrow;
    }
  }

  // Réception de fichier
  Future<void> startFileReceiver(
    String savePath,
    Function(Map<String, dynamic> metadata) onMetadataReceived,
    Function(int received, int total, double speed) onProgress,
    Function(String filePath) onComplete,
    Function(String error) onError,
  ) async {
    await _serverSocket?.close();

    try {
      _serverSocket = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        transferPort,
      );
      print('Serveur démarré sur le port $transferPort');

      _serverSocket?.listen((Socket client) async {
        final clientAddress = client.remoteAddress.address;
        print('Client connecté: $clientAddress');

        final metadataBuffer = BytesBuilder();
        bool metadataReceived = false;
        Map<String, dynamic>? metadata;
        File? outputFile;
        int receivedBytes = 0;
        int totalSize = 0;
        DateTime startTime = DateTime.now();
        DateTime lastProgressTime = DateTime.now();
        int lastProgressBytes = 0;

        client.listen(
          (Uint8List data) async {
            try {
              if (!metadataReceived) {
                metadataBuffer.add(data);
                final allBytes = metadataBuffer.toBytes();
                final newlineIndex = allBytes.indexOf(10); // '\n'

                if (newlineIndex != -1) {
                  final metadataLineBytes = allBytes.sublist(0, newlineIndex);
                  final remainingBytes = allBytes.sublist(newlineIndex + 1);

                  try {
                    final metadataLine = utf8.decode(metadataLineBytes);
                    metadata = jsonDecode(metadataLine);
                    metadataReceived = true;
                    totalSize = metadata!['size'];

                    print(
                      "Métadonnées reçues: ${metadata!['name']} (${metadata!['size']} bytes)",
                    );

                    final filePath = '$savePath/${metadata!['name']}';
                    outputFile = File(filePath);
                    await outputFile!.create(recursive: true);
                    onMetadataReceived(metadata!);

                    if (remainingBytes.isNotEmpty) {
                      await outputFile!.writeAsBytes(
                        remainingBytes,
                        mode: FileMode.append,
                      );
                      receivedBytes += remainingBytes.length;
                      onProgress(receivedBytes, totalSize, 0);
                    }
                  } catch (e) {
                    print('Erreur parsing métadonnées: $e');
                    onError('Erreur de parsing des métadonnées');
                    client.close();
                  }
                }
              } else if (outputFile != null) {
                await outputFile!.writeAsBytes(data, mode: FileMode.append);
                receivedBytes += data.length;

                final now = DateTime.now();
                final elapsedSeconds = now.difference(startTime).inSeconds;
                double speed = 0;

                if (elapsedSeconds > 0) {
                  speed = receivedBytes / elapsedSeconds / 1024;
                }

                if (now.difference(lastProgressTime).inMilliseconds >= 500) {
                  final instantSpeed =
                      (receivedBytes - lastProgressBytes) /
                      now.difference(lastProgressTime).inSeconds /
                      1024;
                  if (instantSpeed > 0 && instantSpeed.isFinite) {
                    speed = instantSpeed;
                  }
                  lastProgressTime = now;
                  lastProgressBytes = receivedBytes;
                }

                onProgress(receivedBytes, totalSize, speed);
              }
            } catch (e) {
              print('Erreur réception données: $e');
              onError('Erreur lors de la réception: $e');
              client.close();
            }
          },
          onError: (error) {
            print('Erreur socket: $error');
            onError('Erreur de connexion: $error');
          },
          onDone: () {
            print('Client déconnecté: $clientAddress');
            if (outputFile != null && receivedBytes == totalSize) {
              onComplete(outputFile!.path);
            } else if (outputFile != null) {
              onError(
                'Transfert incomplet: $receivedBytes/$totalSize bytes reçus',
              );
            }
          },
        );
      });
    } catch (e) {
      print('Erreur démarrage serveur: $e');
      onError('Impossible de démarrer le serveur: $e');
      rethrow;
    }
  }

  // Arrêter le serveur de réception
  Future<void> stopFileReceiver() async {
    await _serverSocket?.close();
    _serverSocket = null;
  }

  // Récupérer les informations réseau
  Future<Map<String, String>> _getNetworkInfo() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        // Ignorer les interfaces loopback et virtuelles
        if (interface.name.contains('lo') || interface.name.contains('veth')) {
          continue;
        }

        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              !addr.isLoopback &&
              !addr.address.startsWith('169.254')) {
            // Ignorer APIPA
            final parts = addr.address.split('.');
            String subnet;

            if (parts.length == 4) {
              subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
            } else {
              subnet = parts.sublist(0, parts.length - 1).join('.');
            }

            return {
              'ip': addr.address,
              'subnet': subnet,
              'interface': interface.name,
            };
          }
        }
      }
    } catch (e) {
      print('Erreur récupération réseau: $e');
    }

    // Fallback à localhost
    return {'ip': '127.0.0.1', 'subnet': '127.0.0', 'interface': 'loopback'};
  }

  // Générer un ID unique pour l'appareil
  Future<String> _getDeviceId() async {
    try {
      final networkInfo = await _getNetworkInfo();
      final macAddress = await _getMacAddress();
      final combined = '${networkInfo['ip']}_$macAddress';
      return combined.hashCode.toString();
    } catch (e) {
      return Platform.localHostname.hashCode.toString();
    }
  }

  // Récupérer l'adresse MAC (fonctionne sur certaines plateformes)
  Future<String> _getMacAddress() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        if (interface.addresses.any(
          (addr) => addr.type == InternetAddressType.IPv4 && !addr.isLoopback,
        )) {
          return interface.name;
        }
      }
    } catch (e) {
      print('Erreur récupération MAC: $e');
    }
    return '00:00:00:00:00:00';
  }

  // Vérifier la connectivité avec un appareil
  Future<bool> pingDevice(String ipAddress) async {
    try {
      final socket = await Socket.connect(
        ipAddress,
        transferPort,
        timeout: const Duration(seconds: 2),
      );
      socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Annuler un transfert en cours
  void cancelTransfer() {
    _serverSocket?.close();
    _channel?.sink.close();
    for (var client in _clients) {
      client.close();
    }
    _clients.clear();
  }

  // Libérer les ressources
  void dispose() {
    _serverSocket?.close();
    _channel?.sink.close();
    _udpSocket?.close();
    for (var client in _clients) {
      client.close();
    }
    _clients.clear();
  }
}
