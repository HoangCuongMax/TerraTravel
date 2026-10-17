import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/metrics.dart';
import '../../core/theme/motion.dart';
import '../../core/util/route_sampler.dart';
import 'car_glyph.dart';
import 'dashed_route_polyline.dart';
import 'map_markers.dart';
import 'road_route_loader.dart';
import 'terra_map.dart';

/// A non-interactive map with a car that travels along the NT road route.
class RouteCarBackdrop extends StatefulWidget {
  static const ambientStartDelay = AppMotion.mapAmbientStartDelay;
  static const ambientPause = AppMotion.mapAmbientPause;
  static const travelBaseDurationMs = AppMotion.mapTravelBaseMilliseconds;
  static const travelSpanDurationMs = AppMotion.mapTravelSpanMilliseconds;

  static const List<List<double>> routeCoordinates = <List<double>>[
    <double>[-12.4634, 130.8456],
    <double>[-13.1830, 130.6805],
    <double>[-12.6692, 132.8352],
    <double>[-14.3103, 132.4204],
    <double>[-23.6980, 133.8807],
    <double>[-24.2634, 131.5567],
    <double>[-25.3444, 131.0369],
  ];

  const RouteCarBackdrop.ambient({
    super.key,
    this.coordinates = routeCoordinates,
    this.roadRouteLoader,
  });

  final List<List<double>> coordinates;
  final RoadRouteLoader? roadRouteLoader;

  @override
  RouteCarBackdropState createState() => RouteCarBackdropState();
}

