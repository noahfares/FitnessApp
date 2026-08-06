import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/db/tables/enums.dart';

/// Set type, from a long-press on the set-number cell (`F-LOG-005` §2).
Future<void> showSetTypeSheet(BuildContext context, {required WorkoutSet set}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => SetTypeSheet(set: set),
  );
}

/// Warm-up or working, and nothing else in Phase 1.
///
/// The full enum exists in the schema from v1 — drop, failure, AMRAP and
/// back-off (`F-LOG-005` §1) — because adding an enum value later is a
/// migration and mislabelled history cannot be recovered. Surfacing all six in
/// the logger before there is anywhere to *see* the distinction would be
/// clutter on the most contested screen in the app, so this offers the two that
/// change what every figure means, and the rest arrive with the analytics that
/// read them.
class SetTypeSheet extends ConsumerWidget {
  const SetTypeSheet({super.key, required this.set});

  final WorkoutSet set;

  static const List<SetType> offered = [SetType.warmup, SetType.working];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              AppSpacing.xs,
            ),
            child: Text('Set type', style: theme.textTheme.titleMedium),
          ),
          for (final type in offered)
            ListTile(
              leading: Icon(
                set.setType == type
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(_title(type)),
              subtitle: Text(_subtitle(type)),
              onTap: () async {
                await ref.read(setRepositoryProvider).setType(set.id, type);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  static String _title(SetType type) => switch (type) {
    SetType.warmup => 'Warm-up',
    SetType.working => 'Working',
    SetType.drop => 'Drop set',
    SetType.failure => 'To failure',
    SetType.amrap => 'AMRAP',
    SetType.backoff => 'Back-off',
  };

  static String _subtitle(SetType type) => switch (type) {
    SetType.warmup => 'Numbered W1, W2. Excluded from every figure.',
    _ => 'Counts toward volume and records.',
  };
}
