/// Minimal RFC 4180 CSV encoding — one field quoted only if it needs it, `\r\n`
/// line endings. No dependency for what this is: escape commas/quotes/
/// newlines, join with commas, done.
String csvRow(List<Object?> fields) => fields.map(_csvField).join(',');

String csvDocument(List<String> header, Iterable<List<Object?>> rows) {
  final buffer = StringBuffer(csvRow(header))..write('\r\n');
  for (final row in rows) {
    buffer
      ..write(csvRow(row))
      ..write('\r\n');
  }
  return buffer.toString();
}

String _csvField(Object? value) {
  if (value == null) return '';
  final text = value.toString();
  if (text.contains(RegExp(r'[,"\r\n]'))) {
    return '"${text.replaceAll('"', '""')}"';
  }
  return text;
}
