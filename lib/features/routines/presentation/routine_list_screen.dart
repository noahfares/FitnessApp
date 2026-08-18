import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../shell/widgets/async_view.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../shell/widgets/empty_state.dart';
import '../application/routine_providers.dart';
import '../../../core/l10n/l10n.dart';

/// The routine list (`F-ROU-001`) — every program, and where they're created,
/// duplicated, archived, folder-organised and deleted from. Toggles to the
/// archived list, where routines are restored from (`F-ROU-009`).
class RoutineListScreen extends ConsumerWidget {
  const RoutineListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showArchived = ref.watch(routineListShowArchivedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          showArchived ? context.l10n.routinesArchivedRoutines : 'Routines',
        ),
        actions: [
          IconButton(
            icon: Icon(
              showArchived
                  ? Icons.checklist_outlined
                  : Icons.inventory_2_outlined,
            ),
            tooltip: showArchived
                ? context.l10n.routinesActiveRoutines
                : context.l10n.routinesArchivedRoutines,
            onPressed: () =>
                ref.read(routineListShowArchivedProvider.notifier).toggle(),
          ),
          if (!showArchived) ...[
            IconButton(
              icon: const Icon(Icons.library_add_outlined),
              tooltip: context.l10n.routinesStarterPrograms,
              onPressed: () => context.push(AppRoutes.starterPrograms),
            ),
            IconButton(
              icon: const Icon(Icons.create_new_folder_outlined),
              tooltip: context.l10n.routinesNewFolder,
              onPressed: () => unawaited(_createFolder(context, ref)),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: context.l10n.routinesNewRoutine,
              onPressed: () => unawaited(_createRoutine(context, ref)),
            ),
          ],
        ],
      ),
      body: showArchived ? const _ArchivedRoutineList() : const _RoutineList(),
    );
  }

  Future<void> _createRoutine(BuildContext context, WidgetRef ref) async {
    final name = await promptRoutineName(
      context,
      title: context.l10n.routinesNewRoutine,
    );
    if (name == null || name.trim().isEmpty) return;
    final routine = await ref
        .read(routineRepositoryProvider)
        .create(name: name);
    if (!context.mounted) return;
    unawaited(context.push(AppRoutes.routine(routine.id)));
  }

  Future<void> _createFolder(BuildContext context, WidgetRef ref) async {
    final name = await promptRoutineName(
      context,
      title: context.l10n.routinesNewFolder,
    );
    if (name == null || name.trim().isEmpty) return;
    await ref.read(routineRepositoryProvider).createFolder(name);
  }
}

class _RoutineList extends ConsumerWidget {
  const _RoutineList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider);
    final folders = ref.watch(routineFoldersProvider);

    return routines.view(
      errorTitle: context.l10n.routinesRoutinesCouldNotBeRead,
      (rows) {
        if (rows.isEmpty) {
          return EmptyState(
            icon: Icons.checklist_outlined,
            title: context.l10n.loggingNoRoutinesYet,
            message: context.l10n.routinesEmptyStateExplainer,
            actionLabel: context.l10n.routinesBrowseStarterPrograms,
            onAction: () => context.push(AppRoutes.starterPrograms),
          );
        }
        return folders.when(
          data: (folderRows) =>
              _GroupedRoutineList(routines: rows, folders: folderRows),
          loading: () => _GroupedRoutineList(routines: rows, folders: const []),
          error: (_, _) =>
              _GroupedRoutineList(routines: rows, folders: const []),
        );
      },
    );
  }
}

/// Routines grouped under their folder, folders in position order, then
/// everything with no folder last. Skips section headers entirely when
/// nothing has been foldered yet — a flat list is the common case
/// (`F-ROU-007`).
class _GroupedRoutineList extends StatelessWidget {
  const _GroupedRoutineList({required this.routines, required this.folders});

  final List<Routine> routines;
  final List<RoutineFolder> folders;

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screen),
        itemCount: routines.length,
        itemBuilder: (context, i) => _RoutineTile(routine: routines[i]),
      );
    }

    final byFolder = <String?, List<Routine>>{};
    for (final routine in routines) {
      (byFolder[routine.folderId] ??= []).add(routine);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        for (final folder in folders)
          if (byFolder[folder.id] case final inFolder?)
            _FolderSection(folder: folder, routines: inFolder),
        if (byFolder[null] case final unfoldered?)
          _FolderSection(folder: null, routines: unfoldered),
      ],
    );
  }
}

class _FolderSection extends StatelessWidget {
  const _FolderSection({required this.folder, required this.routines});

