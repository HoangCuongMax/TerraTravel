import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/elevation.dart';
import '../../core/theme/radius.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../core/util/travel_insights.dart';
import '../../data/models/travel_insight.dart';
import '../../data/repositories/notifiers.dart';
import 'insights_notifier.dart';

class TripInsightsScreen extends ConsumerWidget {
  const TripInsightsScreen({super.key});

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    // The controller belongs to the route's input lifecycle.
    final text = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const _ImportScreen()));
    if (text != null && context.mounted) {
      ref.read(insightsProvider.notifier).importJson(text);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insightsProvider);
    final notifier = ref.read(insightsProvider.notifier);
    final stops = ref.watch(itineraryNotifierProvider).visibleStops;
    final records = insightsForStops(
      state.records,
      stops.map((s) => s.name),
      includeDemo: state.demo,
      carrier: state.carrier,
    );
    final historical = state.records.any((r) => r.data['historical'] == true);
    return Scaffold(
      backgroundColor: AppColors.of(context).canvas,
      appBar: AppBar(title: const Text('Trip insights')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Make your next stop count',
              style: AppType.cardTitle.copyWith(
                color: AppColors.of(context).ink,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Compare fuel, prepare for limited signal and find useful stops.',
            ),
            const SizedBox(height: AppSpacing.md),
            _Panel(
              children: [
                Text(
                  state.demo
                      ? 'Demo preview · fictional data'
                      : historical
                      ? 'Collected records · historical'
                      : state.online
                      ? 'Online map listings'
                      : 'Your data',
                  style: AppType.body.copyWith(
                    color: AppColors.of(context).primaryHover,
                  ),
                ),
                Text(
                  state.demo
                      ? 'Preview only. Places, prices and ratings are fictional.'
                      : historical
                      ? 'Fuel prices are from December 2024 and accommodation listings from 2020. Unreviewed snapshots, not current recommendations.'
                      : state.online
                      ? '© OpenStreetMap contributors · ODbL. Listings do not confirm current prices, ratings or availability.'
                      : 'Search public map listings or import prepared information.',
                ),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    TextButton(
                      onPressed: state.loading || stops.isEmpty
                          ? null
                          : () => notifier.refreshPlaces(stops),
                      child: const Text('Find stays and roadhouses online'),
                    ),
                    TextButton(
                      onPressed: state.loading ? null : notifier.loadDemo,
                      child: Text(state.loading ? 'Loading…' : 'Preview demo'),
                    ),
                    TextButton(
                      onPressed: state.loading ? null : notifier.loadCollected,
                      child: const Text('View collected records'),
                    ),
                    TextButton(
                      onPressed: () => _import(context, ref),
                      child: const Text('Import JSON'),
                    ),
                    if (state.records.isNotEmpty)
                      TextButton(
                        onPressed: notifier.clear,
                        child: const Text('Clear data'),
                      ),
                  ],
                ),
                if (state.records.any((r) => r.demo))
                  Row(
                    children: [
                      const Expanded(child: Text('Show fictional examples')),
                      Switch(value: state.demo, onChanged: notifier.setDemo),
                    ],
                  ),
                if (state.error != null)
                  Text(
                    state.error!,
                    style: AppType.bodySm.copyWith(
                      color: AppColors.of(context).ink,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _Panel(
              children: [
                const Text('Check current information'),
                const Text(
                  'Place searches cover 5 km around up to the first three active stops. '
                  'Use these free sources for current fuel, coverage and accommodation details.',
                ),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    TextButton(
                      onPressed: () =>
                          _open(context, 'https://myfuelnt.nt.gov.au/'),
                      child: const Text('MyFuel NT prices'),
                    ),
                    TextButton(
                      onPressed: () => _open(
                        context,
                        'https://www.infrastructure.gov.au/media-communications/regional-communications-programs/better-connectivity-plan-regional-and-rural-australia/national-audit-mobile-coverage',
                      ),
                      child: const Text('Official mobile coverage'),
                    ),
                    TextButton(
                      onPressed: () => _open(
                        context,
                        'https://northernterritory.com/plan/accommodation',
                      ),
                      child: const Text('NT accommodation'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _Panel(
              children: [
                const Text('Comparison preferences'),
                Wrap(
                  spacing: AppSpacing.md,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: state.carrier,
                      items: ['Telstra', 'Optus', 'Vodafone']
                          .map(
                            (name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) notifier.setCarrier(value);
                      },
                    ),
                    Text('Refill: ${state.litres.toStringAsFixed(0)} L'),
                    IconButton(
                      tooltip: 'Decrease refill by 5 litres',
                      onPressed: state.litres <= 5
                          ? null
                          : () => notifier.setLitres(state.litres - 5),
                      icon: const Icon(LucideIcons.minus),
                    ),
                    IconButton(
                      tooltip: 'Increase refill by 5 litres',
                      onPressed: state.litres >= 200
                          ? null
                          : () => notifier.setLitres(state.litres + 5),
                      icon: const Icon(LucideIcons.plus),
                    ),
                  ],
                ),
                const Text(
                  'Savings compare equal amounts, before detour costs. Confirm fuel type, range and opening hours.',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (records.isEmpty)
              _Panel(
                children: [
                  const Text('No matching insights yet'),
                  Text(
                    state.records.isEmpty
                        ? 'Import a prepared dataset or preview fictional examples.'
                        : 'No records match your active stop names and selected carrier. Demo records are hidden unless enabled.',
                  ),
                  const Text(
                    'Demo examples match Darwin, Katherine and Alice Springs. '
                    'Unmatched places have unknown coverage and prices.',
                  ),
                ],
              ),
            for (final record in records)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _InsightCard(record: record, litres: state.litres),
              ),
            const Text('Prepare before departure'),
            const Text(
              'Confirm remote services and accommodation directly. Matches are based on itinerary stop names; '
              'road detours are not checked. Imported dates are not independently verified. '
              'Open the map areas you need while connected; viewed-map caching is not complete offline navigation.',
            ),
            TextButton(
              onPressed: () => _open(context, 'https://roadreport.nt.gov.au/'),
              child: const Text('Check official NT road conditions'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.record, required this.litres});
  final TravelInsight record;
  final double litres;
  @override
  Widget build(BuildContext context) {
    final r = record;
    final current = r.isCurrent(DateTime.now().toUtc());
    final price = r.kind == 'fuel'
        ? r.data['price_cents_per_litre'] as num?
        : null;
    final comparison = r.kind == 'fuel'
        ? r.data['comparison_price_cents_per_litre'] as num?
        : null;
    final rating = r.kind == 'accommodation' ? r.data['rating'] as num? : null;
    return _Panel(
      children: [
        Text(
          '${r.demo
              ? 'Fictional example'
              : r.data['historical'] == true
              ? 'Historical snapshot · unverified'
              : r.sourceName.startsWith('OpenStreetMap')
              ? 'Map listing · unverified'
              : 'Imported · unverified'} · ${r.kind}',
          style: AppType.caption.copyWith(
            color: AppColors.of(context).primaryHover,
          ),
        ),
        Text(
          r.title,
          style: AppType.subhead.copyWith(color: AppColors.of(context).ink),
        ),
        Text(
          'Linked stop: ${r.placeNames.join(', ')}',
          style: AppType.caption.copyWith(
            color: AppColors.of(context).inkMuted,
          ),
        ),
        if (price != null)
          Text(
            '${r.data['fuel_type']} · \$${(price / 100).toStringAsFixed(2)}/L',
          ),
        if (price != null &&
            comparison != null &&
            r.data['historical'] != true &&
            (current || r.demo)) ...[
          Text(
            'Compared with \$${(comparison / 100).toStringAsFixed(2)}/L: '
            '${comparison >= price ? 'save' : 'costs an extra'} '
            '\$${fuelSaving(priceCents: price.toDouble(), comparisonCents: comparison.toDouble(), litres: litres).abs().toStringAsFixed(2)} '
            'on ${litres.toStringAsFixed(0)} L before detour costs.',
          ),
          const Text(
            'This comparison does not advise waiting for a later station.',
          ),
        ],
        if (r.kind == 'coverage')
          Text(
            '${r.data['carrier']} · prediction, not measured internet speed',
          ),
        if (rating != null)
          Text(
            '$rating/${r.data['rating_scale_max']} · '
            '${r.data['review_count']} reviews · ${r.sourceName}',
          ),
        if (r.kind == 'accommodation')
          const Text(
            'No live room prices or availability. Contact the operator.',
          ),
        if (r.kind == 'roadhouse')
          Text(
            'Listed facilities: ${(r.data['facilities'] as List).join(', ')}',
          ),
        Text(r.details),
        Text(
          r.demo
              ? 'Synthetic values; never use for travel decisions.'
              : current
              ? 'Within dataset validity; confirm before departure.'
              : 'Expired or future-dated · no current recommendation.',
          style: AppType.bodySm.copyWith(color: AppColors.of(context).inkMuted),
        ),
        Text(
          'Observed: ${r.observedAt.toIso8601String()}\nValid until: ${r.expiresAt.toIso8601String()}',
          style: AppType.caption.copyWith(
            color: AppColors.of(context).inkMuted,
          ),
        ),
        if (!r.demo)
          TextButton(
            onPressed: () => _open(context, r.sourceUrl),
            child: Text('Source: ${r.sourceName}'),
          ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.of(context).surface1,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(
        color: AppColors.of(context).hairline,
        width: AppElevation.hairlineWidth,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final child in children)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: child,
          ),
      ],
    ),
  );
}

Future<void> _open(BuildContext context, String url) async {
  var success = false;
  try {
    success = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    /* Show retry guidance below. */
  }
  if (!success && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not open the source. Check your connection and try again.',
        ),
      ),
    );
  }
}

class _ImportScreen extends StatefulWidget {
  const _ImportScreen();
  @override
  State<_ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<_ImportScreen> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Import insight data')),
    body: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paste the version 1.0 JSON package. This replaces the session dataset. '
              'Invalid data leaves the previous dataset intact. Maximum 500 records.',
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: TextField(
                controller: _controller,
                expands: true,
                minLines: null,
                maxLines: null,
                maxLength: 500000,
                decoration: const InputDecoration(
                  labelText: 'Dataset JSON',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(_controller.text),
              child: const Text('Validate and import'),
            ),
          ],
        ),
      ),
    ),
  );
}
