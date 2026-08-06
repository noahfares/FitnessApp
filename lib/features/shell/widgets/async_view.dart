import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';

/// Consistent loading presentation (`F-NAV-006`), so every screen's spinner
/// looks and centres the same way instead of each one rebuilding it.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator.adaptive());
}

/// Consistent error presentation (`F-NAV-006`).
///
/// **Never a raw exception** — [message] is written for the person looking at
/// it, not `e.toString()`. Screens with something more specific to say pass
/// their own [title] and [message]; the defaults are the honest fallback for
/// a stream failure nobody anticipated.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'Try again in a moment.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The `loading` / `error` / `data` triad every stream-backed screen renders,
/// with the first two standardised so only `data` varies at the call site.
extension AsyncValueView<T> on AsyncValue<T> {
  Widget view(
    Widget Function(T data) data, {
    String errorTitle = 'Something went wrong',
    String errorMessage = 'Try again in a moment.',
  }) => when(
    data: data,
    loading: () => const LoadingView(),
    error: (error, stackTrace) =>
        ErrorView(title: errorTitle, message: errorMessage),
  );
}
