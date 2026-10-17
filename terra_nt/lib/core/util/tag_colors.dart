// `Color` is a `dart:ui` type, so naming the real return type here keeps every call
// site statically checked without importing the Flutter framework into tier 1.
import 'dart:ui' show Color;

import '../theme/colors.dart';

Color tagColor(String tag, {bool light = false}) {
  final palette = light ? const AppPalette.light() : const AppPalette.dark();
  switch (tag) {
    case 'Nature':
      return palette.tagGreen;
    case 'Culture':
      return palette.tagPurple;
    case 'Adventure':
      return palette.tagOrange;
    case 'Wildlife':
      return palette.tagBlue;
    case 'Relaxation':
      return palette.tagYellow;
    default:
      return palette.inkTertiary;
  }
}
