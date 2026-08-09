import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';

/// Live bars and plates (`F-PLT-002`).
final barsProvider = StreamProvider<List<Bar>>(
  (ref) => ref.watch(plateRepositoryProvider).watchBars(),
);

final platesProvider = StreamProvider<List<Plate>>(
  (ref) => ref.watch(plateRepositoryProvider).watchPlates(),
);
