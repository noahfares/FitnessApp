import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../settings/application/app_lock_provider.dart';
import '../../../core/l10n/l10n.dart';

/// Gates the whole app behind a PIN when one is configured (`F-SET-010`).
///
/// A no-op when no PIN is set — the default state, and what every existing
/// widget test that pumps `FitnessApp` directly relies on continuing to
/// work unmodified. Re-locks whenever the app returns from the background,
/// since a PIN that only guards cold start is not much of a gate.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  late bool _locked;

  @override
  void initState() {
    super.initState();
    // Cold start with a PIN configured starts locked — only backgrounding
    // re-locks afterwards; nothing else does.
    _locked = ref.read(hasAppLockProvider);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ref.read(hasAppLockProvider) &&
        !_locked) {
      setState(() => _locked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLock = ref.watch(hasAppLockProvider);
    if (!hasLock || !_locked) return widget.child;
    // `builder`'s child normally carries the app's own Navigator/Overlay;
    // replacing it entirely (rather than pushing a route) means the lock
    // screen has to bring its own Overlay for its TextField to work.
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (_) =>
              _LockScreen(onUnlocked: () => setState(() => _locked = false)),
        ),
      ],
    );
  }
}

class _LockScreen extends ConsumerStatefulWidget {
  const _LockScreen({required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  ConsumerState<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<_LockScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final ok = ref.read(appLockNotifierProvider).verify(_controller.text);
    if (ok) {
      widget.onUnlocked();
      return;
    }
    setState(() {
      _error = context.l10n.shellWrongPin;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.l10n.shellEnterPin,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(errorText: _error),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _submit,
                  child: Text(context.l10n.shellUnlock),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
