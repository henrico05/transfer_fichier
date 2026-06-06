import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/device.dart';

class DeviceRepository {
  static final DeviceRepository _instance = DeviceRepository._internal();
  factory DeviceRepository() => _instance;
  DeviceRepository._internal();

  List<Device> _devices = [];

  Future<Device> getCurrentDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId =
        prefs.getString(AppConstants.prefDeviceId) ?? await _generateDeviceId();
    final deviceName =
        prefs.getString(AppConstants.prefDeviceName) ?? Platform.localHostname;

    return Device(
      id: deviceId,
      name: deviceName,
      ipAddress: await _getLocalIp(),
      port: AppConstants.transferPort,
      isConnected: true,
      lastSeen: DateTime.now(),
    );
  }

  Future<void> updateDeviceName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefDeviceName, newName);
  }

  Future<List<Device>> getAvailableDevices() async {
    // Découverte des appareils sur le réseau
    return _devices.where((d) => d.isConnected).toList();
  }

  Future<void> addDevice(Device device) async {
    if (!_devices.any((d) => d.id == device.id)) {
      _devices.add(device);
    }
  }

  Future<void> removeDevice(String deviceId) async {
    _devices.removeWhere((d) => d.id == deviceId);
  }

  Future<void> updateDeviceStatus(String deviceId, bool isConnected) async {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      _devices[index] = _devices[index].copyWith(
        isConnected: isConnected,
        lastSeen: DateTime.now(),
      );
    }
  }

  Future<String> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              !addr.isLoopback &&
              addr.address.startsWith('192.168.')) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      print('Erreur récupération IP: $e');
    }
    return '127.0.0.1';
  }

  Future<String> _generateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(AppConstants.prefDeviceId, deviceId);
    return deviceId;
  }
}
