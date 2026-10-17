import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Fetches road-following geometry from the public OSRM demo service.
///
/// Results are only visual route geometry; OSRM's public demo has no uptime or
/// traffic/closure guarantees. Callers keep their supplied stop coordinates as
/// a graceful fallback when the service is unavailable.
typedef RoadRouteLoader = Future<List<List<double>>?> Function(
  List<List<double>> stops,
);

abstract final class RoadRouteGeometry {
  static const _host = 'router.project-osrm.org';
  static const _timeout = Duration(seconds: 8);
  static const _maxCachedRoutes = 8;
  static const _minimumRequestInterval = Duration(seconds: 1);

  static final Map<String, List<List<double>>> _cache = {};
  static DateTime? _lastRequestAt;
  static Future<void> _requestQueue = Future<void>.value();

  static Future<List<List<double>>?> load(List<List<double>> stops) async {
    if (stops.length < 2 || stops.any((point) => point.length < 2)) {
      return null;
    }

    final key = stops
        .map(
          (point) =>
              '${point[1].toStringAsFixed(5)},${point[0].toStringAsFixed(5)}',
        )
        .join(';');
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
      return cached;
    }

    await _waitForRequestSlot();
    try {
      final coordinates = stops
          .map((point) => '${point[1]},${point[0]}')
          .join(';');
      final uri = Uri.https(_host, '/route/v1/driving/$coordinates', const {
        'overview': 'simplified',
        'geometries': 'geojson',
        'steps': 'false',
      });
      final response = await http
          .get(
            uri,
            headers: const {
              'User-Agent': 'TerraNT/1.0 (Charles Darwin University demo)',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['code'] != 'Ok') {
        return null;
      }
      final routes = decoded['routes'];
      if (routes is! List || routes.isEmpty || routes.first is! Map) {
        return null;
      }
      final geometry = (routes.first as Map)['geometry'];
      if (geometry is! Map || geometry['coordinates'] is! List) return null;

      final points = <List<double>>[];
      for (final coordinate in geometry['coordinates'] as List) {
        if (coordinate is! List || coordinate.length < 2) continue;
        final longitude = (coordinate[0] as num?)?.toDouble();
        final latitude = (coordinate[1] as num?)?.toDouble();
        if (latitude == null ||
            longitude == null ||
            !latitude.isFinite ||
            !longitude.isFinite ||
            latitude < -90 ||
            latitude > 90 ||
            longitude < -180 ||
            longitude > 180) {
          continue;
        }
        points.add([latitude, longitude]);
      }
      if (points.length < 2) return null;

      final immutable = List<List<double>>.unmodifiable(
        points.map(List<double>.unmodifiable),
      );
      _cache[key] = immutable;
      if (_cache.length > _maxCachedRoutes) _cache.remove(_cache.keys.first);
      return immutable;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _waitForRequestSlot() async {
    final previous = _requestQueue;
    final slot = Completer<void>();
    _requestQueue = slot.future;
    await previous;
    try {
      final last = _lastRequestAt;
      if (last != null) {
        final remaining =
            _minimumRequestInterval - DateTime.now().difference(last);
        if (remaining > Duration.zero) await Future<void>.delayed(remaining);
      }
      _lastRequestAt = DateTime.now();
    } finally {
      slot.complete();
    }
  }
}
