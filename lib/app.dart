import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/settings/application/theme_provider.dart';
import 'features/shell/presentation/foundation_preview.dart';

/// Root widget.
///
/// The navigation shell (F-NAV-001/002) replaces [FoundationPreview] as `home`
/// in batch 0.4. Theming is wired now because everything built afterwards
/// depends on it.
class FitnessApp extends ConsumerWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'FitnessApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Applies instantly, no restart (F-SET-002).
      themeMode: ref.watch(themeModeProvider),
      home: const FoundationPreview(),
    );
  }
}
