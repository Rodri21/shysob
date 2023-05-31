
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shysob/settings/styles_settings.dart';

final themeProvider = StateProvider<ThemeData>((ref) {
  return StylesSettings.lightTheme();
});

final themeModeProvider = StateProvider((ref) {
  return ThemeMode.light;
});
