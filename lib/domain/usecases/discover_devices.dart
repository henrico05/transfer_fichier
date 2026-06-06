import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/constants/app_constants.dart';
import '../entities/device.dart';

class DiscoverDevicesUseCase {
  Future<List<Device>> execute() async {
    final List<Device> devices = [];
    final List<Future<void>> discoveryTasks = [];

    // Découverte par broadcast UDP
    try {
      final broadcastAddress = await _getBroadcastAddress();
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      final discoverMessage = jsonEncode({
        'type': 'DISCOVER',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      socket.send(
        utf8.encode(discoverMessage),
        InternetAddress(broadcastAddress),
        AppConstants.discoveryPort,
      );

      final completer = Completer<void>();
      discoveryTasks.add(completer.future);

      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram != null) {
            final message = utf8.decode(datagram.data);
            final data = jsonDecode(message);

            if (data['type'] == 'RESPONSE') {
              devices.add(
                Device(
                  id: data['deviceId'],
                  name: data['deviceName'],
                  ipAddress: datagram.address.address,
                  port: data['port'] ?? AppConstants.transferPort,
                  isConnected: true,
                  lastSeen: DateTime.now(),
                ),
              );
            }
          }
        }
      });

      Future.delayed(const Duration(seconds: 2), () {
        socket.close();
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      await completer.future;
    } catch (e) {
      print('Erreur découverte UDP: $e');
    }

    // Découverte par WebSocket
    try {
      final localIp = await _getLocalIp();
      final subnet = localIp.substring(0, localIp.lastIndexOf('.'));

      for (int i = 1; i <= 254; i++) {
        final ip = '$subnet.$i';
        if (ip != localIp) {
          discoveryTasks.add(_tryConnect(ip, devices));
        }
      }

      await Future.wait(discoveryTasks);
    } catch (e) {
      print('Erreur découverte WebSocket: $e');
    }

    return devices;
  }

  Future<void> _tryConnect(String ip, List<Device> devices) async {
    try {
      final channel = WebSocketChannel.connect(
        Uri.parse('ws://$ip:${AppConstants.discoveryPort}'),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      channel.sink.add(
        jsonEncode({
          'type': 'PING',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      channel.stream.listen((message) {
        final data = jsonDecode(message);
        if (data['type'] == 'PONG') {
          devices.add(
            Device(
              id: data['deviceId'],
              name: data['deviceName'],
              ipAddress: ip,
              port: AppConstants.transferPort,
              isConnected: true,
              lastSeen: DateTime.now(),
            ),
          );
        }
        channel.sink.close();
      });

      await Future.delayed(const Duration(seconds: 1));
      channel.sink.close();
    } catch (e) {
      // Appareil non disponible
    }
  }

  Future<String> _getBroadcastAddress() async {
    final localIp = await _getLocalIp();
    final parts = localIp.split('.');
    return '${parts[0]}.${parts[1]}.${parts[2]}.255';
  }

  Future<String> _getLocalIp() async {
    final interfaces = await NetworkInterface.list();
    for (var interface in interfaces) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 &&
            !addr.isLoopback &&
            (addr.address.startsWith('192.168.') ||
                addr.address.startsWith('10.'))) {
          return addr.address;
        }
      }
    }
    return '127.0.0.1';
  }
}
