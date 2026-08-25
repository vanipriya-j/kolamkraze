import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

ThemeData buildAarlaTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AarlaColors.maroon,
      primary: AarlaColors.maroon,
      secondary: AarlaColors.turmeric,
      surface: AarlaColors.ivory,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AarlaColors.ivory,
  );

  final useGoogle = GoogleFonts.config.allowRuntimeFetching;
  final sans = useGoogle
      ? GoogleFonts.figtreeTextTheme(base.textTheme).apply(
          bodyColor: AarlaColors.charcoal,
          displayColor: AarlaColors.charcoal,
        )
      : base.textTheme.apply(bodyColor: AarlaColors.charcoal, displayColor: AarlaColors.charcoal);

  TextStyle serif(double size, FontWeight weight) {
    if (!useGoogle) {
      return TextStyle(fontSize: size, fontWeight: weight, color: AarlaColors.charcoal, height: 0.95, fontFamily: 'serif');
    }
    return GoogleFonts.cormorantGaramond(
      fontSize: size,
      fontWeight: weight,
      color: AarlaColors.charcoal,
      height: 0.95,
    );
  }

  return base.copyWith(
    textTheme: sans.copyWith(
      displayLarge: serif(48, FontWeight.w600),
      displayMedium: serif(36, FontWeight.w600),
      headlineMedium: serif(28, FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AarlaColors.charcoal,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AarlaColors.ivory,
      indicatorColor: AarlaColors.maroon.withValues(alpha: 0.12),
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
