import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/security/pin_hasher.dart';

/// Batch 5.4 — `F-SET-010`.
void main() {
  test('verifies the correct PIN against its own hash', () {
    final salt = PinHasher.generateSalt();
    final hash = PinHasher.hash('1234', salt);

    expect(PinHasher.verify('1234', salt, hash), isTrue);
  });

  test('rejects the wrong PIN', () {
    final salt = PinHasher.generateSalt();
    final hash = PinHasher.hash('1234', salt);

    expect(PinHasher.verify('0000', salt, hash), isFalse);
  });

  test('never stores the PIN itself in the hash', () {
    final salt = PinHasher.generateSalt();
    final hash = PinHasher.hash('1234', salt);

    expect(hash, isNot(contains('1234')));
  });

  test('two salts never collide in practice', () {
    final salts = {for (var i = 0; i < 100; i++) PinHasher.generateSalt()};

    expect(salts, hasLength(100));
  });

  test('the same PIN hashes differently under different salts', () {
    final saltA = PinHasher.generateSalt();
    final saltB = PinHasher.generateSalt();

    expect(PinHasher.hash('1234', saltA), isNot(PinHasher.hash('1234', saltB)));
  });
}
