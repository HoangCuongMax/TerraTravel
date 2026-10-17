import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_launch.dart';
import 'app/crash_reporting.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'firebase_options.dart';

/// Terra NT — Northern Territory road-trip route planner.
///
/// Task-00 scaffold, Task-01's theme, Task-06's app-launch routing,
/// Task-23's Firebase initialisation (phase 2, `docs/PRD.md` D12) and
/// Task-29's Crashlytics wiring (`docs/PRD.md` D13).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  installCrashReporting(
    recordFlutterFatalError:
        FirebaseCrashlytics.instance.recordFlutterFatalError,
    recordFatalError: (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
  runApp(const ProviderScope(child: TerraNtApp()));
}

class TerraNtApp extends ConsumerWidget {
  const TerraNtApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Terra NT',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value:
            (Theme.of(context).brightness == Brightness.light
                    ? SystemUiOverlayStyle.dark
                    : SystemUiOverlayStyle.light)
                .copyWith(
                  systemNavigationBarColor: Theme.of(context)
                      .scaffoldBackgroundColor,
                ),
        child: child!,
      ),
      home: const AppLaunch(),
    );
  }
}
