import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../core/constants/app_constants.dart';
import '../entities/transfer_file.dart';
import '../entities/transfer_session.dart';

class SendFileUseCase {
  Future<void> execute(
    TransferFile file,
    String targetIp,
    Function(TransferSession) onProgress,
    Function(TransferSession) onComplete,
    Function(String) onError,
  ) async {
    final session = TransferSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      file: file,
      targetDeviceId: targetIp,
      targetDeviceName: targetIp,
      startTime: DateTime.now(),
    );

    try {
      onProgress(session);

      final fileObj = File(file.path);
      if (!await fileObj.exists()) {
        throw Exception('Fichier introuvable');
      }

      final socket = await Socket.connect(
        targetIp,
        AppConstants.transferPort,
        timeout: Duration(seconds: AppConstants.connectionTimeout),
      );

      // Envoi des métadonnées
      final metadata = jsonEncode({
        'messageType': 'FILE_METADATA',
        'id': file.id,
        'name': file.name,
        'size': file.size,
        'type': file.type,
        'checksum': await _calculateChecksum(fileObj),
      });

      socket.write('$metadata\n');
      await socket.flush();

      // Envoi par chunks
      int transferredBytes = 0;
      DateTime startTime = DateTime.now();
      final inputStream = fileObj.openRead();

      await for (var chunk in inputStream) {
        socket.add(chunk);
        transferredBytes += chunk.length;

        final elapsed = DateTime.now().difference(startTime).inSeconds;
        final speed = elapsed > 0 ? transferredBytes / elapsed / 1024 : 0.0;

        final updatedSession = session.copyWith(
          transferredBytes: transferredBytes,
          currentSpeed: speed,
          status: TransferStatus.inProgress,
        );

        onProgress(updatedSession);
        await Future.delayed(Duration.zero); // Permettre à l'UI de respirer
      }

      await socket.flush();
      socket.close();

      final completedSession = session.copyWith(
        transferredBytes: file.size,
        currentSpeed: 0,
        status: TransferStatus.completed,
        endTime: DateTime.now(),
      );

      onComplete(completedSession);
    } catch (e) {
      final failedSession = session.copyWith(
        status: TransferStatus.failed,
        errorMessage: e.toString(),
        endTime: DateTime.now(),
      );
      onError(e.toString());
      onComplete(failedSession);
    }
  }

  Future<String> _calculateChecksum(File file) async {
    final bytes = await file.readAsBytes();
    return md5.convert(bytes).toString();
  }
}
