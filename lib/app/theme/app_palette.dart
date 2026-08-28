import 'package:flutter/material.dart';

/// The app's colours, one set per brightness.
///
/// Lives on the theme as an extension so a widget reads `context.palette`
/// and repaints when the member flips dark mode. Nothing outside this file
/// names a colour value.
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.canvas,
    required this.surface,
    required this.accent,
    required this.onAccent,
    required this.accentText,
    required this.accentPressed,
    required this.accentDeep,
    required this.brand,
    required this.textPrimary,
    required this.textMuted,
    required this.textFaint,
    required this.danger,
    required this.tint,
    required this.divider,
    required this.shadow,
    required this.shadowStrength,
  });

  /// White and green: the default.
  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    canvas: Color(0xFFFBFCF8),
    surface: Color(0xFFFFFFFF),
    accent: Color(0xFFA6E22E),
    onAccent: Color(0xFF12200A),
    accentText: Color(0xFF3F7D0A),
    accentPressed: Color(0xFF8CC61E),
    accentDeep: Color(0xFF2F6108),
    brand: Color(0xFFB08A2E),
    textPrimary: Color(0xFF141A0E),
    textMuted: Color(0xFF5C6853),
    textFaint: Color(0xFF98A28E),
    danger: Color(0xFFE0563E),
    tint: Color(0xFFEFF8DC),
    divider: Color(0x1A141A0E),
    shadow: Color(0xFF1B2A10),
    shadowStrength: 0.08,
  );

  /// Black and green: the dark option.
  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    canvas: Color(0xFF161616),
    surface: Color(0xFF232323),
    accent: Color(0xFFA6E22E),
    onAccent: Color(0xFF101508),
    accentText: Color(0xFFB9EE45),
    accentPressed: Color(0xFF8CC61E),
    accentDeep: Color(0xFFC8F26A),
    brand: Color(0xFFD9B54A),
    textPrimary: Color(0xFFF2F4EC),
    textMuted: Color(0xFFA9B29E),
    textFaint: Color(0xFF6F7866),
    danger: Color(0xFFFF6B54),
    tint: Color(0xFF2C3320),
    divider: Color(0x24FFFFFF),
    shadow: Color(0xFF000000),
    shadowStrength: 0.4,
  );

  /// Illustration colours that do not change with the theme: the blossoms and
  /// the mascot are drawn, not themed.
  static const Color petalLight = Color(0xFFF0C8CD);
  static const Color petalDeep = Color(0xFFDDAAB1);
  static const Color blush = Color(0xFFF5B8BD);
  static const Color mascotBody = Color(0xFFFDEED3);
  static const Color mascotOutline = Color(0xFF3B2F1E);

  final Brightness brightness;

  /// Screen background.
  final Color canvas;

  /// Cards, inputs and the secondary button.
  final Color surface;

  /// Primary call to action.
  final Color accent;

  /// Text and icons drawn on [accent].
  final Color onAccent;

  /// Links and accent text — dark enough on [canvas] to read.
  final Color accentText;
  final Color accentPressed;

  /// Small uppercase labels on [tint].
  final Color accentDeep;

  /// The serif wordmark — the emblem's gold, in both palettes.
  final Color brand;

  final Color textPrimary;
  final Color textMuted;
  final Color textFaint;
  final Color danger;

  /// Soft tint behind chips, avatars and secondary buttons.
  final Color tint;
  final Color divider;

  /// Every elevation is this colour at a different alpha.
  final Color shadow;

  /// How heavy shadows read: a dark surface needs more to show a lift.
  final double shadowStrength;

  bool get isDark => brightness == Brightness.dark;

  Color get focus => accent;

  List<BoxShadow> get shadowInput => _shadow(1, 14, 4);
  List<BoxShadow> get shadowRaised => _shadow(1.5, 18, 6);
  List<BoxShadow> get shadowSoft => _shadow(1, 22, 8);
  List<BoxShadow> get shadowCard => _shadow(1.3, 26, 10);

  List<BoxShadow> _shadow(double weight, double blur, double dy) => [
    BoxShadow(
      color: shadow.withValues(alpha: shadowStrength * weight),
      blurRadius: blur,
      offset: Offset(0, dy),
    ),
  ];

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      canvas: mix(canvas, other.canvas),
      surface: mix(surface, other.surface),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      accentText: mix(accentText, other.accentText),
      accentPressed: mix(accentPressed, other.accentPressed),
      accentDeep: mix(accentDeep, other.accentDeep),
      brand: mix(brand, other.brand),
      textPrimary: mix(textPrimary, other.textPrimary),
      textMuted: mix(textMuted, other.textMuted),
      textFaint: mix(textFaint, other.textFaint),
      danger: mix(danger, other.danger),
      tint: mix(tint, other.tint),
      divider: mix(divider, other.divider),
      shadow: mix(shadow, other.shadow),
      shadowStrength:
          shadowStrength + (other.shadowStrength - shadowStrength) * t,
    );
  }
}

extension AppPaletteContext on BuildContext {
  /// The palette of the theme in force here.
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
