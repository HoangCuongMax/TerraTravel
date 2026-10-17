import 'dart:convert';
import 'dart:math' as math;

import '../../data/models/stop.dart';
import '../../data/models/travel_insight.dart';

const travelSearchRadiusMetres = 5000;
const travelSearchStopLimit = 3;

List<Stop> travelSearchStops(List<Stop> stops) => stops
    .where(
      (s) =>
          s.lat.isFinite &&
          s.lng.isFinite &&
          s.lat >= -26.5 &&
          s.lat <= -10.5 &&
          s.lng >= 128.5 &&
          s.lng <= 138.5,
    )
    .take(travelSearchStopLimit)
    .toList();

String buildTravelPlacesQuery(List<Stop> stops) {
  final areas = travelSearchStops(stops);
  if (areas.isEmpty) {
    throw const FormatException('No valid NT stops to search.');
  }
  final clauses = areas.map((s) {
    final around = 'around:$travelSearchRadiusMetres,${s.lat},${s.lng}';
    return 'nwr($around)[tourism~"^(hotel|motel|guest_house)\$"];'
        'nwr($around)[name~"roadhouse",i];';
  }).join();
  return '[out:json][timeout:20];($clauses);out center 80;';
}

double _distance(double lat, double lng, Stop stop) {
  const radians = math.pi / 180;
  final dlat = (lat - stop.lat) * radians;
  final dlng = (lng - stop.lng) * radians;
  final a =
      math.pow(math.sin(dlat / 2), 2) +
      math.cos(lat * radians) *
          math.cos(stop.lat * radians) *
          math.pow(math.sin(dlng / 2), 2);
  return 6371000 * 2 * math.asin(math.sqrt(a.clamp(0, 1)));
}

List<TravelInsight> parseTravelPlaces(
  String text,
  List<Stop> stops,
  DateTime fetchedAt,
) {
  final root = jsonDecode(text);
  if (root is! Map || root['elements'] is! List || root['remark'] != null) {
    throw const FormatException('Place service returned incomplete data.');
  }
  final areas = travelSearchStops(stops);
  final records = <Map<String, dynamic>>[];
  final ids = <String>{};
  for (final element in (root['elements'] as List).take(80)) {
    if (element is! Map ||
        element['tags'] is! Map ||
        element['id'] is! int ||
        !{'node', 'way', 'relation'}.contains(element['type'])) {
      continue;
    }
    final tags = element['tags'] as Map;
    final name = tags['name'];
    if (name is! String || name.trim().isEmpty) continue;
    final roadhouse = name.toLowerCase().contains('roadhouse');
    if (!roadhouse &&
        !{'hotel', 'motel', 'guest_house'}.contains(tags['tourism'])) {
      continue;
    }
    final centre = element['center'] is Map
        ? element['center'] as Map
        : element;
    final lat = centre['lat'], lng = centre['lon'];
    if (lat is! num || lng is! num || !lat.isFinite || !lng.isFinite) continue;
    Stop? nearest;
    var distance = double.infinity;
    for (final stop in areas) {
      final candidate = _distance(lat.toDouble(), lng.toDouble(), stop);
      if (candidate < distance) {
        distance = candidate;
        nearest = stop;
      }
    }
    if (nearest == null || distance > travelSearchRadiusMetres) continue;
    final id = 'osm-${element['type']}-${element['id']}';
    if (!ids.add(id)) continue;
    final facilities = <String>[
      if (tags['amenity'] == 'fuel') 'Fuel outlet (stock unknown)',
      if (tags['toilets'] == 'yes') 'Toilets',
      if (tags['shower'] == 'yes') 'Shower',
      if (tags['internet_access'] == 'wlan')
        'Wi-Fi listed (performance unknown)',
    ];
    records.add({
      'id': id, 'kind': roadhouse ? 'roadhouse' : 'accommodation',
      'title': name.trim(), 'place_names': [nearest.name],
      'details':
          'Map listing approximately ${(distance / 1000).toStringAsFixed(1)} km from '
          '${nearest.name} in a straight line, not a road detour. Community map data may be outdated. '
          'Opening hours, prices, guest ratings and availability are not verified.',
      'source_url':
          'https://www.openstreetmap.org/${element['type']}/${element['id']}',
      'source_name': 'OpenStreetMap contributors (ODbL)',
      'observed_at': fetchedAt.toUtc().toIso8601String(),
      // This bounds the retrieved snapshot, not the truth of operating details.
      'expires_at': fetchedAt
          .toUtc()
          .add(const Duration(minutes: 30))
          .toIso8601String(),
      'data_mode': 'real',
      'data': roadhouse ? {'facilities': facilities} : <String, dynamic>{},
    });
  }
  return TravelInsight.parseDataset(
    jsonEncode({'schema_version': '1.0', 'records': records}),
  );
}
