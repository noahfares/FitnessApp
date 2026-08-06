/// Random identifiers for rows the user creates.
///
/// Every primary key in the schema is a UUID string rather than an autoincrement
/// integer, so rows created on two devices can never collide (ADR-0008). The
/// seed dataset uses UUIDv5 derived from its `externalId`; user-created rows
/// have no such name to derive from, so they get v4.
///
/// Hand-rolled rather than a `uuid` dependency: this is thirty lines, and the
/// package would be pulled in underneath the whole app for one function.
library;

import 'dart:math';

final Random _random = Random.secure();

/// A random (version 4) UUID in canonical 8-4-4-4-12 form.
///
/// Callers generate the id *before* the insert, so a new row can be rendered
/// optimistically and referenced while the write is still in flight.
String newUuidV4() {
  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));

  // Version 4 in the high nibble of byte 6, RFC 4122 variant in byte 8.
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  final hex = [
    for (final byte in bytes) byte.toRadixString(16).padLeft(2, '0'),
  ].join();

  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
