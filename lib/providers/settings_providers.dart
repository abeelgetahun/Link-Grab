import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/settings.dart';
import '../services/hive_service.dart';

part 'settings_providers.g.dart';

// Service provider for SettingsService
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<Settings> build() async {
    // Load initial settings; SettingsService().getSettings() handles defaults
    return _service.getSettings();
  }

  SettingsService get _service => ref.read(settingsServiceProvider);

  Future<void> updateSettings(Settings newSettings) async {
    state = const AsyncValue.loading();
    try {
      await _service.saveSettings(newSettings);
      state = AsyncValue.data(newSettings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleDarkMode() async {
    state = const AsyncValue.loading();
    try {
      final currentSettings = await _service.getSettings();
      final newSettings = Settings(darkMode: !currentSettings.darkMode);
      await _service.saveSettings(newSettings);
      state = AsyncValue.data(newSettings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// The @riverpod annotation creates settingsNotifierProvider
// Provider to get the current settings
@riverpod
Settings? currentSettings(CurrentSettingsRef ref) {
  return ref.watch(settingsNotifierProvider).when(
        data: (data) => data,
        loading: () => ref.watch(settingsNotifierProvider).value, // Keep previous value while loading
        error: (_, __) => null, // Or handle error appropriately
      );
}

// Provider to directly get the dark mode status
@riverpod
bool isDarkMode(IsDarkModeRef ref) {
  return ref.watch(settingsNotifierProvider).when(
        data: (settings) => settings.darkMode,
        loading: () => ref.watch(settingsNotifierProvider).value?.darkMode ?? false,
        error: (_, __) => false, // Default to false on error
      );
}
