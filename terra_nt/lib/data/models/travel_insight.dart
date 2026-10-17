import 'dart:convert';

/// Backend preparation interchange, separate from the saved-route contract.
class TravelInsight {
  const TravelInsight({
    required this.id,
    required this.kind,
    required this.title,
    required this.placeNames,
    required this.details,
    required this.sourceUrl,
    required this.sourceName,
    required this.observedAt,
    required this.expiresAt,
    required this.demo,
    required this.data,
  });
  final String id, kind, title, details, sourceUrl, sourceName;
  final List<String> placeNames;
  final DateTime observedAt, expiresAt;
  final bool demo;
  final Map<String, dynamic> data;

  bool isCurrent(DateTime now) =>
      !observedAt.isAfter(now) && now.isBefore(expiresAt);

  static List<TravelInsight> parseDataset(String text) {
    final root = jsonDecode(text);
    if (root is! Map ||
        root['schema_version'] != '1.0' ||
        root['records'] is! List) {
      throw const FormatException(
        'Expected schema_version 1.0 and a records array.',
      );
    }
    final records = root['records'] as List;
    if (records.length > 500) {
      throw const FormatException('Maximum 500 records.');
    }
    final ids = <String>{};
    final result = <TravelInsight>[];
    for (final value in records) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Invalid record.');
      }
      String field(String key) {
        final v = value[key];
        if (v is! String || v.trim().isEmpty) {
          throw FormatException('Missing $key.');
        }
        return v.trim();
      }

      final id = field('id');
      if (!ids.add(id)) throw FormatException('Duplicate id: $id.');
      final kind = field('kind');
      if (!{'fuel', 'coverage', 'accommodation', 'roadhouse'}.contains(kind)) {
        throw FormatException('Unknown kind: $kind.');
      }
      final names = value['place_names'];
      if (names is! List ||
          names.isEmpty ||
          names.any((n) => n is! String || n.trim().isEmpty)) {
        throw FormatException('$id needs place_names.');
      }
      final mode = field('data_mode');
      if (!{'real', 'synthetic_demo'}.contains(mode)) {
        throw const FormatException('Invalid data_mode.');
      }
      final source = field('source_url');
      final uri = Uri.tryParse(source);
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty) {
        throw const FormatException('Source must be an HTTPS URL.');
      }
      DateTime timestamp(String key) {
        final raw = field(key);
        if (!RegExp(r'(Z|[+-]\d{2}:\d{2})$').hasMatch(raw)) {
          throw FormatException('$key needs a timezone.');
        }
        return DateTime.parse(raw).toUtc();
      }

      final observed = timestamp('observed_at');
      final expires = timestamp('expires_at');
      if (!expires.isAfter(observed)) {
        throw const FormatException('Invalid validity interval.');
      }
      final data = value['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Missing data object.');
      }
      double positive(String key) {
        final n = data[key];
        if (n is! num || !n.isFinite || n <= 0) {
          throw FormatException('Invalid $key.');
        }
        return n.toDouble();
      }

      if (kind == 'fuel') {
        positive('price_cents_per_litre');
        if (data['comparison_price_cents_per_litre'] != null) {
          positive('comparison_price_cents_per_litre');
        }
        if (data['fuel_type'] is! String ||
            (data['fuel_type'] as String).isEmpty) {
          throw const FormatException('Fuel type required.');
        }
      }
      if (kind == 'coverage' &&
          (data['carrier'] is! String || data['basis'] != 'prediction')) {
        throw const FormatException(
          'Coverage requires carrier and prediction basis.',
        );
      }
      if (kind == 'accommodation' && data['rating'] != null) {
        final score = positive('rating');
        final scale = positive('rating_scale_max');
        if (score > scale ||
            data['review_count'] is! int ||
            (data['review_count'] as int) < 0) {
          throw const FormatException('Invalid rating or review count.');
        }
      }
      if (kind == 'roadhouse' &&
          (data['facilities'] is! List ||
              (data['facilities'] as List).any((f) => f is! String))) {
        throw const FormatException('Facilities must be a string array.');
      }
      result.add(
        TravelInsight(
          id: id,
          kind: kind,
          title: field('title'),
          placeNames: List<String>.unmodifiable(names.cast<String>()),
          details: field('details'),
          sourceUrl: source,
          sourceName: field('source_name'),
          observedAt: observed,
          expiresAt: expires,
          demo: mode == 'synthetic_demo',
          data: Map<String, dynamic>.unmodifiable(data),
        ),
      );
    }
    return List<TravelInsight>.unmodifiable(result);
  }
}
