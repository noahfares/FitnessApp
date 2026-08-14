import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salted SHA-256 hashing for the app lock's PIN (`F-SET-010`).
///
/// **A UI gate, not encryption at rest.** This stops someone picking up the
/// phone and opening the app; it does nothing against someone with the
/// database file itself — nothing in this app encrypts data at rest. The
/// spec's "matters mainly because of progress photos" is about casual
/// access, not a security boundary against extraction.
class PinHasher {
  const PinHasher._();

  /// A fresh random salt for one PIN — regenerated on every `setPin`, never
  /// reused, so two users (or one user resetting) never share a rainbow
  /// table entry.
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String hash(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  static bool verify(String pin, String salt, String expectedHash) {
    return hash(pin, salt) == expectedHash;
  }
}
