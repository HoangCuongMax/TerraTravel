import 'dart:math' as math;

/// Returns cumulative great-circle distances for a polyline of [lat, lng] pairs.
List<double> cumulativeDistances(List<List<double>> points) {
  if (points.isEmpty) {
    return <double>[];
  }

  final cumulative = <double>[0];
  for (var i = 1; i < points.length; i++) {
    cumulative.add(
      cumulative.last + _segmentDistanceMeters(points[i - 1], points[i]),
    );
  }
  return cumulative;
}

/// Samples a point at fraction [fraction] along the full polyline.
List<double> pointAtFraction(
  List<List<double>> points,
  double fraction, {
  List<double>? cumulative,
}) {
  if (points.isEmpty) {
    throw ArgumentError.value(points, 'points', 'must not be empty');
  }
  if (points.length == 1) {
    return List<double>.from(points.first);
  }

  final clampedFraction = fraction.clamp(0.0, 1.0).toDouble();
  final distances = cumulative ?? cumulativeDistances(points);
  final total = distances.last;
  final target = clampedFraction * total;

  for (var i = 1; i < distances.length; i++) {
    if (target <= distances[i]) {
      final previousDistance = distances[i - 1];
      final segmentDistance = distances[i] - previousDistance;
      final segmentFraction = segmentDistance == 0
          ? 0.0
          : (target - previousDistance) / segmentDistance;
      final start = points[i - 1];
      final end = points[i];
      return <double>[
        start[0] + (end[0] - start[0]) * segmentFraction,
        start[1] + (end[1] - start[1]) * segmentFraction,
      ];
    }
  }

  return List<double>.from(points.last);
}

double _segmentDistanceMeters(List<double> a, List<double> b) {
  const earthRadiusMeters = 6371008.8;
  final lat1 = a[0] * math.pi / 180;
  final lat2 = b[0] * math.pi / 180;
  final deltaLat = lat2 - lat1;
  final deltaLng = (b[1] - a[1]) * math.pi / 180;
  final sinLat = math.sin(deltaLat / 2);
  final sinLng = math.sin(deltaLng / 2);
  final haversine =
      sinLat * sinLat + math.cos(lat1) * math.cos(lat2) * sinLng * sinLng;
  return earthRadiusMeters *
      2 *
      math.asin(math.sqrt(haversine.clamp(0.0, 1.0)));
}
