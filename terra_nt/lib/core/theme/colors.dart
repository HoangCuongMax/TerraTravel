import 'package:flutter/material.dart';

/// Colour tokens, transcribed from `design/design-system/tokens/colors.css`.
///
/// The sections and order below mirror that file so the two can be diffed by eye.
///
/// Only *base* tokens carry a literal. Every semantic alias references the base
/// constant it points at, exactly as the CSS uses `var(--color-…)`: duplicating a
/// hex would mean a correction had to be made in two places, which is the whole
/// reason this file exists.
class AppColors {
  AppColors._();

  static AppPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? const AppPalette.light()
      : const AppPalette.dark();

  // ---------- Brand & accent ----------
  static const primary = Color(0xFF5E6AD2);
  static const primaryHover = Color(0xFF828FFF);
  static const primaryFocus = Color(0xFF5E69D1);
  static const onPrimary = Color(0xFFFFFFFF);
  static const brandSecure = Color(0xFF7A7FAD);

  // ---------- Surface ladder ----------
  static const canvas = Color(0xFF010102);
  static const surface1 = Color(0xFF0F1011);
  static const surface2 = Color(0xFF141516);
  static const surface3 = Color(0xFF18191A);
  static const surface4 = Color(0xFF191A1B);

  // ---------- Hairlines ----------
  static const hairline = Color(0xFF23252A);
  static const hairlineStrong = Color(0xFF34343A);
  static const hairlineTertiary = Color(0xFF3E3E44);

  // ---------- Ink ----------
  static const ink = Color(0xFFF7F8F8);
  static const inkMuted = Color(0xFFD0D6E0);
  static const inkSubtle = Color(0xFF8A8F98);
  static const inkTertiary = Color(0xFF62666D);

  // ---------- Inverse ----------
  static const inverseCanvas = Color(0xFFFFFFFF);
  static const inverseSurface1 = Color(0xFFF5F6F6);
  static const inverseSurface2 = Color(0xFFF6F7F7);
  static const inverseInk = Color(0xFF000000);

  // ---------- Semantic ----------
  static const success = Color(0xFF27A644);
  static const overlay = Color(0xFF000000);

  // ---------- Semantic aliases ----------
  static const bgPage = canvas;
  static const bgCard = surface1;
  static const bgCardFeatured = surface2;
  static const bgCardHover = surface2;
  static const bgMenu = surface3;
  static const bgLifted = surface4;
  static const bgInverse = inverseCanvas;

  /// `--bg-scrim: rgb(1 1 2 / 0.72)`. That rgb triplet is `--color-canvas`, so this
  /// stays an alias rather than a fourth literal. Not `const`: `withValues` is not.
  static final bgScrim = canvas.withValues(alpha: 0.72);

  static const textHeading = ink;
  static const textBody = ink;
  static const textSecondary = inkMuted;
  static const textTertiary = inkSubtle;
  static const textDisabled = inkTertiary;
  static const textInverse = inverseInk;
  static const textLink = primary;
  static const textLinkHover = primaryHover;

  static const borderCard = hairline;
  static const borderCardFeatured = hairlineStrong;
  static const borderNested = hairlineTertiary;
  static const borderFocus = primaryFocus;

  static const actionPrimaryBg = primary;
  static const actionPrimaryBgHover = primaryHover;
  static const actionPrimaryBgPressed = primaryFocus;
  static const actionPrimaryFg = onPrimary;
  static const actionSecondaryBg = surface1;
  static const actionSecondaryBgHover = surface2;
  static const actionSecondaryFg = ink;

  /// `--action-tertiary-bg: transparent`. Written as a fully transparent literal
  /// rather than `Colors.transparent` so this file needs no material import.
  static const actionTertiaryBg = Color(0x00000000);
  static const actionTertiaryBgHover = surface1;
  static const actionInverseBg = inverseCanvas;
  static const actionInverseBgHover = inverseSurface1;
  static const actionInverseFg = inverseInk;

