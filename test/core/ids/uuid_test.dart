import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/ids/uuid.dart';

void main() {
  final canonical = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  test('is a canonical version-4 UUID', () {
    // The shape matters beyond tidiness: export/import round-trips these as
    // strings (F-DAT-001), and a malformed id is only discovered on restore.
    expect(newUuidV4(), matches(canonical));
  });

  test('does not repeat', () {
    final ids = {for (var i = 0; i < 5000; i++) newUuidV4()};
    expect(ids, hasLength(5000));
  });
}
