import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Builds a Flutter [ThemeData] from an [AppPalette] — the equivalent of
/// swapping CSS custom properties via [data-theme] on the web app.
class AppTheme {
  AppTheme._();

  static ThemeData from(AppPalette p, {required bool isDark}) {
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    final colorScheme = (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: p.brand,
      onPrimary: Colors.white,
      secondary: p.secondary,
      surface: p.bgSurface,
      onSurface: p.textPrimary,
      error: AppColors.coral500,
    );

    return base.copyWith(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: p.bgCanvas,
      canvasColor: p.bgCanvas,
      colorScheme: colorScheme,
      primaryColor: p.brand,
      dividerColor: p.borderSubtle,
      splashFactory: InkRipple.splashFactory,
      textTheme: _textTheme(p),
      appBarTheme: AppBarTheme(
        backgroundColor: p.bgCanvas,
        foregroundColor: p.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: p.textPrimary,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.bgSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: p.borderSubtle),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.bgSurface,
        hintStyle: TextStyle(color: p.textTertiary, fontSize: 14),
        labelStyle: TextStyle(color: p.textSecondary, fontSize: 13, fontWeight: FontWeight.w700),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: p.borderDefault, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: p.borderDefault, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: p.brand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.coral500, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textPrimary,
          side: BorderSide(color: p.borderDefault),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.brand,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: p.bgSunken,
        selectedColor: p.brand,
        labelStyle: TextStyle(color: p.textSecondary, fontSize: 12, fontWeight: FontWeight.w700),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: StadiumBorder(side: BorderSide(color: p.borderDefault)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.bgSurface,
        selectedItemColor: p.brand,
        unselectedItemColor: p.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      drawerTheme: DrawerThemeData(backgroundColor: p.bgSurface),
      dividerTheme: DividerThemeData(color: p.borderSubtle, thickness: 1, space: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.white : p.bgSurface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.brand : p.borderStrong,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.brand : Colors.transparent,
        ),
        side: BorderSide(color: p.borderStrong, width: 1.5),
      ),
      extensions: [p],
    );
  }

  static TextTheme _textTheme(AppPalette p) {
    TextStyle base(double size, FontWeight w, Color c, {double? letterSpacing, String? family}) => TextStyle(
          fontFamily: family ?? 'Sora',
          fontSize: size,
          fontWeight: w,
          color: c,
          letterSpacing: letterSpacing,
          height: 1.3,
        );
    TextStyle display(double size, {double? letterSpacing}) =>
        base(size, FontWeight.w700, p.textPrimary, letterSpacing: letterSpacing, family: 'SpaceGrotesk');
    return TextTheme(
      displayLarge: display(40, letterSpacing: -0.5),
      displayMedium: display(32, letterSpacing: -0.4),
      displaySmall: display(26, letterSpacing: -0.3),
      headlineMedium: display(22, letterSpacing: -0.2),
      headlineSmall: display(19),
      titleLarge: base(17, FontWeight.w700, p.textPrimary),
      titleMedium: base(15, FontWeight.w700, p.textPrimary),
      titleSmall: base(13, FontWeight.w700, p.textSecondary),
      bodyLarge: base(15, FontWeight.w400, p.textPrimary),
      bodyMedium: base(13.5, FontWeight.w400, p.textSecondary),
      bodySmall: base(12, FontWeight.w500, p.textTertiary),
      labelLarge: base(14, FontWeight.w700, p.textPrimary),
      labelMedium: base(12, FontWeight.w700, p.textSecondary),
      labelSmall: base(11, FontWeight.w700, p.textTertiary, letterSpacing: 0.4),
    );
  }
}

/// Lets any widget read the raw semantic palette — for things ThemeData has
/// no slot for (hero gradients, sunken backgrounds, etc.) — via
/// `context.palette` instead of the verbose ThemeExtension lookup.
extension AppPaletteContextX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
