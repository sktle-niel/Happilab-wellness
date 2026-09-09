import 'package:flutter/material.dart';

/// The app's colours, one set per brightness.
///
/// Lives on the theme as an extension so a widget reads `context.palette`
/// and repaints when the member flips dark mode. Nothing outside this file
/// names a colour value. The scheme is the admin website's: paper and ink,
/// lime for the action, lavender for the notice, quiet greys for the rest.
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
    required this.info,
    required this.tint,
    required this.glass,
    required this.glassEdge,
    required this.divider,
    required this.shadow,
    required this.shadowStrength,
  });

  /// Paper and ink with lime: the default.
  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    canvas: Color(0xFFF6F6F4),
    surface: Color(0xFFFFFFFF),
    accent: Color(0xFFD6F26A),
    onAccent: Color(0xFF2F3B00),
    accentText: Color(0xFF4F7A00),
    accentPressed: Color(0xFFC9E85A),
    accentDeep: Color(0xFF2F3B00),
    brand: Color(0xFFB7791F),
    textPrimary: Color(0xFF141414),
    textMuted: Color(0xFF5C5C59),
    textFaint: Color(0xFF9A9A96),
    danger: Color(0xFFC73E3E),
    info: Color(0xFF5F55CF),
    tint: Color(0xFFEEF7CF),
    glass: Color(0xF5FFFFFF),
    glassEdge: Color(0x0D141414),
    divider: Color(0x14141414),
    shadow: Color(0xFF141414),
    shadowStrength: 0.06,
  );

  /// Ink with lime: the dark option.
  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    canvas: Color(0xFF111111),
    surface: Color(0xFF1F1F1F),
    accent: Color(0xFFD6F26A),
    onAccent: Color(0xFF2F3B00),
    accentText: Color(0xFFD6F26A),
    accentPressed: Color(0xFFC9E85A),
    accentDeep: Color(0xFFE7F8A6),
    brand: Color(0xFFD9A84A),
    textPrimary: Color(0xFFF2F2EE),
    textMuted: Color(0xFFB9B9B5),
    textFaint: Color(0xFF7A7A76),
    danger: Color(0xFFFF6B54),
    info: Color(0xFFB9B2F4),
    tint: Color(0xFF262626),
    glass: Color(0xF01F1F1F),
    glassEdge: Color(0x14FFFFFF),
    divider: Color(0x1FFFFFFF),
    shadow: Color(0xFF000000),
    shadowStrength: 0.4,
  );

  /// Illustration colours that do not change with the theme: the mascot is
  /// drawn, not themed.
  static const Color blush = Color(0xFFF5B8BD);
  static const Color mascotBody = Color(0xFFFDEED3);
  static const Color mascotOutline = Color(0xFF3B2F1E);

  final Brightness brightness;

  /// Screen background behind the illustration.
  final Color canvas;

  /// Cards, inputs and the secondary button.
  final Color surface;

  /// Primary call to action: the lime.
  final Color accent;

  /// Text and icons drawn on [accent]: the lime's own dark ink.
  final Color onAccent;

  /// Links and accent text — a green dark enough on paper to read.
  final Color accentText;
  final Color accentPressed;

  /// Small uppercase labels on [tint].
  final Color accentDeep;

  /// Amber, for what should not read as an action — the rating stars and
  /// the caution toast.
  final Color brand;

  final Color textPrimary;
  final Color textMuted;
  final Color textFaint;
  final Color danger;

  /// Neutral notice, in the website's lavender: the one status colour outside
  /// the lime, so information has its own voice.
  final Color info;

  /// Soft lime behind chips, avatars and secondary buttons.
  final Color tint;

  /// Cards and sheets, laid over the backdrop: paper with a breath of the
  /// picture through it, held off the page by a hairline and a soft shadow
  /// rather than a drawn border.
  final Color glass;

  /// The hairline round a [glass] surface.
  final Color glassEdge;
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
      info: mix(info, other.info),
      tint: mix(tint, other.tint),
      glass: mix(glass, other.glass),
      glassEdge: mix(glassEdge, other.glassEdge),
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
