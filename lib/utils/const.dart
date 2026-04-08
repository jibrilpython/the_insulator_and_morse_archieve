import 'package:flutter/material.dart';
import 'package:insulator_and_morse_archieve/enum/my_enums.dart';

// ─── THE GLASS KINETIC: 2026 PREMIUM ───────────────────────────────────────────

const Color kBackground    = Color(0xFF0D0D0D); // Deep Obsidian
const Color kAccent        = Color(0xFF5EDFFF); // Pulsing Cyan
const Color kAccentAmber   = Color(0xFFFFB347); // Warning Amber
const Color kPrimaryText   = Color(0xFFF9F9F9); // Crisp White
const Color kSecondaryText = Color(0xFF7E7E7E); // Muted Pewter

// Surface Overhaul
const Color kPanelBg       = Color(0xFF161616); // Layer Surface
const Color kOutline       = Color(0xFF242424); // Fine Border
const Color kGlassSurface   = Color(0x33FFFFFF); // Glass Base
const Color kError         = Color(0xFFFF5252);

// Glass Kinetic Constants
const double kRadiusXLarge   = 48.0; // High-Fidelity Pills
const double kRadiusLarge    = 28.0;
const double kRadiusStandard = 20.0;
const double kRadiusSubtle   = 12.0;
const double kRadiusPill     = 999.0;

// High-Fidelity Glows
const BoxShadow kShadowCyan = BoxShadow(
  color: Color(0x335EDFFF),
  blurRadius: 32,
  spreadRadius: -4,
  offset: Offset(0, 8),
);

const BoxShadow kShadowAmber = BoxShadow(
  color: Color(0x22FFB347),
  blurRadius: 24,
  spreadRadius: -2,
  offset: Offset(0, 4),
);

const BoxShadow kShadowFloat = BoxShadow(
  color: Color(0x66000000),
  blurRadius: 40,
  spreadRadius: 0,
  offset: Offset(0, 12),
);

// Glass Mesh Gradients
final kMeshGradient = [
  kBackground,
  const Color(0xFF121212),
  const Color(0xFF0D0D0D),
];

// Helper: Hardware Category Colors (2026 Soft Palette)
Color getCategoryColor(HardwareCategory category) {
  switch (category) {
    case HardwareCategory.glassInsulator:
      return const Color(0xFF4AC7E0); // Electric Aqua
    case HardwareCategory.porcelainInsulator:
      return const Color(0xFFE0E0E0); // Ceramic White
    case HardwareCategory.telegraphKey:
      return const Color(0xFFB5935A); // Burnished Brass
    case HardwareCategory.sounder:
      return const Color(0xFF8B6B4A); // Mahogany Relay
    case HardwareCategory.lightningArrestor:
      return const Color(0xFFFF7E5F); // Plasma Orange
    case HardwareCategory.cableSplice:
      return const Color(0xFF567A6A); // Lead Oxide
    case HardwareCategory.other:
      return const Color(0xFF8E8E93); // Neutral Component
  }
}

// Condition State Colors
Color getConditionColor(ConditionState state) {
  switch (state) {
    case ConditionState.mint:
      return const Color(0xFF63FFB4); // Pristine Green
    case ConditionState.excellent:
      return const Color(0xFF96FF63);
    case ConditionState.good:
      return const Color(0xFFFFB363);
    case ConditionState.fair:
      return const Color(0xFFFFE063);
    case ConditionState.poor:
      return const Color(0xFFFF6363);
    case ConditionState.unknown:
      return kSecondaryText;
  }
}

// Glass Spectrum Colors (Updated for Kinetic Swatches)
Color getGlassSwatchColor(String colorName) {
  final name = colorName.toLowerCase().trim();
  bool matches(List<String> keywords) {
    return keywords.any((k) => RegExp('\\b$k\\b').hasMatch(name));
  }

  if (matches(['aqua', 'teal', 'cyan'])) return const Color(0xFF7FFFD4);
  if (matches(['blue', 'cobalt', 'sapphire'])) return const Color(0xFF007FFF);
  if (matches(['amber', 'yellow', 'honey'])) return const Color(0xFFFFBF00);
  if (matches(['green', 'sage', 'emerald'])) return const Color(0xFF50C878);
  if (matches(['red', 'ruby', 'crimson'])) return const Color(0xFFFF4D4D);
  if (matches(['orange', 'coral'])) return const Color(0xFFFF7F50);
  if (matches(['gold', 'brass'])) return const Color(0xFFFFD700);
  if (matches(['purple', 'opal', 'amethyst'])) return const Color(0xFF9370DB);
  if (matches(['olive', 'khaki'])) return const Color(0xFF808000);
  if (matches(['straw', 'champagne'])) return const Color(0xFFE4D96F);
  if (matches(['smoke', 'gray', 'grey'])) return const Color(0xFF708090);
  if (matches(['clear', 'transparent'])) return const Color(0xFFE5E4E2);
  if (matches(['white', 'milk'])) return const Color(0xFFF5F5F5);
  if (matches(['brown', 'root beer'])) return const Color(0xFF8B4513);
  return kSecondaryText; // Default: Muted Pewter
}

