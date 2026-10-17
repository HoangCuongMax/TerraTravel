import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terra_nt/core/theme/app_theme.dart';
import 'package:terra_nt/core/util/travel_insights.dart';
import 'package:terra_nt/data/models/travel_insight.dart';
import 'package:terra_nt/features/insights/insights_notifier.dart';
import 'package:terra_nt/features/insights/trip_insights_screen.dart';

void main() {
  final text = File('assets/data/travel_insights_demo.json').readAsStringSync();
  List<TravelInsight> records() => TravelInsight.parseDataset(text);
  test(
    'collected asset preserves historical dates and excludes synthetic claims',
    () {
      final collected = TravelInsight.parseDataset(
        File('assets/data/travel_insights_collected.json').readAsStringSync(),
      );
      expect(collected, hasLength(470));
      expect(collected.where((r) => r.kind == 'fuel'), hasLength(313));
      expect(collected.where((r) => r.kind == 'accommodation'), hasLength(157));
      expect(
        collected.every((r) => !r.demo && r.data['historical'] == true),
        isTrue,
      );
      expect(
        collected.every((r) => !r.isCurrent(DateTime.utc(2026, 10, 17))),
        isTrue,
      );
      expect(collected.every((r) => r.data['rating'] == null), isTrue);
      expect(
        collected.every(
          (r) => r.data['comparison_price_cents_per_litre'] == null,
        ),
        isTrue,
      );
    },
  );
  testWidgets(
    'collected records load locally with historical banner and clear',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const TripInsightsScreen(),
          ),
        ),
      );
      expect(find.text('View collected records'), findsOneWidget);
      await tester.runAsync(
        () => container.read(insightsProvider.notifier).loadCollected(),
      );
      expect(container.read(insightsProvider).error, isNull);
      await tester.pumpAndSettle();
      expect(find.text('Collected records · historical'), findsOneWidget);
      expect(
        find.textContaining('Fuel prices are from December 2024'),
        findsOneWidget,
      );
      expect(find.textContaining('Compared with'), findsNothing);
      await tester.ensureVisible(find.text('Clear data'));
      await tester.tap(find.text('Clear data'));
      await tester.pumpAndSettle();
      expect(find.text('Your data'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  test(
    'fuel calculation preserves savings and extra cost; rejects invalid inputs',
    () {
      expect(fuelSaving(priceCents: 185, comparisonCents: 215, litres: 40), 12);
      expect(
        fuelSaving(priceCents: 215, comparisonCents: 185, litres: 40),
        -12,
      );
      expect(
        () => fuelSaving(
          priceCents: 185,
          comparisonCents: 215,
          litres: double.nan,
        ),
        throwsArgumentError,
      );
    },
  );
  test('exact alias matching, carrier and demo exclusion', () {
    expect(
      insightsForStops(
        records(),
        ['Darwin'],
        includeDemo: false,
        carrier: 'Telstra',
      ),
      isEmpty,
    );
    expect(
      insightsForStops(
        records(),
        [' darwin '],
        includeDemo: true,
        carrier: 'Telstra',
      ),
      hasLength(4),
    );
    expect(
      insightsForStops(
        records(),
        ['Darwin'],
        includeDemo: true,
        carrier: 'Optus',
      ),
      hasLength(3),
    );
    expect(
      insightsForStops(
        records(),
        ['Darwin Waterfront'],
        includeDemo: true,
        carrier: 'Telstra',
      ),
      isEmpty,
    );
  });
  test('freshness rejects expired and future observations', () {
    final row = records().first;
    expect(row.isCurrent(DateTime.utc(2026, 10, 17, 12)), isTrue);
    expect(row.isCurrent(DateTime.utc(2026, 10, 18)), isFalse);
    expect(row.isCurrent(DateTime.utc(2026, 10, 16)), isFalse);
  });
  test('import rejects duplicate IDs, invalid units, timezone and source', () {
    for (final mutation in <void Function(Map<String, dynamic>)>[
      (root) => (root['records'] as List).add((root['records'] as List).first),
      (root) => root['records'][0]['data']['price_cents_per_litre'] = -1,
      (root) => root['records'][0]['observed_at'] = '2026-10-17',
      (root) => root['records'][0]['source_url'] = 'javascript:alert(1)',
      (root) => root['records'][2]['data']['rating'] = 7,
      (root) => root['records'][3]['data']['facilities'] = [true],
    ]) {
      final root = jsonDecode(text) as Map<String, dynamic>;
      mutation(root);
      expect(
        () => TravelInsight.parseDataset(jsonEncode(root)),
        throwsFormatException,
      );
    }
  });
  test('invalid imports preserve previous data; demo opt-in and clear are session-only', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(insightsProvider.notifier);
    expect(notifier.importJson(text), isTrue);
    expect(container.read(insightsProvider).demo, isFalse);
    expect(notifier.importJson('{}'), isFalse);
    expect(container.read(insightsProvider).records, hasLength(4));
    notifier.setDemo(true);
    notifier.setLitres(60);
    expect(container.read(insightsProvider).litres, 60);
    notifier.clear();
    expect(container.read(insightsProvider).records, isEmpty);
    expect(container.read(insightsProvider).error, isNull);
  });
  testWidgets(
    'narrow screen, demo opt-in, import back and controller disposal',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const TripInsightsScreen(),
          ),
        ),
      );
      expect(find.text('Your data'), findsOneWidget);
      await tester.tap(find.text('Preview demo'));
      await tester.pumpAndSettle();
      expect(find.text('Demo preview · fictional data'), findsOneWidget);
      await tester.ensureVisible(find.text('Import JSON'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import JSON'));
      await tester.pumpAndSettle();
      expect(find.text('Dataset JSON'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Trip insights'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('all four demo cards render while scrolling with scaled text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(insightsProvider.notifier).importJson(text);
    container.read(insightsProvider.notifier).setDemo(true);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const TripInsightsScreen(),
        ),
      ),
    );
    for (final title in [
      'Example roadhouse A',
      'Prepare before a limited-coverage leg',
      'Example overnight stay',
      'Example combined rest stop',
    ]) {
      await tester.scrollUntilVisible(find.text(title), 250);
      expect(find.text(title), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('expired real prices are reference only, with no saving claim', (
    tester,
  ) async {
    final root = jsonDecode(text) as Map<String, dynamic>;
    final first = root['records'][0] as Map<String, dynamic>;
    first['data_mode'] = 'real';
    first['observed_at'] = '2000-01-01T00:00:00Z';
    first['expires_at'] = '2000-01-02T00:00:00Z';
    root['records'] = [first];
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(insightsProvider.notifier).importJson(jsonEncode(root));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const TripInsightsScreen(),
        ),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('Expired or future-dated · no current recommendation.'),
      250,
    );
    expect(find.textContaining('Compared with'), findsNothing);
    expect(find.text('Source: Synthetic fixture'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
