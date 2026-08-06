import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';

/// Per-set note (`F-LOG-023`).
Future<void> showSetNoteSheet(BuildContext context, {required WorkoutSet set}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: MediaQuery.viewInsetsOf(context),
      child: SetNoteSheet(set: set),
    ),
  );
}

/// A small sheet, opened from an icon on the row — never a field in the row
/// itself (`F-LOG-023` §2).
///
/// This is the one place the system keyboard is right: it is free text, not a
/// number, and it is typed between sets rather than during one.
class SetNoteSheet extends ConsumerStatefulWidget {
  const SetNoteSheet({super.key, required this.set});

  final WorkoutSet set;

  @override
  ConsumerState<SetNoteSheet> createState() => _SetNoteSheetState();
}

class _SetNoteSheetState extends ConsumerState<SetNoteSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.set.notes ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref
        .read(setRepositoryProvider)
        .setNote(widget.set.id, _controller.text);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Set note', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _controller,
              autofocus: true,
              // The observation exists for about ten seconds after the set and
              // then it is gone, so entry is short and immediate.
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Left shoulder twinged, belt too loose…',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
