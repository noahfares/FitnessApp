import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';

/// Stands in for a tab whose features have not been built yet.
///
/// Says plainly what will live here and when, rather than showing an empty
/// screen that reads as broken. Each one is deleted by the feature that
/// replaces it.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.arrivesIn,
    required this.description,
    super.key,
  });

  final String title;
  final String arrivesIn;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Arrives in $arrivesIn',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Home tab for Phase 0.
///
/// The real dashboard is `F-NAV-004` in Phase 1. This exists so the shell has a
/// root, and so Settings is reachable — it is reached from Home by design
/// rather than owning a tab.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitnessApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Phase 0 complete', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Shell, routing, theming and units are in place.\n'
                'Logging arrives in Phase 1.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              // The catalogue's only entry point until the exercise picker
              // arrives with F-LOG-002.
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.exercises),
                icon: const Icon(Icons.fitness_center),
                label: const Text('Exercises'),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton.tonalIcon(
                onPressed: () => context.push(AppRoutes.settings),
                icon: const Icon(Icons.tune),
                label: const Text('Units and appearance'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown for a URI that matches nothing — a mistyped deep link, or one from an
/// older version whose route has since moved.
class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({required this.uri, super.key});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nothing lives at\n$uri',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
