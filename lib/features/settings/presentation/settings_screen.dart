import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../domain/timing/rest_defaults.dart';
import '../application/rest_timer_settings_provider.dart';
import '../application/theme_provider.dart';
import '../application/unit_preferences_provider.dart';

/// Settings root.
///
/// Reached from Home rather than owning a tab — low-frequency screens would
/// dilute the five slots (docs/23-NAVIGATION.md).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitPreferencesProvider);
    final themeMode = ref.watch(themeModeProvider);
    final restTimer = ref.watch(restTimerSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Units'),
            subtitle: Text(
              '${units.load.symbol} · ${units.length.symbol} · '
              '${units.distance.symbol}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsUnits),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Appearance'),
            subtitle: Text(themeMode.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsAppearance),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Rest timer'),
            subtitle: Text(
              '${restTimer.autoStart ? 'Starts automatically' : 'Manual start'}'
              ' · '
              '${restTimer.defaultSeconds == null ? 'automatic length' : formatRestDuration(restTimer.defaultSeconds!)}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsRestTimer),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_weight_outlined),
            title: const Text('Bodyweight'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.body),
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsData),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.settingsAbout),
          ),
        ],
      ),
    );
  }
}
