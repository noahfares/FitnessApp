import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_app/core/units/mass.dart';
import 'package:fitness_app/data/db/app_database.dart';
import 'package:fitness_app/data/repositories/plate_repository.dart';

void main() {
  late AppDatabase db;
  late PlateRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = PlateRepository(
      db,
      clock: () => DateTime.fromMillisecondsSinceEpoch(5000),
    );
  });
  tearDown(() => db.close());

  group('bars and plates (F-PLT-002)', () {
    test('a new bar is immediately readable', () async {
      final id = await repo.createBar(
        id: 'bar-1',
        name: 'Standard barbell',
        weightGrams: 20000,
        isDefault: true,
      );

      final bars = await repo.getBars();
      expect(bars, hasLength(1));
      expect(bars.single.id, id);
      expect(bars.single.isDefault, isTrue);
    });

    test('setting a bar default clears the previous default', () async {
      await repo.createBar(
        id: 'bar-1',
        name: 'Standard',
        weightGrams: 20000,
        isDefault: true,
      );
      await repo.createBar(
        id: 'bar-2',
        name: "Women's",
        weightGrams: 15000,
        isDefault: true,
      );

      final bars = await repo.getBars();
      final defaults = bars.where((b) => b.isDefault).toList();
      expect(defaults, hasLength(1));
      expect(defaults.single.id, 'bar-2');
    });

    test('deleting a bar tombstones it rather than removing it', () async {
      await repo.createBar(id: 'bar-1', name: 'Standard', weightGrams: 20000);
      await repo.deleteBar('bar-1');

      expect(await repo.getBars(), isEmpty);
      expect(await repo.findBarById('bar-1'), isNull);
    });

    test('resolveBar falls back to the inventory default when the '
        "exercise's own bar has been deleted", () async {
      await repo.createBar(
        id: 'bar-1',
        name: 'Standard',
        weightGrams: 20000,
        isDefault: true,
      );
      await repo.createBar(id: 'bar-2', name: 'Specialty', weightGrams: 25000);
      await repo.deleteBar('bar-2');

      final resolved = await repo.resolveBar('bar-2');
      expect(resolved?.id, 'bar-1');
    });

    test('resolveBar returns null with no bars configured at all', () async {
      expect(await repo.resolveBar(null), isNull);
    });

    test('usable plates exclude disabled and zero-count rows', () async {
      await repo.createPlate(id: 'p-20', weightGrams: 20000, countAvailable: 2);
      await repo.createPlate(id: 'p-10', weightGrams: 10000, countAvailable: 0);
      await repo.createPlate(
        id: 'p-5',
        weightGrams: 5000,
        countAvailable: 2,
        isEnabled: false,
      );

      final usable = await repo.getUsablePlates();
      expect(usable, hasLength(1));
      expect(usable.single.weightGrams, 20000);
    });
  });

  group('first-run seeding (F-PLT-002 §1, §3)', () {
    test('seeds a kilogram set when the load unit is kg', () async {
      await repo.seedDefaultsIfNeeded(MassUnit.kg);

      final bars = await repo.getBars();
      expect(bars, isNotEmpty);
      expect(bars.any((b) => b.weightGrams == 20000 && b.isDefault), isTrue);
      expect(await repo.getPlates(), isNotEmpty);
    });

    test('seeds a pound set when the load unit is lb', () async {
      await repo.seedDefaultsIfNeeded(MassUnit.lb);

      final bars = await repo.getBars();
      expect(
        bars.any((b) => b.weightGrams == Mass.lb(45).grams && b.isDefault),
        isTrue,
      );
    });

    test(
      'runs once — a second call is a no-op even for a different unit',
      () async {
        await repo.seedDefaultsIfNeeded(MassUnit.kg);
        final afterFirst = await repo.getBars();

        await repo.seedDefaultsIfNeeded(MassUnit.lb);
        final afterSecond = await repo.getBars();

        expect(afterSecond.length, afterFirst.length);
        expect(afterSecond.map((b) => b.id), afterFirst.map((b) => b.id));
      },
    );

    test(
      'never re-seeds over a curated inventory the user has edited',
      () async {
        await repo.seedDefaultsIfNeeded(MassUnit.kg);
        await repo.deleteBar((await repo.getBars()).first.id);
        final afterEdit = await repo.getBars();

        await repo.seedDefaultsIfNeeded(MassUnit.kg);

        expect(await repo.getBars(), afterEdit);
      },
    );
  });
}