  final RoutineFolder? folder;
  final List<Routine> routines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Text(
              folder?.name ?? context.l10n.routinesNoFolder,
              style: theme.textTheme.titleSmall,
            ),
          ),
          for (final routine in routines) _RoutineTile(routine: routine),
        ],
      ),
    );
  }
}

class _ArchivedRoutineList extends ConsumerWidget {
  const _ArchivedRoutineList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archived = ref.watch(archivedRoutinesProvider);
    return archived.view(
      errorTitle: context.l10n.routinesArchivedRoutinesCouldNotBe,
      (rows) => rows.isEmpty
          ? EmptyState(
              icon: Icons.inventory_2_outlined,
              title: context.l10n.catalogNothingArchived,
              message: context.l10n.routinesArchivedExplainer,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.screen),
              itemCount: rows.length,
              itemBuilder: (context, i) =>
                  _RoutineTile(routine: rows[i], isArchived: true),
            ),
    );
  }
}

class _RoutineTile extends ConsumerWidget {
  const _RoutineTile({required this.routine, this.isArchived = false});

  final Routine routine;
  final bool isArchived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(routineDaysProvider(routine.id));
    return Card(
      child: ListTile(
        title: Text(routine.name),
        subtitle: days.when(
          data: (rows) => Text(
            rows.isEmpty
                ? context.l10n.routinesNoDaysYet
                : rows.map((d) => d.name).join(' · '),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        trailing: isArchived
            ? IconButton(
                icon: const Icon(Icons.unarchive_outlined),
                tooltip: context.l10n.catalogRestore,
                onPressed: () => unawaited(
                  ref
                      .read(routineRepositoryProvider)
                      .setArchived(routine.id, isArchived: false),
                ),
              )
            : PopupMenuButton<_RoutineAction>(
                onSelected: (action) =>
                    unawaited(_handle(context, ref, action)),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _RoutineAction.moveToFolder,
                    child: Text(context.l10n.routinesMoveToFolder),
                  ),
                  PopupMenuItem(
                    value: _RoutineAction.duplicate,
                    child: Text(context.l10n.routinesDuplicate),
                  ),
                  PopupMenuItem(
                    value: _RoutineAction.archive,
                    child: Text(context.l10n.catalogArchive),
                  ),
                  PopupMenuItem(
                    value: _RoutineAction.delete,
                    child: Text(context.l10n.catalogDelete),
                  ),
                ],
              ),
        onTap: () => context.push(AppRoutes.routine(routine.id)),
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _RoutineAction action,
  ) async {
    final repo = ref.read(routineRepositoryProvider);
    switch (action) {
      case _RoutineAction.moveToFolder:
        await _showMoveToFolderSheet(context, ref);
      case _RoutineAction.duplicate:
        await repo.duplicate(routine.id);
      case _RoutineAction.archive:
        await repo.setArchived(routine.id, isArchived: true);
      case _RoutineAction.delete:
        final confirmed = await showConfirmSheet(
          context,
          title: context.l10n.routinesDeleteRoutineTitle(routine.name),
          message: context.l10n.routinesDeleteRoutineExplainer,
        );
        if (confirmed) await repo.delete(routine.id);
    }
  }

  Future<void> _showMoveToFolderSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final folders = await ref.read(routineFoldersProvider.future);
    if (!context.mounted) return;
    final repo = ref.read(routineRepositoryProvider);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(context.l10n.routinesNoFolder),
              onTap: () {
                unawaited(repo.setFolder(routine.id, null));
                Navigator.of(sheetContext).pop();
              },
            ),
            for (final folder in folders)
              ListTile(
                title: Text(folder.name),
                onTap: () {
                  unawaited(repo.setFolder(routine.id, folder.id));
                  Navigator.of(sheetContext).pop();
                },
              ),
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(context.l10n.routinesNewFolder),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                if (!context.mounted) return;
                final name = await promptRoutineName(
                  context,
                  title: context.l10n.routinesNewFolder,
                );
                if (name == null || name.trim().isEmpty) return;
                final created = await repo.createFolder(name);
                await repo.setFolder(routine.id, created.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

enum _RoutineAction { moveToFolder, duplicate, archive, delete }

/// Shared by every rename/create prompt across routines, days and this list —
/// one dialog, so they read and behave identically.
Future<String?> promptRoutineName(
  BuildContext context, {
  required String title,
  String initial = '',
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: context.l10n.catalogName),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.catalogCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text(context.l10n.catalogSave),
        ),
      ],
    ),
  );
}
