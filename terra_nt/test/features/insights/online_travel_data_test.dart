import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:terra_nt/core/util/osm_travel_data.dart';
import 'package:terra_nt/data/models/stop.dart';
import 'package:terra_nt/data/repositories/travel_data_client.dart';
import 'package:terra_nt/features/insights/insights_notifier.dart';

const stop = Stop(
  name: 'Darwin',
  subtitle: '',
  lat: -12.4634,
  lng: 130.8456,
  hours: '',
  duration: '',
  aiNote: '',
  tags: [],
  detailedPlan: [],
);
final fetched = DateTime.utc(2026, 10, 17);
Map<String, dynamic> element(
  int id,
  String name, {
  String tourism = 'hotel',
  double lat = -12.4634,
}) => {
  'type': 'node',
  'id': id,
  'lat': lat,
  'lon': 130.8456,
  'tags': {'name': name, 'tourism': tourism, 'stars': '5', 'toilets': 'yes'},
};
String fixture(List<dynamic> elements) => jsonEncode({'elements': elements});

void main() {
  test('query bounds public lookup to three NT anchors and a 5 km radius', () {
    final query = buildTravelPlacesQuery([stop, stop, stop, stop]);
    expect('around:5000'.allMatches(query), hasLength(6));
    expect(query, contains('out center 80'));
    expect(() => buildTravelPlacesQuery([]), throwsFormatException);
  });
  test('hotel stars never become guest ratings; duplicates, far and malformed rows are excluded', () {
    final rows = parseTravelPlaces(
      fixture([
        element(1, 'A hotel'),
        element(1, 'A hotel'),
        element(2, 'Far hotel', lat: -25),
        element(3, 'Example roadhouse', tourism: ''),
        {'id': 4},
      ]),
      [stop],
      fetched,
    );
    expect(rows, hasLength(2));
    expect(rows.first.data['rating'], isNull);
    expect(rows.first.demo, isFalse);
    expect(rows.first.sourceUrl, 'https://www.openstreetmap.org/node/1');
    expect(rows.first.placeNames, ['Darwin']);
    expect(rows.first.details, contains('not a road detour'));
    expect(rows.last.data['facilities'], ['Toilets']);
    expect(
      rows.first.isCurrent(fetched.add(const Duration(minutes: 31))),
      isFalse,
    );
    expect(
      () => parseTravelPlaces('{"elements":[],"remark":"timeout"}', [
        stop,
      ], fetched),
      throwsFormatException,
    );
  });
  test(
    'HTTPS POST succeeds, cache avoids repeated public-service requests',
    () async {
      var calls = 0;
      final mock = MockClient((request) async {
        calls++;
        expect(request.url.scheme, 'https');
        expect(request.url.host, 'overpass-api.de');
        expect(request.method, 'POST');
        expect(request.bodyFields['data'], contains('tourism'));
        return http.Response(fixture([element(1, 'A hotel')]), 200);
      });
      addTearDown(mock.close);
      final client = TravelDataClient(mock, now: () => fetched);
      expect(await client.findPlaces([stop]), hasLength(1));
      expect(await client.findPlaces([stop]), hasLength(1));
      expect(calls, 1);
    },
  );
  test(
    'rate limit backs off and never replaces old data with a fabricated result',
    () async {
      var calls = 0;
      final mock = MockClient((_) async {
        calls++;
        return http.Response('busy', 429);
      });
      addTearDown(mock.close);
      final client = TravelDataClient(mock, now: () => fetched);
      final container = ProviderContainer(
        overrides: [travelDataClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);
      await container.read(insightsProvider.notifier).loadDemo();
      final previous = container.read(insightsProvider).records;
      await container.read(insightsProvider.notifier).refreshPlaces([stop]);
      expect(container.read(insightsProvider).records, same(previous));
      expect(container.read(insightsProvider).error, contains('busy'));
      expect(container.read(insightsProvider).loading, isFalse);
      await expectLater(client.findPlaces([stop]), throwsFormatException);
      expect(calls, 1);
    },
  );
  test('online success is real map data, not demo mode', () async {
    final mock = MockClient(
      (_) async => http.Response(fixture([element(1, 'A hotel')]), 200),
    );
    addTearDown(mock.close);
    final container = ProviderContainer(
      overrides: [
        travelDataClientProvider.overrideWithValue(
          TravelDataClient(mock, now: () => fetched),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(insightsProvider.notifier).refreshPlaces([stop]);
    expect(container.read(insightsProvider).online, isTrue);
    expect(container.read(insightsProvider).demo, isFalse);
    expect(container.read(insightsProvider).records.single.title, 'A hotel');
  });
}
