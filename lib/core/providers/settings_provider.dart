import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      isDarkMode: prefs.getBool('darkMode') ?? true,
      defaultWordLength: prefs.getInt('defaultWordLength') ?? 5,
      hardMode: prefs.getBool('hardMode') ?? false,
    );
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    state = state.copyWith(isDarkMode: value);
  }

  Future<void> setDefaultWordLength(int length) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultWordLength', length);
    state = state.copyWith(defaultWordLength: length);
  }

  Future<void> setHardMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hardMode', value);
    state = state.copyWith(hardMode: value);
  }
}

class AppSettings {
  final bool isDarkMode;
  final int defaultWordLength;
  final bool hardMode;

  const AppSettings({
    this.isDarkMode = true,
    this.defaultWordLength = 5,
    this.hardMode = false,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    int? defaultWordLength,
    bool? hardMode,
  }) =>
      AppSettings(
        isDarkMode: isDarkMode ?? this.isDarkMode,
        defaultWordLength: defaultWordLength ?? this.defaultWordLength,
        hardMode: hardMode ?? this.hardMode,
      );
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
