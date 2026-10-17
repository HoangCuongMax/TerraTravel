import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/models/stop.dart';
import '../../data/repositories/travel_data_client.dart';

import '../../data/models/travel_insight.dart';

class InsightsState {
  const InsightsState({
    this.records = const [],
    this.demo = false,
    this.litres = 40,
    this.carrier = 'Telstra',
    this.error,
    this.loading = false,
    this.online = false,
  });
  final List<TravelInsight> records;
  final bool demo, loading, online;
  final double litres;
  final String carrier;
  final String? error;
}

final travelDataClientProvider = Provider<TravelDataClient>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return TravelDataClient(client);
});

final insightsProvider = NotifierProvider<InsightsNotifier, InsightsState>(
  InsightsNotifier.new,
);

/// Session-only data; no new persistence keys or repository seam.
class InsightsNotifier extends Notifier<InsightsState> {
  @override
  InsightsState build() {
    ref.onDispose(() => _revision++);
    return const InsightsState();
  }

  int _revision = 0;
  void _update({
    List<TravelInsight>? records,
    bool? demo,
    double? litres,
    String? carrier,
    String? error,
    bool? loading,
    bool? online,
  }) {
    state = InsightsState(
      records: records ?? state.records,
      demo: demo ?? state.demo,
      litres: litres ?? state.litres,
      carrier: carrier ?? state.carrier,
      error: error,
      loading: loading ?? state.loading,
      online: online ?? state.online,
    );
  }

  Future<void> loadDemo() async {
    final revision = ++_revision;
    _update(loading: true);
    try {
      final text = await rootBundle.loadString(
        'assets/data/travel_insights_demo.json',
      );
      if (revision != _revision) return;
      _update(
        records: TravelInsight.parseDataset(text),
        demo: true,
        online: false,
        loading: false,
      );
    } catch (_) {
      if (revision == _revision) {
        _update(error: 'Could not load the demo dataset.', loading: false);
      }
    }
  }

  Future<void> loadCollected() async {
    final revision = ++_revision;
    _update(loading: true);
    try {
      final text = await rootBundle.loadString(
        'assets/data/travel_insights_collected.json',
      );
      if (revision != _revision) return;
      _update(
        records: TravelInsight.parseDataset(text),
        demo: false,
        online: false,
        loading: false,
      );
    } catch (_) {
      if (revision == _revision) {
        _update(error: 'Could not load the collected records.', loading: false);
      }
    }
  }

  Future<void> refreshPlaces(List<Stop> stops) async {
    final revision = ++_revision;
    _update(loading: true);
    try {
      final records = await ref
          .read(travelDataClientProvider)
          .findPlaces(stops);
      if (revision != _revision) return;
      _update(records: records, demo: false, online: true, loading: false);
    } catch (error) {
      if (revision != _revision) return;
      _update(
        loading: false,
        error: error is FormatException ? error.message.toString() : 'Could not reach the place service. Check your connection and retry. Previous data is retained.',
      );
    }
  }

  bool importJson(String text) {
    try {
      final records = TravelInsight.parseDataset(text);
      ++_revision;
      _update(records: records, demo: false, loading: false, online: false);
      return true;
    } on FormatException catch (e) {
      _update(error: e.message.toString());
      return false;
    }
  }

  void setDemo(bool value) => _update(demo: value);
  void setCarrier(String value) => _update(carrier: value);
  void setLitres(double value) {
    if (!value.isFinite || value < 1 || value > 200) return;
    _update(litres: value);
  }

  void clear() {
    ++_revision;
    state = const InsightsState();
  }
}
