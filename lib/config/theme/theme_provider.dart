/// Proveedor del tema (claro/oscuro) con persistencia en SharedPreferences.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _key = 'flash_theme_mode';

  @override
  ThemeMode build() {
    _loadFromStorage();
    return ThemeMode.dark;
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      await prefs.setString(_key, 'light');
    } else {
      state = ThemeMode.dark;
      await prefs.setString(_key, 'dark');
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    state = mode;
    await prefs.setString(_key, mode == ThemeMode.dark ? 'dark' : 'light');
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);