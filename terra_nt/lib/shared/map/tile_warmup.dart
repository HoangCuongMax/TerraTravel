import 'package:flutter/material.dart';

import '../../core/theme/spacing.dart';
import '../../data/models/poi.dart';
import 'terra_map.dart';

/// Warms `flutter_map`'s own tile cache while Welcome is on screen, so Explore
/// does not open on empty tiles.
///
/// It mounts the same OpenFreeMap vector map Explore uses — same bounds, fit
/// padding and viewport size — then hides it. The vector layer fetches and
/// caches the visible tiles before Explore opens. Layout, not painting, drives
/// the map camera, so Offstage still lets the map resolve its viewport.
class TileWarmup extends StatelessWidget {
  const TileWarmup({super.key, required this.pois});

  /// The same list Explore fits its camera to; the bounds decide which tiles
  /// load, so warming a different box would warm the wrong tiles.
  final List<Poi> pois;

  @override
  Widget build(BuildContext context) {
    // Explore's map fills the tab shell's body, not the whole screen: below it
    // sit `BottomNav`'s own `AppSpacing.padFooterY` of content and the device's
    // bottom inset. The height has to match, because `flutter_map` picks its
    // tile level with `zoom.round()` — fitting the same bounds into a taller
    // box can round to a different zoom and cache tiles Explore never asks for.
    final screen = MediaQuery.sizeOf(context);
    final shellBodyHeight =
        screen.height -
        AppSpacing.padFooterY -
        MediaQuery.paddingOf(context).bottom;
    // The same formula Explore uses for its own fit padding
    // (`explore_screen.dart`): the Scaffold body's height once the keyboard
    // has resized it. Kept separate from `shellBodyHeight` above, which
    // sizes this offstage box to match the tab shell's real viewport.
    final bodyHeight = screen.height - MediaQuery.viewInsetsOf(context).bottom;
    return Offstage(
      child: SizedBox(
        width: screen.width,
        height: shellBodyHeight,
        child: TerraMap(
          interactive: false,
          bounds: poiBounds(pois),
          fitPadding: TerraMap.exploreFitPaddingFor(
            MediaQuery.paddingOf(context).top,
            bodyHeight,
          ),
        ),
      ),
    );
  }
}
