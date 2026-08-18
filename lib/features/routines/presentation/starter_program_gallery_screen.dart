import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/db/database_provider.dart';
import '../../../domain/routines/starter_programs.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../../core/l10n/l10n.dart';

/// Browsable gallery of the built-in starter programs (`F-ROU-015`) —
/// reached from the routine list's empty state so a fresh install has
/// something usable before the user has written a routine of their own.
/// Importing always copies; nothing here stays linked to the template
/// afterwards (see `RoutineRepository.importStarterProgram`).
class StarterProgramGalleryScreen extends StatelessWidget {
  const StarterProgramGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.routinesStarterPrograms)),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screen),
        itemCount: starterPrograms.length,
        itemBuilder: (context, i) =>
            _StarterProgramCard(program: starterPrograms[i]),
      ),
    );
  }
}

class _StarterProgramCard extends ConsumerWidget {
  const _StarterProgramCard({required this.program});

  final StarterProgram program;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(program.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(program.summary, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${context.l10n.routinesProgramDayCount(program.days.length)}'
              ' · ${program.days.map((d) => d.name).join(' · ')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: () => launchUrl(
                Uri.parse(program.attributionUrl),
                mode: LaunchMode.externalApplication,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      program.attribution,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: () => unawaited(_import(context, ref)),
                child: Text(context.l10n.routinesAddToMyRoutines),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmSheet(
      context,
      title: context.l10n.routinesAddProgramTitle(program.name),
      message: context.l10n.routinesImportProgramExplainer(program.days.length),
      confirmLabel: context.l10n.routinesAdd,
      isDestructive: false,
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    final result = await ref
        .read(routineRepositoryProvider)
        .importStarterProgram(program);
    if (!context.mounted) return;

    if (result.skippedExternalIds.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.routinesProgramSkipped(
              result.skippedExternalIds.length,
            ),
          ),
        ),
      );
    }
    unawaited(context.push(AppRoutes.routine(result.routineId)));
  }
}
