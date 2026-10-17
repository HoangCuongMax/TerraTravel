import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terra_nt/core/theme/app_theme.dart';
import 'package:terra_nt/core/theme/colors.dart';
import 'package:terra_nt/core/theme/theme_notifier.dart';
import 'package:terra_nt/core/util/tag_colors.dart';
import 'package:terra_nt/features/profile/profile_screen.dart';
import 'package:terra_nt/features/insights/trip_insights_screen.dart';
import 'package:terra_nt/features/auth/login_screen.dart';
import 'package:terra_nt/shared/map/terra_map.dart';
import 'package:terra_nt/shared/widgets/settings_row.dart';

class _ThemeHarness extends ConsumerWidget {
  const _ThemeHarness();
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ref.watch(themeModeProvider),
    home: const ProfileScreen(),
  );
}

double contrast(Color a, Color b) {
  final l1 = a.computeLuminance(), l2 = b.computeLuminance();
  return ((l1 > l2 ? l1 : l2) + 0.05) / ((l1 > l2 ? l2 : l1) + 0.05);
}

void main() {
  test('light semantic text, links, tags and primary action are readable', () {
    const p = AppPalette.light();
    for (final bg in [p.canvas, p.surface1, p.surface2]) {
      for (final ink in [
        p.ink,
        p.inkMuted,
        p.inkSubtle,
        p.inkTertiary,
        p.primary,
      ]) {
        expect(contrast(ink, bg), greaterThanOrEqualTo(4.5));
      }
    }
    expect(contrast(p.onPrimary, p.primary), greaterThanOrEqualTo(4.5));
    for (final tag in [
      'Nature',
      'Culture',
      'Adventure',
      'Wildlife',
      'Relaxation',
    ]) {
      expect(
        contrast(tagColor(tag, light: true), p.surface1),
        greaterThanOrEqualTo(4.5),
      );
    }
    expect(tagColor('Unknown', light: true), p.inkTertiary);
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.scaffoldBackgroundColor, AppColors.canvas);
    expect(openFreeMapStyleFor(Brightness.light), openFreeMapLightStyleUrl);
    expect(openFreeMapStyleFor(Brightness.dark), openFreeMapStyleUrl);
  });

  test(
    'theme state is app-wide, defaults to light, and resets in a new session',
    () {
      final first = ProviderContainer();
      final second = ProviderContainer();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      expect(first.read(themeModeProvider), ThemeMode.light);
      first.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
      expect(first.read(themeModeProvider), ThemeMode.dark);
      expect(second.read(themeModeProvider), ThemeMode.light);
    },
  );

  testWidgets(
    'Profile selector changes the app theme without resetting its state',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: _ThemeHarness()));
      await tester.ensureVisible(
        find.byKey(const ValueKey('profile-appearance')),
      );
      await tester.tap(find.byType(DropdownButton<ThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(ProfileScreen))).brightness,
        Brightness.dark,
      );
      await tester.tap(find.byType(DropdownButton<ThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Light').last);
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(ProfileScreen));
      expect(Theme.of(context).brightness, Brightness.light);
      final container = ProviderScope.containerOf(context);
      expect(container.read(themeModeProvider), ThemeMode.light);
      final row = tester.widget<SettingsRow>(
        find.byKey(const ValueKey('profile-offline-maps')),
      );
      expect(row.label, 'Offline maps');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('system appearance responds to platform brightness', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(themeModeProvider.notifier).setMode(ThemeMode.system);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _ThemeHarness(),
      ),
    );
    expect(
      Theme.of(tester.element(find.byType(ProfileScreen))).brightness,
      Brightness.light,
    );
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(ProfileScreen))).brightness,
      Brightness.dark,
    );
  });

  testWidgets(
    'light Profile, Login and Trip insights fit narrow scaled screens',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final screen in <Widget>[
        const ProfileScreen(),
        const LoginScreen(),
        const TripInsightsScreen(),
      ]) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.5)),
                child: child!,
              ),
              home: screen,
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    },
  );
}
