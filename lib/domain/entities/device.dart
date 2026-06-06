import 'package:equatable/equatable.dart';

class Device extends Equatable {
  final String id;
  final String name;
  final String ipAddress;
  final int port;
  final bool isConnected;
  final DateTime lastSeen;
  final int? signalStrength;

  const Device({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.port,
    this.isConnected = false,
    required this.lastSeen,
    this.signalStrength,
  });

  factory Device.empty() {
    return Device(
      id: '',
      name: '',
      ipAddress: '',
      port: 0,
      lastSeen: DateTime.now(),
    );
  }

  Device copyWith({
    String? id,
    String? name,
    String? ipAddress,
    int? port,
    bool? isConnected,
    DateTime? lastSeen,
    int? signalStrength,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      isConnected: isConnected ?? this.isConnected,
      lastSeen: lastSeen ?? this.lastSeen,
      signalStrength: signalStrength ?? this.signalStrength,
    );
  }

  String get formattedAddress => '$ipAddress:$port';

  bool get isLocal =>
      ipAddress.startsWith('192.168.') || ipAddress.startsWith('10.');

  @override
  List<Object?> get props => [
    id,
    name,
    ipAddress,
    port,
    isConnected,
    lastSeen,
    signalStrength,
  ];
}
