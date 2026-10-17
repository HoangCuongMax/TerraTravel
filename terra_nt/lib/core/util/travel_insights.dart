import '../../data/models/travel_insight.dart';

String _normalise(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

/// Exact aliases only: nearby names are not proof of a road-corridor match.
List<TravelInsight> insightsForStops(
  List<TravelInsight> records,
  Iterable<String> stopNames, {
  required bool includeDemo,
  required String carrier,
}) {
  final names = stopNames.map(_normalise).toSet();
  return records
      .where(
        (r) =>
            (includeDemo || !r.demo) &&
            r.placeNames.any((n) => names.contains(_normalise(n))) &&
            (r.kind != 'coverage' ||
                _normalise(r.data['carrier'] as String) == _normalise(carrier)),
      )
      .toList();
}

double fuelSaving({
  required double priceCents,
  required double comparisonCents,
  required double litres,
}) {
  if (![
    priceCents,
    comparisonCents,
    litres,
  ].every((v) => v.isFinite && v > 0)) {
    throw ArgumentError('Prices and litres must be finite and positive.');
  }
  return (comparisonCents - priceCents) * litres / 100;
}
