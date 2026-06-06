import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import '../../core/constants/app_constants.dart';
import '../entities/transfer_file.dart';
import '../entities/transfer_session.dart';

class ReceiveFileUseCase {
  Stream<TransferSession> execute(String savePath) async* {
    ServerSocket? serverSocket;

    try {
      serverSocket = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        AppConstants.transferPort,
      );

      await for (Socket client in serverSocket) {
        TransferSession? session;
        File? outputFile;
        int receivedBytes = 0;
        DateTime startTime = DateTime.now();
        final metadataBuffer = BytesBuilder();
        bool metadataParsed = false;

        await for (Uint8List data in client) {
          if (!metadataParsed) {
            metadataBuffer.add(data);
            final packet = metadataBuffer.toBytes();
            final newlineIndex = packet.indexOf(10); // '\n'

            if (newlineIndex != -1) {
              final metadataBytes = packet.sublist(0, newlineIndex);
              final remainingBytes = packet.sublist(newlineIndex + 1);
              final metadataStr = utf8.decode(metadataBytes);
              final metadata = jsonDecode(metadataStr);

              final file = TransferFile(
                id: metadata['id'],
                name: metadata['name'],
                path: '$savePath/${metadata['name']}',
                size: metadata['size'],
                type: metadata['type'],
                createdAt: DateTime.now(),
              );

              session = TransferSession(
                id: metadata['id'],
                file: file,
                targetDeviceId: client.remoteAddress.address,
                targetDeviceName: client.remoteAddress.address,
                startTime: DateTime.now(),
              );

              outputFile = File(file.path);
              await outputFile.create(recursive: true);

              if (remainingBytes.isNotEmpty) {
                await outputFile.writeAsBytes(
                  remainingBytes,
                  mode: FileMode.append,
                );
                receivedBytes += remainingBytes.length;
              }

              metadataParsed = true;
            }
          } else if (outputFile != null && session != null) {
            await outputFile.writeAsBytes(data, mode: FileMode.append);
            receivedBytes += data.length;

            final elapsed = DateTime.now().difference(startTime).inSeconds;
            final speed = elapsed > 0 ? receivedBytes / elapsed / 1024 : 0.0;

            final updatedSession = session.copyWith(
              transferredBytes: receivedBytes,
              currentSpeed: speed,
              status: TransferStatus.inProgress,
            );

            yield updatedSession;
          }
        }

        if (session != null && receivedBytes == session.file.size) {
          final completedSession = session.copyWith(
            transferredBytes: receivedBytes,
            status: TransferStatus.completed,
            endTime: DateTime.now(),
          );
          yield completedSession;
        }

        await client.close();
      }
    } catch (e) {
      rethrow;
    } finally {
      await serverSocket?.close();
    }
  }
}
