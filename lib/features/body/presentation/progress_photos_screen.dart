import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../shell/widgets/confirm_sheet.dart';
import '../../shell/widgets/empty_state.dart';

/// Date-tagged progress photos, grid plus side-by-side compare (`F-BOD-004`
/// §2). Photos never leave the device — no share, no export button here —
/// and the file itself is excluded from JSON backups by construction (the
/// export dumps DB tables only); see `ProgressPhotoRepository`'s own doc for
/// the full reasoning.
class ProgressPhotosScreen extends ConsumerStatefulWidget {
  const ProgressPhotosScreen({super.key});

  @override
  ConsumerState<ProgressPhotosScreen> createState() =>
      _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState extends ConsumerState<ProgressPhotosScreen> {
  final Set<String> _selectedForCompare = {};
  bool _compareMode = false;

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(_progressPhotosStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress photos'),
        actions: [
          IconButton(
            tooltip: _compareMode ? 'Cancel compare' : 'Compare two photos',
            icon: Icon(_compareMode ? Icons.close : Icons.compare),
            onPressed: () => setState(() {
              _compareMode = !_compareMode;
              _selectedForCompare.clear();
            }),
          ),
        ],
      ),
      body: photosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load photos.')),
        data: (photos) {
          if (photos.isEmpty) {
            return const EmptyState(
              icon: Icons.photo_camera_outlined,
              title: 'No progress photos yet',
              message: 'Add one to start a date-tagged record.',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.screen),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              final selected = _selectedForCompare.contains(photo.id);
              return _PhotoTile(
                photo: photo,
                selected: selected,
                onTap: () => _compareMode
                    ? _toggleCompareSelection(photo.id)
                    : unawaited(_openPhoto(photo)),
              );
            },
          );
        },
      ),
      floatingActionButton: _compareMode && _selectedForCompare.length == 2
          ? FloatingActionButton.extended(
              onPressed: () => unawaited(_showComparison()),
              icon: const Icon(Icons.compare),
              label: const Text('Compare'),
            )
          : FloatingActionButton(
              onPressed: _compareMode ? null : () => unawaited(_addPhoto()),
              child: const Icon(Icons.add_a_photo_outlined),
            ),
    );
  }

  void _toggleCompareSelection(String id) {
    setState(() {
      if (_selectedForCompare.contains(id)) {
        _selectedForCompare.remove(id);
      } else if (_selectedForCompare.length < 2) {
        _selectedForCompare.add(id);
      }
    });
  }

  Future<void> _addPhoto() async {
    final picked = await FilePicker.pickFiles(type: FileType.image);
    final path = picked?.files.single.path;
    if (path == null) return;
    await ref.read(progressPhotoRepositoryProvider).addPhoto(File(path));
  }

  Future<void> _openPhoto(ProgressPhoto photo) async {
    final file = await ref
        .read(progressPhotoRepositoryProvider)
        .resolveFile(photo.filePath);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(file),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_dateLabel(photo)),
                  TextButton(
                    onPressed: () => unawaited(_confirmDelete(photo)),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ProgressPhoto photo) async {
    final confirmed = await showConfirmSheet(
      context,
      title: 'Delete this photo?',
      message: 'This permanently removes the photo from this device.',
    );
    if (!confirmed) return;
    await ref.read(progressPhotoRepositoryProvider).deletePhoto(photo.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _showComparison() async {
    final repo = ref.read(progressPhotoRepositoryProvider);
    final photos = await ref.read(_progressPhotosStreamProvider.future);
    final selected = [
      for (final id in _selectedForCompare)
        photos.firstWhere((p) => p.id == id),
    ]..sort((a, b) => a.takenAt.compareTo(b.takenAt));

    final files = [
      for (final p in selected) await repo.resolveFile(p.filePath),
    ];
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < selected.length; i++)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.file(files[i]),
                    Text(_dateLabel(selected[i])),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(ProgressPhoto photo) => DateFormat.yMMMd().format(
    DateTime.fromMillisecondsSinceEpoch(photo.takenAt, isUtc: true),
  );
}

class _PhotoTile extends ConsumerWidget {
  const _PhotoTile({
    required this.photo,
    required this.selected,
    required this.onTap,
  });

  final ProgressPhoto photo;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<File>(
      future: ref
          .read(progressPhotoRepositoryProvider)
          .resolveFile(photo.filePath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: selected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    )
                  : null,
            ),
            child: file == null
                ? const ColoredBox(color: Colors.black12)
                : Image.file(file, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}

final _progressPhotosStreamProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(progressPhotoRepositoryProvider).watchAll(),
);
