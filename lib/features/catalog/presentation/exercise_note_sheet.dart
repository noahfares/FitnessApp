import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/db/database_provider.dart';
import '../../../core/l10n/l10n.dart';

/// The exercise's own persistent sticky note (`F-CAT-007`) — seat height,
/// pin position, grip width. Distinct from a session's own per-exercise note
/// (`set_note_sheet.dart`'s per-*set* counterpart is `F-LOG-023`): this one
/// outlives every session it's used in.
Future<void> showExerciseNoteSheet(
  BuildContext context, {
  required String exerciseId,
  required String? currentNote,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: MediaQuery.viewInsetsOf(context),
      child: ExerciseNoteSheet(
        exerciseId: exerciseId,
        currentNote: currentNote,
      ),
    ),
  );
}

/// Reachable from the active workout without leaving it (`F-CAT-007` §3) —
/// this writes only through `ExerciseRepository`, so it can never touch a
/// logged set or the rest timer (`F-CAT-007` acceptance).
class ExerciseNoteSheet extends ConsumerStatefulWidget {
  const ExerciseNoteSheet({
    super.key,
    required this.exerciseId,
    required this.currentNote,
  });

  final String exerciseId;
  final String? currentNote;

  @override
  ConsumerState<ExerciseNoteSheet> createState() => _ExerciseNoteSheetState();
}

class _ExerciseNoteSheetState extends ConsumerState<ExerciseNoteSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.currentNote ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref
        .read(exerciseRepositoryProvider)
        .setNotes(widget.exerciseId, _controller.text);
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
            Text(
              context.l10n.catalogExerciseNote,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: context.l10n.catalogSeatHeight4PinPosition,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.catalogCancel),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: _save,
                  child: Text(context.l10n.catalogSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
