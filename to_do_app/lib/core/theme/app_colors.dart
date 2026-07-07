import 'package:flutter/material.dart';

/// Raw brand palette, built from the brand swatches: Dark Russet #681702,
/// Blaze Orange #FF6601, Burnt Sienna #DF3F13, Cosmic Latte #FFF5CB,
/// Isabelline #F1EEEA, Deep Jungle Green #073D35. Warm ember tones (orange /
/// russet / sienna) carry the brand + danger roles; deep jungle green
/// carries the secondary/success role; Cosmic Latte and Isabelline anchor
/// the light neutrals. Semantic (theme-aware) colors live in [AppPalette]
/// below; always prefer those in UI code so day/night switches automatically.
class AppColors {
  AppColors._();

  // "indigo" — kept as the historical name for the brand ramp; values are
  // now the warm orange/russet family instead of purple.
  static const indigo50 = Color(0xFFFFF1E6);
  static const indigo100 = Color(0xFFFFE0C7);
  static const indigo200 = Color(0xFFFFC79A);
  static const indigo300 = Color(0xFFFFA662);
  static const indigo400 = Color(0xFFFF8433);
  static const indigo500 = Color(0xFFFF6601); // Blaze Orange
  static const indigo600 = Color(0xFF681702); // Dark Russet
  static const indigo700 = Color(0xFF4A1001);

  // "sky" — repurposed as the warm-neutral "waiting / pending" tone (no blue
  // exists in the brand palette, so pending status reads as neutral rather
  // than colored).
  static const sky50 = Color(0xFFF3EFEA);
  static const sky300 = Color(0xFFC7BBA9);
  static const sky400 = Color(0xFFA89A85);
  static const sky500 = Color(0xFF837663);
  static const sky700 = Color(0xFF4C4136);

  // "amber" — golden accent, kept distinct (more yellow) from the Blaze
  // Orange brand color so favorites/premium/medium-priority still pop apart
  // from primary actions.
  static const amber50 = Color(0xFFFFF7E0);
  static const amber300 = Color(0xFFFFDD8A);
  static const amber400 = Color(0xFFFFCB57);
  static const amber500 = Color(0xFFFFB627);
  static const amber700 = Color(0xFFC97F0A);

  // "coral" — danger/overdue/high-priority, from Burnt Sienna.
  static const coral500 = Color(0xFFDF3F13); // Burnt Sienna
  static const coral600 = Color(0xFFB93410);
  static const coralSoft = Color(0xFFFBE2DA);
  static const coralSoftBorder = Color(0xFFF3C6B6);

  // "mint" — success/completed/low-priority, from Deep Jungle Green.
  static const mint500 = Color(0xFF1C9C74);
  static const mint600 = Color(0xFF147F5E);
  static const mintSoft = Color(0xFFDDF2E7);

  // Two brand swatches that don't fit a ramp — used directly.
  static const cosmicLatte = Color(0xFFFFF5CB);
  static const jungleGreen = Color(0xFF073D35);

  // Warm neutral ramp (was cool blue-gray) — anchored on Isabelline.
  static const gray25 = Color(0xFFFEFCFA);
  static const gray50 = Color(0xFFFBF7F2);
  static const gray100 = Color(0xFFF1EEEA); // Isabelline
  static const gray150 = Color(0xFFE8E2D9);
  static const gray200 = Color(0xFFDDD5C8);
  static const gray300 = Color(0xFFC7BBA9);
  static const gray400 = Color(0xFFA89A85);
  static const gray500 = Color(0xFF837663);
  static const gray600 = Color(0xFF665A4A);
  static const gray700 = Color(0xFF4C4136);
  static const gray800 = Color(0xFF332A22);
  static const gray900 = Color(0xFF211A15);
  static const gray950 = Color(0xFF150F0C);

  // Night surfaces, derived from Deep Jungle Green rather than indigo.
  static const nightSurface = Color(0xFF0E211D);
  static const nightSurface2 = Color(0xFF122921);
  static const nightSunken = Color(0xFF061210);
  static const nightBorder = Color(0xFF1B342D);
  static const nightBorderStrong = Color(0xFF24443B);
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

  /// Warm day theme — cream/Isabelline neutrals with a Blaze Orange brand.
  static const day = AppPalette(
    bgCanvas: AppColors.gray100, // Isabelline
    bgSurface: Colors.white,
    bgSurface2: AppColors.gray50,
    bgSunken: AppColors.gray150,
    textPrimary: AppColors.gray900,
    textSecondary: AppColors.gray600,
    textTertiary: AppColors.gray400,
    borderSubtle: AppColors.gray150,
    borderDefault: AppColors.gray200,
    borderStrong: AppColors.gray300,
    brand: AppColors.indigo500, // Blaze Orange
    brandStrong: AppColors.indigo600, // Dark Russet
    brandSoft: AppColors.cosmicLatte,
    accent: AppColors.amber500,
    accentSoft: AppColors.amber50,
    secondary: AppColors.jungleGreen,
    secondarySoft: AppColors.mintSoft,
    heroGradient: [AppColors.indigo500, AppColors.coral500, AppColors.indigo600],
  );

  /// Deep-forest night theme — near-black jungle green base with a lightened
  /// ember-orange brand for contrast.
  static const night = AppPalette(
    bgCanvas: Color(0xFF081613),
    bgSurface: AppColors.nightSurface,
    bgSurface2: AppColors.nightSurface2,
    bgSunken: AppColors.nightSunken,
    textPrimary: AppColors.gray100, // Isabelline
    textSecondary: Color(0xFFC9BFAE),
    textTertiary: Color(0xFF8C8172),
    borderSubtle: AppColors.nightBorder,
    borderDefault: AppColors.nightBorderStrong,
    borderStrong: Color(0xFF2F5245),
    brand: AppColors.indigo400,
    brandStrong: AppColors.indigo300,
    brandSoft: Color(0xFF3A2313),
    accent: AppColors.amber400,
    accentSoft: Color(0xFF3B2C10),
    secondary: Color(0xFF2FA88C),
    secondarySoft: Color(0xFF16332B),
    heroGradient: [AppColors.indigo400, Color(0xFFE2531F), AppColors.indigo600],
  );
}
