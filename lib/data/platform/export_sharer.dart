import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Hands an exported file to the system share sheet (`F-DAT-011` §4).
///
/// A seam, the same reasoning as `RestTimerService`: `share_plus` uses a
/// platform channel, which a widget test cannot exercise, so production code
/// depends on this interface rather than the plugin directly
/// (docs/20-ARCHITECTURE.md §cross-platform-discipline).
abstract interface class ExportSharer {
  Future<void> share(File file, {required String subject});

  /// Multiple files in one share sheet action — the CSV export's three
  /// files (`F-DAT-002` §4) shouldn't need three separate share prompts.
  Future<void> shareAll(List<File> files, {required String subject});
}

class SystemExportSharer implements ExportSharer {
  @override
  Future<void> share(File file, {required String subject}) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: subject),
    );
  }

  @override
  Future<void> shareAll(List<File> files, {required String subject}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [for (final f in files) XFile(f.path)],
        subject: subject,
      ),
    );
  }
}

final exportSharerProvider = Provider<ExportSharer>(
  (ref) => SystemExportSharer(),
);
