import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/device.dart';
import '../../data/repositories/device_repository.dart';

class DeviceState {
  final List<Device> devices;
  final Device? currentDevice;
  final bool isDiscovering;
  final String? error;

  DeviceState({
    this.devices = const [],
    this.currentDevice,
    this.isDiscovering = false,
    this.error,
  });

  DeviceState copyWith({
    List<Device>? devices,
    Device? currentDevice,
    bool? isDiscovering,
    String? error,
  }) {
    return DeviceState(
      devices: devices ?? this.devices,
      currentDevice: currentDevice ?? this.currentDevice,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      error: error ?? this.error,
    );
  }
}

class DeviceNotifier extends StateNotifier<DeviceState> {
  final DeviceRepository _repository;

  DeviceNotifier(this._repository) : super(DeviceState()) {
    _loadCurrentDevice();
  }

  Future<void> _loadCurrentDevice() async {
    final device = await _repository.getCurrentDevice();
    state = state.copyWith(currentDevice: device);
  }

  Future<void> discoverDevices() async {
    state = state.copyWith(isDiscovering: true, error: null);

    try {
      final devices = await _repository.getAvailableDevices();
      state = state.copyWith(devices: devices, isDiscovering: false);
    } catch (e) {
      state = state.copyWith(
        isDiscovering: false,
        error: 'Erreur découverte: $e',
      );
    }
  }

  Future<void> updateDeviceName(String newName) async {
    await _repository.updateDeviceName(newName);
    await _loadCurrentDevice();
  }

  void selectDevice(Device device) {
    // Sélectionner un appareil pour le transfert
  }
}

final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>((
  ref,
) {
  return DeviceNotifier(DeviceRepository());
});
