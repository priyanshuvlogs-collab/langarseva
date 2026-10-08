import 'package:flutter/material.dart';

/// Saffron/kesari accent, the colour of seva.
const seedColor = Color(0xFFF57C00);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    appBarTheme: AppBarTheme(centerTitle: false, backgroundColor: scheme.surface, scrolledUnderElevation: 0),
    chipTheme: const ChipThemeData(showCheckmark: false),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    ),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(), isDense: true),
    cardTheme: const CardThemeData(clipBehavior: Clip.antiAlias),
  );
}
