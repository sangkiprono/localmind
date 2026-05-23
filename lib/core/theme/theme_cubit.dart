import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark');
    if (isDark == null) {
      emit(ThemeMode.system);
    } else {
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = state == ThemeMode.dark;
    await prefs.setBool('is_dark', !isDark);
    emit(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}