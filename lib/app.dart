import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/application/theme_provider.dart';
import 'features/shell/widgets/app_lock_gate.dart';

/// Root widget.
class FitnessApp extends ConsumerWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicColorEnabled = ref.watch(dynamicColorEnabledProvider);

    // `DynamicColorBuilder` queries the platform once and rebuilds when the
    // wallpaper changes; both schemes come back null on any platform or OS
    // version `dynamic_color` doesn't support, which is exactly the "off"
    // state the toggle already defaults to (`F-THM-003`).
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          title: 'FitnessApp',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(
            dynamicScheme: dynamicColorEnabled ? lightDynamic : null,
          ),
          darkTheme: AppTheme.dark(
            dynamicScheme: dynamicColorEnabled ? darkDynamic : null,
          ),
          // Applies instantly, no restart (F-SET-002).
          themeMode: ref.watch(themeModeProvider),
          routerConfig: ref.watch(routerProvider),
          // A no-op when no PIN is configured (`F-SET-010`) — see
          // `AppLockGate`'s own doc.
          builder: (context, child) => AppLockGate(child: child!),
        );
      },
    );
  }
}
