import 'package:equatable/equatable.dart';
import 'file_model.dart';

enum TransferStatusModel {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
  paused,
}

enum TransferDirectionModel { send, receive }

class TransferModel extends Equatable {
  final String id;
  final FileModel file;
  final String targetDeviceId;
  final String targetDeviceName;
  final String targetIp;
  final TransferDirectionModel direction;
  final TransferStatusModel status;
  final int transferredBytes;
  final int totalBytes;
  final double currentSpeed;
  final DateTime startTime;
  final DateTime? endTime;
  final int retryCount;
  final String? errorMessage;

  const TransferModel({
    required this.id,
    required this.file,
    required this.targetDeviceId,
    required this.targetDeviceName,
    required this.targetIp,
    required this.direction,
    required this.status,
    required this.transferredBytes,
    required this.totalBytes,
    required this.currentSpeed,
    required this.startTime,
    this.endTime,
    required this.retryCount,
    this.errorMessage,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      id: json['id'],
      file: FileModel.fromJson(json['file']),
      targetDeviceId: json['targetDeviceId'],
      targetDeviceName: json['targetDeviceName'],
      targetIp: json['targetIp'],
      direction: _parseDirection(json['direction']),
      status: _parseStatus(json['status']),
      transferredBytes: json['transferredBytes'],
      totalBytes: json['totalBytes'],
      currentSpeed: (json['currentSpeed'] as num).toDouble(),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      retryCount: json['retryCount'],
      errorMessage: json['errorMessage'],
    );
  }

  factory TransferModel.fromJsonDb(Map<String, dynamic> json, FileModel file) {
    return TransferModel(
      id: json['id'],
      file: file,
      targetDeviceId: json['target_device_id'],
      targetDeviceName: json['target_device_name'],
      targetIp: json['target_ip'],
      direction: _parseDirection(json['direction']),
      status: _parseStatus(json['status']),
      transferredBytes: json['transferred_bytes'],
      totalBytes: json['total_bytes'],
      currentSpeed: (json['current_speed'] as num).toDouble(),
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : null,
      retryCount: json['retry_count'],
      errorMessage: json['error_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file': file.toJson(),
      'targetDeviceId': targetDeviceId,
      'targetDeviceName': targetDeviceName,
      'targetIp': targetIp,
      'direction': direction.name,
      'status': status.name,
      'transferredBytes': transferredBytes,
      'totalBytes': totalBytes,
      'currentSpeed': currentSpeed,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'retryCount': retryCount,
      'errorMessage': errorMessage,
    };
  }

  Map<String, dynamic> toJsonDb() {
    return {
      'id': id,
      'file_id': file.id,
      'target_device_id': targetDeviceId,
      'target_device_name': targetDeviceName,
      'target_ip': targetIp,
      'direction': direction.name,
      'status': status.name,
      'transferred_bytes': transferredBytes,
      'total_bytes': totalBytes,
      'current_speed': currentSpeed,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'retry_count': retryCount,
      'error_message': errorMessage,
    };
  }

  double get progress => totalBytes > 0 ? transferredBytes / totalBytes : 0;

  String get remainingTime {
    if (currentSpeed <= 0) return 'Calcul en cours...';
    final remainingBytes = totalBytes - transferredBytes;
    final seconds = remainingBytes / (currentSpeed * 1024);

    if (seconds < 60) return '${seconds.toStringAsFixed(0)} secondes';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(0)} minutes';
    return '${(seconds / 3600).toStringAsFixed(1)} heures';
  }

  static TransferDirectionModel _parseDirection(String value) {
    return TransferDirectionModel.values.firstWhere(
      (e) => e.name == value || e.toString() == value,
      orElse: () => TransferDirectionModel.send,
    );
  }

  static TransferStatusModel _parseStatus(String value) {
    return TransferStatusModel.values.firstWhere(
      (e) => e.name == value || e.toString() == value,
      orElse: () => TransferStatusModel.pending,
    );
  }

  TransferModel copyWith({
    String? id,
    FileModel? file,
    String? targetDeviceId,
    String? targetDeviceName,
    String? targetIp,
    TransferDirectionModel? direction,
    TransferStatusModel? status,
    int? transferredBytes,
    int? totalBytes,
    double? currentSpeed,
    DateTime? startTime,
    DateTime? endTime,
    int? retryCount,
    String? errorMessage,
  }) {
    return TransferModel(
      id: id ?? this.id,
      file: file ?? this.file,
      targetDeviceId: targetDeviceId ?? this.targetDeviceId,
      targetDeviceName: targetDeviceName ?? this.targetDeviceName,
      targetIp: targetIp ?? this.targetIp,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
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
    targetIp,
    direction,
    status,
    transferredBytes,
    totalBytes,
    currentSpeed,
    startTime,
    endTime,
    retryCount,
    errorMessage,
  ];
}
