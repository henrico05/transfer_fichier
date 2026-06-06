import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class SettingsState {
  final bool darkMode;
  final bool compressionEnabled;
  final bool encryptionEnabled;
  final String savePath;
  final int maxConcurrentTransfers;

  SettingsState({
    this.darkMode = true,
    this.compressionEnabled = false,
    this.encryptionEnabled = true,
    this.savePath = '',
    this.maxConcurrentTransfers = 3,
  });

  SettingsState copyWith({
    bool? darkMode,
    bool? compressionEnabled,
    bool? encryptionEnabled,
    String? savePath,
    int? maxConcurrentTransfers,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      compressionEnabled: compressionEnabled ?? this.compressionEnabled,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
      savePath: savePath ?? this.savePath,
      maxConcurrentTransfers:
          maxConcurrentTransfers ?? this.maxConcurrentTransfers,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    state = state.copyWith(
      darkMode: prefs.getBool(AppConstants.prefDarkMode) ?? true,
      compressionEnabled:
          prefs.getBool(AppConstants.prefCompressionEnabled) ?? false,
      encryptionEnabled:
          prefs.getBool(AppConstants.prefEncryptionEnabled) ?? true,
      savePath: prefs.getString(AppConstants.prefSavePath) ?? '',
    );
  }

  Future<void> toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefDarkMode, value);
    state = state.copyWith(darkMode: value);
  }

  Future<void> toggleCompression(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefCompressionEnabled, value);
    state = state.copyWith(compressionEnabled: value);
  }

  Future<void> toggleEncryption(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefEncryptionEnabled, value);
    state = state.copyWith(encryptionEnabled: value);
  }

  Future<void> setSavePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefSavePath, path);
    state = state.copyWith(savePath: path);
  }

  Future<void> setMaxConcurrentTransfers(int value) async {
    state = state.copyWith(maxConcurrentTransfers: value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);
