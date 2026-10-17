import 'package:flutter/widgets.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/metrics.dart';
import '../../shared/map/road_route_loader.dart';
import '../../shared/map/route_car_backdrop.dart';

/// The decorative map and scrim shared by the pre-app authentication screens.
class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({super.key});

  static LinearGradient _scrim(BuildContext context) => LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: const [
      0,
      AppMetrics.loginScrimMidpoint,
      AppMetrics.loginScrimOpaquePoint,
      1,
    ],
    colors: [
      AppColors.of(context).loginScrimStart,
      AppColors.of(context).loginScrimMid,
      AppColors.of(context).canvas,
      AppColors.of(context).canvas,
    ],
  );

  // Laid out at the screen height, which the keyboard does not change, so the
  // map attribution goes behind the keyboard instead of over the links.
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return OverflowBox(
      alignment: Alignment.topCenter,
      minHeight: height,
      maxHeight: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: RouteCarBackdrop.ambient(
              roadRouteLoader: RoadRouteGeometry.load,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: _scrim(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
