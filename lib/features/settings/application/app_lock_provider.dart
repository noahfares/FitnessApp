import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/pin_hasher.dart';
import 'unit_preferences_provider.dart';

/// Whether an app-lock PIN is configured — the "off by default" state every
/// caller needs to check before ever showing a lock screen (`F-SET-010`).
final hasAppLockProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString(_hashKey) != null;
});

const _hashKey = 'security.pinHash';
const _saltKey = 'security.pinSalt';

/// Sets, verifies and clears the app-lock PIN (`F-SET-010`).
///
/// Scalar setting, [SharedPreferences] rather than the database, same
/// reasoning as every other `F-SET-*` preference. Only the salted hash is
/// ever stored (`PinHasher`) — never the PIN itself.
class AppLockNotifier {
  AppLockNotifier(this._ref);

  final Ref _ref;

  Future<void> setPin(String pin) async {
    final salt = PinHasher.generateSalt();
    final hash = PinHasher.hash(pin, salt);
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setString(_saltKey, salt);
    await prefs.setString(_hashKey, hash);
    _ref.invalidate(hasAppLockProvider);
  }

  Future<void> clearPin() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.remove(_saltKey);
    await prefs.remove(_hashKey);
    _ref.invalidate(hasAppLockProvider);
  }

  bool verify(String pin) {
    final prefs = _ref.read(sharedPreferencesProvider);
    final salt = prefs.getString(_saltKey);
    final hash = prefs.getString(_hashKey);
    if (salt == null || hash == null) return true;
    return PinHasher.verify(pin, salt, hash);
  }
}

final appLockNotifierProvider = Provider<AppLockNotifier>(
  (ref) => AppLockNotifier(ref),
);
