import 'package:flutter/material.dart';

/// Raw brand palette — mirrors css/variables.css from the web app.
/// Semantic (theme-aware) colors live in [AppPalette] below; always prefer
/// those in UI code so day/night switches automatically.
class AppColors {
  AppColors._();

  static const indigo50 = Color(0xFFF2F0FF);
  static const indigo100 = Color(0xFFE5E1FF);
  static const indigo200 = Color(0xFFC9C0FF);
  static const indigo300 = Color(0xFFA596FF);
  static const indigo400 = Color(0xFF8570FF);
  static const indigo500 = Color(0xFF6C4EFF);
  static const indigo600 = Color(0xFF5936E8);
  static const indigo700 = Color(0xFF4527C2);

  static const sky50 = Color(0xFFEEF8FF);
  static const sky300 = Color(0xFF7DCDFF);
  static const sky400 = Color(0xFF45B3FF);
  static const sky500 = Color(0xFF1F97F2);
  static const sky700 = Color(0xFF0D5FA3);

  static const amber50 = Color(0xFFFFF8E8);
  static const amber300 = Color(0xFFFFC352);
  static const amber400 = Color(0xFFFFAB29);
  static const amber500 = Color(0xFFFA8F0F);
  static const amber700 = Color(0xFFB74E0A);

  static const coral500 = Color(0xFFFF6B6B);
  static const coral600 = Color(0xFFEE4F4F);
  static const mint500 = Color(0xFF22C58B);
  static const mint600 = Color(0xFF16A374);

  static const gray25 = Color(0xFFFBFBFE);
  static const gray50 = Color(0xFFF5F5FB);
  static const gray100 = Color(0xFFEEEEF7);
  static const gray150 = Color(0xFFE6E6F2);
  static const gray200 = Color(0xFFDCDCE8);
  static const gray300 = Color(0xFFC3C3D6);
  static const gray400 = Color(0xFF9D9DB5);
  static const gray500 = Color(0xFF7A7A95);
  static const gray600 = Color(0xFF5D5D76);
  static const gray700 = Color(0xFF46465C);
  static const gray800 = Color(0xFF2E2E40);
  static const gray900 = Color(0xFF1C1C29);
  static const gray950 = Color(0xFF101018);

  static const nightSurface = Color(0xFF191828);
  static const nightSurface2 = Color(0xFF1F1E30);
  static const nightSunken = Color(0xFF14131F);
  static const nightBorder = Color(0xFF27263B);
  static const nightBorderStrong = Color(0xFF302F47);
}

/// Semantic tokens that flip between day and night — the Flutter equivalent
/// of the CSS custom properties in variables.css. Registered as a
/// [ThemeExtension] so any widget can read it via `context.palette`.
class AppPalette extends ThemeExtension<AppPalette> {
  final Color bgCanvas;
  final Color bgSurface;
  final Color bgSurface2;
  final Color bgSunken;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  final Color brand;
  final Color brandStrong;
  final Color brandSoft;
  final Color accent;
  final Color accentSoft;
  final Color secondary;
  final Color secondarySoft;
  final List<Color> heroGradient;

  const AppPalette({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgSurface2,
    required this.bgSunken,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.brand,
    required this.brandStrong,
    required this.brandSoft,
    required this.accent,
    required this.accentSoft,
    required this.secondary,
    required this.secondarySoft,
    required this.heroGradient,
  });

  @override
  AppPalette copyWith({
    Color? bgCanvas,
    Color? bgSurface,
    Color? bgSurface2,
    Color? bgSunken,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? brand,
    Color? brandStrong,
    Color? brandSoft,
    Color? accent,
    Color? accentSoft,
    Color? secondary,
    Color? secondarySoft,
    List<Color>? heroGradient,
  }) {
    return AppPalette(
      bgCanvas: bgCanvas ?? this.bgCanvas,
      bgSurface: bgSurface ?? this.bgSurface,
      bgSurface2: bgSurface2 ?? this.bgSurface2,
      bgSunken: bgSunken ?? this.bgSunken,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      brand: brand ?? this.brand,
      brandStrong: brandStrong ?? this.brandStrong,
      brandSoft: brandSoft ?? this.brandSoft,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      secondary: secondary ?? this.secondary,
      secondarySoft: secondarySoft ?? this.secondarySoft,
      heroGradient: heroGradient ?? this.heroGradient,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      bgCanvas: c(bgCanvas, other.bgCanvas),
      bgSurface: c(bgSurface, other.bgSurface),
      bgSurface2: c(bgSurface2, other.bgSurface2),
      bgSunken: c(bgSunken, other.bgSunken),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textTertiary: c(textTertiary, other.textTertiary),
      borderSubtle: c(borderSubtle, other.borderSubtle),
      borderDefault: c(borderDefault, other.borderDefault),
      borderStrong: c(borderStrong, other.borderStrong),
      brand: c(brand, other.brand),
      brandStrong: c(brandStrong, other.brandStrong),
      brandSoft: c(brandSoft, other.brandSoft),
      accent: c(accent, other.accent),
      accentSoft: c(accentSoft, other.accentSoft),
      secondary: c(secondary, other.secondary),
      secondarySoft: c(secondarySoft, other.secondarySoft),
      heroGradient: t < 0.5 ? heroGradient : other.heroGradient,
    );
  }

  static const day = AppPalette(
    bgCanvas: Color(0xFFF5F5FB),
    bgSurface: Colors.white,
    bgSurface2: Color(0xFFFBFBFF),
    bgSunken: Color(0xFFF0F0F9),
    textPrimary: AppColors.gray900,
    textSecondary: AppColors.gray600,
    textTertiary: AppColors.gray400,
    borderSubtle: AppColors.gray150,
    borderDefault: AppColors.gray200,
    borderStrong: AppColors.gray300,
    brand: AppColors.indigo500,
    brandStrong: AppColors.indigo600,
    brandSoft: AppColors.indigo50,
    accent: AppColors.amber500,
    accentSoft: AppColors.amber50,
    secondary: AppColors.sky500,
    secondarySoft: AppColors.sky50,
    heroGradient: [Color(0xFF6C4EFF), Color(0xFF8F6DFF), Color(0xFF45B3FF)],
  );

  static const night = AppPalette(
    bgCanvas: Color(0xFF100F1C),
    bgSurface: AppColors.nightSurface,
    bgSurface2: AppColors.nightSurface2,
    bgSunken: AppColors.nightSunken,
    textPrimary: Color(0xFFF2F1FB),
    textSecondary: Color(0xFFA9A8C4),
    textTertiary: Color(0xFF706F8D),
    borderSubtle: AppColors.nightBorder,
    borderDefault: AppColors.nightBorderStrong,
    borderStrong: Color(0xFF423F61),
    brand: AppColors.indigo400,
    brandStrong: AppColors.indigo300,
    brandSoft: Color(0xFF241F42),
    accent: AppColors.amber400,
    accentSoft: Color(0xFF382A12),
    secondary: AppColors.sky400,
    secondarySoft: Color(0xFF16283F),
    heroGradient: [Color(0xFF4527C2), Color(0xFF6C4EFF), Color(0xFF1078CC)],
  );
}