class RouteCarBackdropState extends State<RouteCarBackdrop>
    with SingleTickerProviderStateMixin {
  static const _minimumFraction = 0.0;
  static const _maximumFraction = 1.0;
  static const _easeOutCubic = _EaseOutCubic();

  late final AnimationController _travelController;
  Timer? _ambientTimer;

  /// Notified once per travel tick, so only the map's marker layer rebuilds.
  /// `setState` here would rebuild [TerraMap] and with it the tile layer.
  final _carTick = _CarTicker();

  double _fraction = _minimumFraction;
  late List<List<double>> _routeCoordinates;
  late List<double> _routeDistances;
  double _longitudeDelta = _minimumFraction;
  double _headingRadians = _minimumFraction;

  LatLng get currentPosition {
    final sample = pointAtFraction(
      _routeCoordinates,
      _fraction,
      cumulative: _routeDistances,
    );
    return LatLng(sample.first, sample.last);
  }

  double get currentFraction => _fraction;

  @override
  void initState() {
    super.initState();
    assert(widget.coordinates.length >= 2);
    _routeCoordinates = widget.coordinates;
    _routeDistances = cumulativeDistances(_routeCoordinates);
    _travelController = AnimationController(vsync: this)
      ..addListener(_advanceTravel)
      ..addStatusListener(_completeTravel);
    _updateCarDirection(_minimumFraction, forward: true);
    _ambientTimer = Timer(
      RouteCarBackdrop.ambientStartDelay,
      _startAmbientLoop,
    );
    if (widget.roadRouteLoader case final loader?) {
      unawaited(_loadRoadGeometry(loader));
    }
  }

  Future<void> _loadRoadGeometry(RoadRouteLoader loader) async {
    final road = await loader(widget.coordinates);
    if (!mounted || road == null || road.length < 2) return;

    _ambientTimer?.cancel();
    _travelController.stop();
    setState(() {
      _routeCoordinates = road;
      _routeDistances = cumulativeDistances(road);
      _fraction = _minimumFraction;
      _updateCarDirection(_minimumFraction, forward: true);
    });
    _ambientTimer = Timer(RouteCarBackdrop.ambientPause, _startAmbientLoop);
  }

  void _startAmbientLoop() => _animateTo(_maximumFraction);

  void _animateTo(double requestedTarget) {
    _ambientTimer?.cancel();
    final target = requestedTarget
        .clamp(_minimumFraction, _maximumFraction)
        .toDouble();
    final start = _fraction;
    final span = (target - start).abs();
    final durationMilliseconds =
        RouteCarBackdrop.travelBaseDurationMs +
        span * RouteCarBackdrop.travelSpanDurationMs;

    _travelController
      ..stop()
      ..duration = Duration(milliseconds: durationMilliseconds.round());
    _travelStart = start;
    _travelTarget = target;
    _travelController.forward(from: _minimumFraction);
  }

  double _travelStart = _minimumFraction;
  double _travelTarget = _minimumFraction;

  void _advanceTravel() {
    final easedProgress = _easeOutCubic.transform(_travelController.value);
    final fraction =
        _travelStart + (_travelTarget - _travelStart) * easedProgress;
    final sample = pointAtFraction(
      _routeCoordinates,
      fraction,
      cumulative: _routeDistances,
    );
    if (!mounted) return;
    _fraction = fraction;
    _updateCarDirection(
      fraction,
      forward: _travelTarget >= _travelStart,
      position: sample,
    );
    _carTick.tick();
  }

  void _updateCarDirection(
    double fraction, {
    required bool forward,
    List<double>? position,
  }) {
    final current =
        position ??
        pointAtFraction(
          _routeCoordinates,
          fraction,
          cumulative: _routeDistances,
        );
    const lookAhead = 0.00015;
    var targetFraction = (fraction + (forward ? lookAhead : -lookAhead))
        .clamp(_minimumFraction, _maximumFraction)
        .toDouble();
    if (targetFraction == fraction) {
      targetFraction = (fraction + (forward ? -lookAhead : lookAhead))
          .clamp(_minimumFraction, _maximumFraction)
          .toDouble();
    }
    final next = pointAtFraction(
      _routeCoordinates,
      targetFraction,
      cumulative: _routeDistances,
    );
    final dx = next.last - current.last;
    final deltaLat = next.first - current.first;
    // Web Mercator stretches north/south by sec(latitude). This converts the
    // route tangent into the direction the marker moves on the map.
    final dy = -deltaLat / math.cos(current.first * math.pi / 180);
    if (dx.abs() + dy.abs() < 1e-12) return;
    _longitudeDelta = dx;
    final horizontalFacing = dx < 0 ? -1.0 : 1.0;
    _headingRadians = math.atan2(dy * horizontalFacing, dx.abs());
  }

  void _completeTravel(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    final nextTarget = _travelTarget == _maximumFraction
        ? _minimumFraction
        : _maximumFraction;
    _ambientTimer = Timer(
      RouteCarBackdrop.ambientPause,
      () => _animateTo(nextTarget),
    );
  }

  @override
  void dispose() {
    _ambientTimer?.cancel();
    _travelController
      ..removeListener(_advanceTravel)
      ..removeStatusListener(_completeTravel)
      ..dispose();
    _carTick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final points = _routeCoordinates
        .map((point) => LatLng(point.first, point.last))
        .toList(growable: false);
    return SizedBox.expand(
      child: TerraMap(
        interactive: false,
        bounds: LatLngBounds.fromPoints(points),
        fitPadding: TerraMap.backdropFitPadding,
        polylines: [DashedRoutePolyline.backdrop(points: points)],
        animatedMarkers: (
          listenable: _carTick,
          build: () => [
            ...points.map(
              (point) =>
                  TerraMapMarker(point: point, child: const RouteDotMarker()),
            ),
            TerraMapMarker(
              key: const ValueKey('route-car-marker'),
              point: currentPosition,
              width: AppMetrics.mapCarMarkerWidth,
              height: AppMetrics.mapCarMarkerHeight,
              child: CarGlyph(
                longitudeDelta: _longitudeDelta,
                headingRadians: _headingRadians,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Exposes [ChangeNotifier.notifyListeners], which is protected, to the state
/// that owns the ticker.
class _CarTicker extends ChangeNotifier {
  void tick() => notifyListeners();
}

class _EaseOutCubic extends Curve {
  const _EaseOutCubic();

  @override
  double transformInternal(double t) => 1 - math.pow(1 - t, 3).toDouble();
}
