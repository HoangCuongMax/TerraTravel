import 'package:http/http.dart' as http;

import '../../core/util/osm_travel_data.dart';
import '../models/stop.dart';
import '../models/travel_insight.dart';

/// Concrete public-data client, not a third repository interface.
class TravelDataClient {
  TravelDataClient(this.client, {DateTime Function()? now})
    : now = now ?? DateTime.now;
  final http.Client client;
  final DateTime Function() now;
  String? _cachedQuery;
  DateTime? _cachedAt, _lastAttempt;
  List<TravelInsight> _cached = const [];
  Future<List<TravelInsight>> findPlaces(List<Stop> stops) async {
    final query = buildTravelPlacesQuery(stops);
    final time = now().toUtc();
    if (_cachedQuery == query &&
        _cachedAt != null &&
        time.difference(_cachedAt!) < const Duration(minutes: 30)) {
      return _cached;
    }
    if (_lastAttempt != null &&
        time.difference(_lastAttempt!) < const Duration(seconds: 30)) {
      throw const FormatException(
        'Please wait 30 seconds before another place search.',
      );
    }
    _lastAttempt = time;
    final response = await client
        .post(
          Uri.parse('https://overpass-api.de/api/interpreter'),
          headers: const {
            'Accept': 'application/json',
            'User-Agent': 'TerraNT/1.0 (CDU travel planner)',
          },
          body: {'data': query},
        )
        .timeout(const Duration(seconds: 25));
    if (response.statusCode == 429 || response.statusCode == 406) {
      throw const FormatException(
        'The public place service is busy. Wait 30 seconds and retry.',
      );
    }
    if (response.statusCode != 200 || response.bodyBytes.length > 2000000) {
      throw const FormatException(
        'Place information is unavailable. Try again later.',
      );
    }
    final records = parseTravelPlaces(response.body, stops, time);
    _cachedQuery = query;
    _cachedAt = time;
    _cached = records;
    return records;
  }
}
