import 'package:equatable/equatable.dart';

class DeviceModel extends Equatable {
  final String id;
  final String name;
  final String ipAddress;
  final int port;
  final bool isConnected;
  final DateTime lastSeen;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.port,
    this.isConnected = false,
    required this.lastSeen,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      name: json['name'],
      ipAddress: json['ipAddress'],
      port: json['port'],
      isConnected: json['isConnected'] ?? false,
      lastSeen: DateTime.parse(json['lastSeen']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'port': port,
      'isConnected': isConnected,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, ipAddress, port, isConnected, lastSeen];
}
