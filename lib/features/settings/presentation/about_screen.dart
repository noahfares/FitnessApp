import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Settings › About (`F-SET-009`, partial).
///
/// The version shown here is the only diagnostic context this app will ever
/// have: there is no crash reporting and no telemetry (ADR-0002), so a bug
/// report can only name a build if this screen tells the user which one they
/// are on.
///
/// Licences and the repository link land with the rest of `F-SET-009` in
/// Phase 1; this is the shell for it.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  /// Kept in step with `VERSION` and `pubspec.yaml` by CI.
  ///
  /// Read from the package at runtime once `F-REL-005` wires the build number
  /// through; a constant is honest for now and cheaper than a plugin.
  static const String version = '0.14.0';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        children: [
          const ListTile(title: Text('Version'), subtitle: Text(version)),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Privacy', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No account. No server. No telemetry. This app makes no '
                  'network calls at all, and your training data never leaves '
                  'the device unless you export it yourself.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
