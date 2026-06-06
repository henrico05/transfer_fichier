import 'package:equatable/equatable.dart';
import 'transfer_file.dart';

enum TransferStatus {
  pending,
  preparing,
  inProgress,
  paused,
  completed,
  failed,
  cancelled,
}

class TransferSession extends Equatable {
  final String id;
  final TransferFile file;
  final String targetDeviceId;
  final String targetDeviceName;
  final TransferStatus status;
  final int transferredBytes;
  final DateTime startTime;
  final DateTime? endTime;
  final double currentSpeed;
  final int retryCount;
  final String? errorMessage;

  const TransferSession({
    required this.id,
    required this.file,
    required this.targetDeviceId,
    required this.targetDeviceName,
    this.status = TransferStatus.pending,
    this.transferredBytes = 0,
    required this.startTime,
    this.endTime,
    this.currentSpeed = 0.0,
    this.retryCount = 0,
    this.errorMessage,
  });

  double get progress => file.size > 0 ? transferredBytes / file.size : 0;

  String get remainingTime {
    if (currentSpeed <= 0) return 'Calcul en cours...';
    final remainingBytes = file.size - transferredBytes;
    final seconds = remainingBytes / (currentSpeed * 1024);

    if (seconds < 60) return '${seconds.toStringAsFixed(0)}s';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(0)}min';
    return '${(seconds / 3600).toStringAsFixed(1)}h';
  }

  TransferSession copyWith({
    String? id,
    TransferFile? file,
    String? targetDeviceId,
    String? targetDeviceName,
    TransferStatus? status,
    int? transferredBytes,
    DateTime? startTime,
    DateTime? endTime,
    double? currentSpeed,
    int? retryCount,
    String? errorMessage,
  }) {
    return TransferSession(
      id: id ?? this.id,
      file: file ?? this.file,
      targetDeviceId: targetDeviceId ?? this.targetDeviceId,
      targetDeviceName: targetDeviceName ?? this.targetDeviceName,
      status: status ?? this.status,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    id,
    file,
    targetDeviceId,
    targetDeviceName,
    status,
    transferredBytes,
    startTime,
    endTime,
    currentSpeed,
    retryCount,
    errorMessage,
  ];
}