  // ---------- Product-UI accent tags ----------
  //
  // Provisional (`docs/PRD.md` Q7): derived from the accent hue family, never
  // sampled from the real product. They keep their own literals even though
  // `tagBlue` currently equals `primary` and `tagGreen` equals `success` — a
  // correction to a tag must not drag a brand colour with it.
  static const tagBlue = Color(0xFF5E6AD2);
  static const tagPurple = Color(0xFF8B5CF0);
  static const tagGreen = Color(0xFF27A644);
  static const tagYellow = Color(0xFFD4A72C);
  static const tagOrange = Color(0xFFD97B34);
  static const tagRed = Color(0xFFD1484A);

  // ---------- App scrims and translucent surfaces ----------
  static final loginScrimStart = canvas.withValues(alpha: 0.5);
  static final loginScrimMid = canvas.withValues(alpha: 0.72);
  static final welcomeScrim = canvas.withValues(alpha: 0.42);
  static final onboardingScrim = canvas.withValues(alpha: 0.18);
  static final onboardingChrome = surface2.withValues(alpha: 0.7);
  static final stopDetailHeroScrim = surface1.withValues(alpha: 0.8);
}

/// Context-scoped palette. Static AppColors remain the dark reference tokens.
class AppPalette {
  const AppPalette.light() : isLight = true;
  const AppPalette.dark() : isLight = false;
  final bool isLight;
  Color get primary => isLight ? Color(0xFF4F46B5) : AppColors.primary;
  Color get primaryHover =>
      isLight ? Color(0xFF413797) : AppColors.primaryHover;
  Color get primaryFocus =>
      isLight ? Color(0xFF3A308B) : AppColors.primaryFocus;
  Color get onPrimary => isLight ? AppColors.onPrimary : AppColors.onPrimary;
  Color get brandSecure => isLight ? Color(0xFF5D568E) : AppColors.brandSecure;
  Color get canvas => isLight ? Color(0xFFF6F7FA) : AppColors.canvas;
  Color get surface1 => isLight ? Color(0xFFFFFFFF) : AppColors.surface1;
  Color get surface2 => isLight ? Color(0xFFF0F1F6) : AppColors.surface2;
  Color get surface3 => isLight ? Color(0xFFE8EAF2) : AppColors.surface3;
  Color get surface4 => isLight ? Color(0xFFE1E4EF) : AppColors.surface4;
  Color get hairline => isLight ? Color(0xFFD9DDE7) : AppColors.hairline;
  Color get hairlineStrong =>
      isLight ? Color(0xFFB9C0D0) : AppColors.hairlineStrong;
  Color get hairlineTertiary =>
      isLight ? Color(0xFF9BA5B9) : AppColors.hairlineTertiary;
  Color get ink => isLight ? Color(0xFF181B26) : AppColors.ink;
  Color get inkMuted => isLight ? Color(0xFF34394A) : AppColors.inkMuted;
  Color get inkSubtle => isLight ? Color(0xFF535B70) : AppColors.inkSubtle;
  Color get inkTertiary => isLight ? Color(0xFF60697E) : AppColors.inkTertiary;
  Color get inverseCanvas =>
      isLight ? AppColors.canvas : AppColors.inverseCanvas;
  Color get inverseSurface1 =>
      isLight ? AppColors.surface1 : AppColors.inverseSurface1;
  Color get inverseSurface2 =>
      isLight ? AppColors.surface2 : AppColors.inverseSurface2;
  Color get inverseInk => isLight ? AppColors.ink : AppColors.inverseInk;
  Color get success => isLight ? Color(0xFF177A32) : AppColors.success;
  Color get overlay => isLight ? AppColors.overlay : AppColors.overlay;
  Color get bgPage => isLight ? canvas : AppColors.bgPage;
  Color get bgCard => isLight ? surface1 : AppColors.bgCard;
  Color get bgCardFeatured => isLight ? surface2 : AppColors.bgCardFeatured;
  Color get bgCardHover => isLight ? surface2 : AppColors.bgCardHover;
  Color get bgMenu => isLight ? surface3 : AppColors.bgMenu;
  Color get bgLifted => isLight ? surface4 : AppColors.bgLifted;
  Color get bgInverse => isLight ? inverseCanvas : AppColors.bgInverse;
  Color get bgScrim =>
      isLight ? canvas.withValues(alpha: 0.72) : AppColors.bgScrim;
  Color get textHeading => isLight ? ink : AppColors.textHeading;
  Color get textBody => isLight ? ink : AppColors.textBody;
  Color get textSecondary => isLight ? inkMuted : AppColors.textSecondary;
  Color get textTertiary => isLight ? inkSubtle : AppColors.textTertiary;
  Color get textDisabled => isLight ? inkTertiary : AppColors.textDisabled;
  Color get textInverse => isLight ? inverseInk : AppColors.textInverse;
  Color get textLink => isLight ? primary : AppColors.textLink;
  Color get textLinkHover => isLight ? primaryHover : AppColors.textLinkHover;
  Color get borderCard => isLight ? hairline : AppColors.borderCard;
  Color get borderCardFeatured =>
      isLight ? hairlineStrong : AppColors.borderCardFeatured;
  Color get borderNested => isLight ? hairlineTertiary : AppColors.borderNested;
  Color get borderFocus => isLight ? primaryFocus : AppColors.borderFocus;
  Color get actionPrimaryBg => isLight ? primary : AppColors.actionPrimaryBg;
  Color get actionPrimaryBgHover =>
      isLight ? primaryHover : AppColors.actionPrimaryBgHover;
  Color get actionPrimaryBgPressed =>
      isLight ? primaryFocus : AppColors.actionPrimaryBgPressed;
  Color get actionPrimaryFg => isLight ? onPrimary : AppColors.actionPrimaryFg;
  Color get actionSecondaryBg =>
      isLight ? surface1 : AppColors.actionSecondaryBg;
  Color get actionSecondaryBgHover =>
      isLight ? surface2 : AppColors.actionSecondaryBgHover;
  Color get actionSecondaryFg => isLight ? ink : AppColors.actionSecondaryFg;
  Color get actionTertiaryBg =>
      isLight ? AppColors.actionTertiaryBg : AppColors.actionTertiaryBg;
  Color get actionTertiaryBgHover =>
      isLight ? surface1 : AppColors.actionTertiaryBgHover;
  Color get actionInverseBg =>
      isLight ? inverseCanvas : AppColors.actionInverseBg;
  Color get actionInverseBgHover =>
      isLight ? inverseSurface1 : AppColors.actionInverseBgHover;
  Color get actionInverseFg => isLight ? inverseInk : AppColors.actionInverseFg;
  Color get tagBlue => isLight ? primary : AppColors.tagBlue;
  Color get tagPurple => isLight ? Color(0xFF7040B0) : AppColors.tagPurple;
  Color get tagGreen => isLight ? success : AppColors.tagGreen;
  Color get tagYellow => isLight ? Color(0xFF85620C) : AppColors.tagYellow;
  Color get tagOrange => isLight ? Color(0xFFA64D17) : AppColors.tagOrange;
  Color get tagRed => isLight ? Color(0xFFB02F37) : AppColors.tagRed;
  Color get loginScrimStart =>
      isLight ? canvas.withValues(alpha: 0.5) : AppColors.loginScrimStart;
  Color get loginScrimMid =>
      isLight ? canvas.withValues(alpha: 0.72) : AppColors.loginScrimMid;
  Color get welcomeScrim =>
      isLight ? canvas.withValues(alpha: 0.42) : AppColors.welcomeScrim;
  Color get onboardingScrim =>
      isLight ? canvas.withValues(alpha: 0.18) : AppColors.onboardingScrim;
  Color get onboardingChrome =>
      isLight ? surface2.withValues(alpha: 0.7) : AppColors.onboardingChrome;
  Color get stopDetailHeroScrim =>
      isLight ? surface1.withValues(alpha: 0.8) : AppColors.stopDetailHeroScrim;
}
