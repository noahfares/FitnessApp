// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BarsTable extends Bars with TableInfo<$BarsTable, Bar> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BarsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local-user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightGramsMeta = const VerificationMeta(
    'weightGrams',
  );
  @override
  late final GeneratedColumn<int> weightGrams = GeneratedColumn<int>(
    'weight_grams',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    weightGrams,
    isDefault,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bars';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bar> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('weight_grams')) {
      context.handle(
        _weightGramsMeta,
        weightGrams.isAcceptableOrUnknown(
          data['weight_grams']!,
          _weightGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weightGramsMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bar map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bar(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      weightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight_grams'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $BarsTable createAlias(String alias) {
    return $BarsTable(attachedDatabase, alias);
  }
}

class Bar extends DataClass implements Insertable<Bar> {
  /// UUID v4, generated client-side.
  ///
  /// Not an autoincrementing integer: an ID that exists before the insert
  /// completes lets the UI render optimistically, which matters directly for
  /// write-through set logging (`F-LOG-007`), and removes the collision problem
  /// from any future sync.
  final String id;

  /// Constant `'local-user'` for now. Adding a `NOT NULL` foreign key to
  /// populated tables later is painful; adding a column that is already there
  /// and already correct is free.
  final String userId;

  /// UTC epoch milliseconds.
  final int createdAt;

  /// UTC epoch milliseconds, rewritten on **every** modification. The basis for
  /// last-write-wins resolution if sync ever ships.
  final int updatedAt;

  /// Soft-delete tombstone. **Nothing is ever hard-deleted.**
  ///
  /// Every read filters `deleted_at IS NULL`. A query that forgets silently
  /// resurrects deleted rows — the single most likely bug this schema
  /// introduces, which is why the filter is centralised in the DAOs rather than
  /// written per query.
  final int? deletedAt;
  final String name;

  /// Canonical grams, like every other mass in the schema (ADR-0003).
  final int weightGrams;
  final bool isDefault;
  const Bar({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.weightGrams,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['weight_grams'] = Variable<int>(weightGrams);
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  BarsCompanion toCompanion(bool nullToAbsent) {
    return BarsCompanion(
      id: Value(id),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      weightGrams: Value(weightGrams),
      isDefault: Value(isDefault),
    );
  }

  factory Bar.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bar(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      weightGrams: serializer.fromJson<int>(json['weightGrams']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'weightGrams': serializer.toJson<int>(weightGrams),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  Bar copyWith({
    String? id,
    String? userId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? name,
    int? weightGrams,
    bool? isDefault,
  }) => Bar(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    weightGrams: weightGrams ?? this.weightGrams,
    isDefault: isDefault ?? this.isDefault,
  );
  Bar copyWithCompanion(BarsCompanion data) {
    return Bar(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      weightGrams: data.weightGrams.present
          ? data.weightGrams.value
          : this.weightGrams,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bar(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    weightGrams,
    isDefault,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bar &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.weightGrams == this.weightGrams &&
          other.isDefault == this.isDefault);
}

class BarsCompanion extends UpdateCompanion<Bar> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> name;
  final Value<int> weightGrams;
  final Value<bool> isDefault;
  final Value<int> rowid;
  const BarsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.weightGrams = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BarsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    required int weightGrams,
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       weightGrams = Value(weightGrams);
  static Insertable<Bar> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? name,
    Expression<int>? weightGrams,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (weightGrams != null) 'weight_grams': weightGrams,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BarsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? name,
    Value<int>? weightGrams,
    Value<bool>? isDefault,
    Value<int>? rowid,
  }) {
    return BarsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      weightGrams: weightGrams ?? this.weightGrams,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (weightGrams.present) {
      map['weight_grams'] = Variable<int>(weightGrams.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BarsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local-user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> aliases =
      GeneratedColumn<String>(
        'aliases',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      ).withConverter<List<String>>($ExercisesTable.$converteraliases);
  @override
  late final GeneratedColumnWithTypeConverter<Muscle, String> primaryMuscle =
      GeneratedColumn<String>(
        'primary_muscle',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Muscle>($ExercisesTable.$converterprimaryMuscle);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  secondaryMuscles = GeneratedColumn<String>(
    'secondary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  ).withConverter<List<String>>($ExercisesTable.$convertersecondaryMuscles);
  @override
  late final GeneratedColumnWithTypeConverter<Equipment, String> equipment =
      GeneratedColumn<String>(
        'equipment',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Equipment>($ExercisesTable.$converterequipment);
  @override
  late final GeneratedColumnWithTypeConverter<TrackingType, String>
  trackingType = GeneratedColumn<String>(
    'tracking_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<TrackingType>($ExercisesTable.$convertertrackingType);
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<int> archivedAt = GeneratedColumn<int>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultRestSecondsMeta =
      const VerificationMeta('defaultRestSeconds');
  @override
  late final GeneratedColumn<int> defaultRestSeconds = GeneratedColumn<int>(
    'default_rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultBarIdMeta = const VerificationMeta(
    'defaultBarId',
  );
  @override
  late final GeneratedColumn<String> defaultBarId = GeneratedColumn<String>(
    'default_bar_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bars (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<WeightEntryMode, String>
  weightEntryMode = GeneratedColumn<String>(
    'weight_entry_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('total'),
  ).withConverter<WeightEntryMode>($ExercisesTable.$converterweightEntryMode);
  static const VerificationMeta _incrementGramsMeta = const VerificationMeta(
    'incrementGrams',
  );
  @override
  late final GeneratedColumn<int> incrementGrams = GeneratedColumn<int>(
    'increment_grams',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyweightCoefficientMeta =
      const VerificationMeta('bodyweightCoefficient');
  @override
  late final GeneratedColumn<double> bodyweightCoefficient =
      GeneratedColumn<double>(
        'bodyweight_coefficient',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<WeightSource, String>
  weightSource = GeneratedColumn<String>(
    'weight_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('plateLoaded'),
  ).withConverter<WeightSource>($ExercisesTable.$converterweightSource);
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String>
  fixedIncrementsGrams = GeneratedColumn<String>(
    'fixed_increments_grams',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  ).withConverter<List<int>>($ExercisesTable.$converterfixedIncrementsGrams);
  static const VerificationMeta _stackBaseGramsMeta = const VerificationMeta(
    'stackBaseGrams',
  );
  @override
  late final GeneratedColumn<int> stackBaseGrams = GeneratedColumn<int>(
    'stack_base_grams',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stackStepGramsMeta = const VerificationMeta(
    'stackStepGrams',
  );
  @override
  late final GeneratedColumn<int> stackStepGrams = GeneratedColumn<int>(
    'stack_step_grams',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stackHalfStepGramsMeta =
      const VerificationMeta('stackHalfStepGrams');
  @override
  late final GeneratedColumn<int> stackHalfStepGrams = GeneratedColumn<int>(
    'stack_half_step_grams',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warmupRulesetMeta = const VerificationMeta(
    'warmupRuleset',
  );
  @override
  late final GeneratedColumn<String> warmupRuleset = GeneratedColumn<String>(
    'warmup_ruleset',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trainingMaxGramsMeta = const VerificationMeta(
    'trainingMaxGrams',
  );
  @override
  late final GeneratedColumn<int> trainingMaxGrams = GeneratedColumn<int>(
    'training_max_grams',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seedUpdatedAtMeta = const VerificationMeta(
    'seedUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> seedUpdatedAt = GeneratedColumn<int>(
    'seed_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    externalId,
    name,
    aliases,
    primaryMuscle,
    secondaryMuscles,
    equipment,
    trackingType,
    isCustom,
    isFavorite,
    archivedAt,
    notes,
    defaultRestSeconds,
    defaultBarId,
    weightEntryMode,
    incrementGrams,
    bodyweightCoefficient,
    weightSource,
    fixedIncrementsGrams,
    stackBaseGrams,
    stackStepGrams,
    stackHalfStepGrams,
    warmupRuleset,
    trainingMaxGrams,
    seedUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('default_rest_seconds')) {
      context.handle(
        _defaultRestSecondsMeta,
        defaultRestSeconds.isAcceptableOrUnknown(
          data['default_rest_seconds']!,
          _defaultRestSecondsMeta,
        ),
      );
    }
    if (data.containsKey('default_bar_id')) {
      context.handle(
        _defaultBarIdMeta,
        defaultBarId.isAcceptableOrUnknown(
          data['default_bar_id']!,
          _defaultBarIdMeta,
        ),
      );
    }
    if (data.containsKey('increment_grams')) {
      context.handle(
        _incrementGramsMeta,
        incrementGrams.isAcceptableOrUnknown(
          data['increment_grams']!,
          _incrementGramsMeta,
        ),
      );
    }
    if (data.containsKey('bodyweight_coefficient')) {
      context.handle(
        _bodyweightCoefficientMeta,
        bodyweightCoefficient.isAcceptableOrUnknown(
          data['bodyweight_coefficient']!,
          _bodyweightCoefficientMeta,
        ),
      );
    }
    if (data.containsKey('stack_base_grams')) {
      context.handle(
        _stackBaseGramsMeta,
        stackBaseGrams.isAcceptableOrUnknown(
          data['stack_base_grams']!,
          _stackBaseGramsMeta,
        ),
      );
    }
    if (data.containsKey('stack_step_grams')) {
      context.handle(
        _stackStepGramsMeta,
        stackStepGrams.isAcceptableOrUnknown(
          data['stack_step_grams']!,
          _stackStepGramsMeta,
        ),
      );
    }
    if (data.containsKey('stack_half_step_grams')) {
      context.handle(
        _stackHalfStepGramsMeta,
        stackHalfStepGrams.isAcceptableOrUnknown(
          data['stack_half_step_grams']!,
          _stackHalfStepGramsMeta,
        ),
      );
    }
    if (data.containsKey('warmup_ruleset')) {
      context.handle(
        _warmupRulesetMeta,
        warmupRuleset.isAcceptableOrUnknown(
          data['warmup_ruleset']!,
          _warmupRulesetMeta,
        ),
      );
    }
    if (data.containsKey('training_max_grams')) {
      context.handle(
        _trainingMaxGramsMeta,
        trainingMaxGrams.isAcceptableOrUnknown(
          data['training_max_grams']!,
          _trainingMaxGramsMeta,
        ),
      );
    }
    if (data.containsKey('seed_updated_at')) {
      context.handle(
        _seedUpdatedAtMeta,
        seedUpdatedAt.isAcceptableOrUnknown(
          data['seed_updated_at']!,
          _seedUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      aliases: $ExercisesTable.$converteraliases.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}aliases'],
        )!,
      ),
      primaryMuscle: $ExercisesTable.$converterprimaryMuscle.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}primary_muscle'],
        )!,
      ),
      secondaryMuscles: $ExercisesTable.$convertersecondaryMuscles.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}secondary_muscles'],
        )!,
      ),
      equipment: $ExercisesTable.$converterequipment.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}equipment'],
        )!,
      ),
      trackingType: $ExercisesTable.$convertertrackingType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tracking_type'],
        )!,
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archived_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      defaultRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_rest_seconds'],
      ),
      defaultBarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_bar_id'],
      ),
      weightEntryMode: $ExercisesTable.$converterweightEntryMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weight_entry_mode'],
        )!,
      ),
      incrementGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}increment_grams'],
      ),
      bodyweightCoefficient: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bodyweight_coefficient'],
      ),
      weightSource: $ExercisesTable.$converterweightSource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weight_source'],
        )!,
      ),
      fixedIncrementsGrams: $ExercisesTable.$converterfixedIncrementsGrams
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}fixed_increments_grams'],
            )!,
          ),
      stackBaseGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stack_base_grams'],
      ),
      stackStepGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stack_step_grams'],
      ),
      stackHalfStepGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stack_half_step_grams'],
      ),
      warmupRuleset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warmup_ruleset'],
      ),
      trainingMaxGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}training_max_grams'],
      ),
      seedUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed_updated_at'],
      ),
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<List<String>, String, String> $converteraliases =
      const StringListConverter();
  static JsonTypeConverter2<Muscle, String, String> $converterprimaryMuscle =
      const EnumNameConverter<Muscle>(Muscle.values);
  static JsonTypeConverter2<List<String>, String, String>
  $convertersecondaryMuscles = const StringListConverter();
  static JsonTypeConverter2<Equipment, String, String> $converterequipment =
      const EnumNameConverter<Equipment>(Equipment.values);
  static JsonTypeConverter2<TrackingType, String, String>
  $convertertrackingType = const EnumNameConverter<TrackingType>(
    TrackingType.values,
  );
  static JsonTypeConverter2<WeightEntryMode, String, String>
  $converterweightEntryMode = const EnumNameConverter<WeightEntryMode>(
    WeightEntryMode.values,
  );
  static JsonTypeConverter2<WeightSource, String, String>
  $converterweightSource = const EnumNameConverter<WeightSource>(
    WeightSource.values,
  );
  static TypeConverter<List<int>, String> $converterfixedIncrementsGrams =
      const IntListConverter();
}

class Exercise extends DataClass implements Insertable<Exercise> {
  /// UUID v4, generated client-side.
  ///
  /// Not an autoincrementing integer: an ID that exists before the insert
  /// completes lets the UI render optimistically, which matters directly for
  /// write-through set logging (`F-LOG-007`), and removes the collision problem
  /// from any future sync.
  final String id;

  /// Constant `'local-user'` for now. Adding a `NOT NULL` foreign key to
  /// populated tables later is painful; adding a column that is already there
  /// and already correct is free.
  final String userId;

  /// UTC epoch milliseconds.
  final int createdAt;

  /// UTC epoch milliseconds, rewritten on **every** modification. The basis for
  /// last-write-wins resolution if sync ever ships.
  final int updatedAt;

  /// Soft-delete tombstone. **Nothing is ever hard-deleted.**
  ///
  /// Every read filters `deleted_at IS NULL`. A query that forgets silently
  /// resurrects deleted rows — the single most likely bug this schema
  /// introduces, which is why the filter is centralised in the DAOs rather than
  /// written per query.
  final int? deletedAt;

  /// The seed dataset's own identifier, so the catalogue can be re-synced or
  /// corrected upstream without duplicating rows or breaking references from
  /// existing sets. Null for custom exercises.
  final String? externalId;
  final String name;

  /// Searchable but not displayed — "RDL", "OHP" (`F-CAT-008`).
  final List<String> aliases;
  final Muscle primaryMuscle;
  final List<String> secondaryMuscles;
  final Equipment equipment;
  final TrackingType trackingType;
  final bool isCustom;
  final bool isFavorite;

  /// Hidden from pickers (`F-CAT-009`). Distinct from `deletedAt`: archiving is
  /// a user-facing organisational act, deletion is a tombstone.
  final int? archivedAt;

  /// Seat height, pin position, grip width (`F-CAT-007`). Persists across every
  /// session, unlike per-workout notes.
  final String? notes;
  final int? defaultRestSeconds;
  final String? defaultBarId;
  final WeightEntryMode weightEntryMode;

  /// Smallest sensible jump for this exercise, in canonical grams
  /// (`F-SET-007`).
  final int? incrementGrams;

  /// Fraction of bodyweight loaded, for `bodyweightReps` (`F-LOG-019`).
  final double? bodyweightCoefficient;

  /// Plate-loaded, fixed dumbbells, or a weight stack (`F-PLT-005`). Decides
  /// what the plate calculator shows and what the progression engine's
  /// plate-aware rounding (`F-PRG-012`) snaps a proposal to.
  final WeightSource weightSource;

  /// The discrete total weights this exercise's rack actually stocks, for
  /// [WeightSource.fixedIncrement] — real dumbbell racks are not always
  /// evenly spaced, so this is an explicit list rather than a step size.
  /// Canonical grams, storage-is-always-total (`F-LOG-017` §1).
  final List<int> fixedIncrementsGrams;

  /// [WeightSource.stack]'s minimum pin weight, canonical grams.
  final int? stackBaseGrams;

  /// [WeightSource.stack]'s jump between pin positions, canonical grams.
  final int? stackStepGrams;

  /// [WeightSource.stack]'s optional add-on magnet, canonical grams — half a
  /// [stackStepGrams] on most machines, but not assumed to be.
  final int? stackHalfStepGrams;

  /// User-editable, per-exercise warm-up ramp (`F-LOG-020`) — JSON array of
  /// `{percent, reps}` steps. Null uses the app-wide default ramp.
  final String? warmupRuleset;

  /// The anchor for percentage-based progression (`F-PRG-004`), canonical
  /// grams — set by hand or derived from the exercise's best e1RM
  /// (`F-PRG-010`). Null until the user sets one; a percentage-based rule
  /// falls back to the routine's static target with no training max
  /// configured, the same "nothing to compute from yet" shape every other
  /// rule's first-run case already uses.
  final int? trainingMaxGrams;

  /// `updatedAt` as of the last time **seeding** wrote this row.
  ///
  /// Resolves the open question in `F-CAT-001`: a seeded row counts as
  /// user-edited when `updatedAt != seedUpdatedAt`, so re-seeding never
  /// clobbers an edit. Comparing `updatedAt` to `createdAt` instead would work
  /// exactly once — the first re-seed makes them differ and every row then
  /// looks edited forever.
  ///
  /// Null for custom exercises, which seeding never touches.
  final int? seedUpdatedAt;
  const Exercise({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.externalId,
    required this.name,
    required this.aliases,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.equipment,
    required this.trackingType,
    required this.isCustom,
    required this.isFavorite,
    this.archivedAt,
    this.notes,
    this.defaultRestSeconds,
    this.defaultBarId,
    required this.weightEntryMode,
    this.incrementGrams,
    this.bodyweightCoefficient,
    required this.weightSource,
    required this.fixedIncrementsGrams,
    this.stackBaseGrams,
    this.stackStepGrams,
    this.stackHalfStepGrams,
    this.warmupRuleset,
    this.trainingMaxGrams,
    this.seedUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    map['name'] = Variable<String>(name);
    {
      map['aliases'] = Variable<String>(
        $ExercisesTable.$converteraliases.toSql(aliases),
      );
    }
    {
      map['primary_muscle'] = Variable<String>(
        $ExercisesTable.$converterprimaryMuscle.toSql(primaryMuscle),
      );
    }
    {
      map['secondary_muscles'] = Variable<String>(
        $ExercisesTable.$convertersecondaryMuscles.toSql(secondaryMuscles),
      );
    }
    {
      map['equipment'] = Variable<String>(
        $ExercisesTable.$converterequipment.toSql(equipment),
      );
    }
    {
      map['tracking_type'] = Variable<String>(
        $ExercisesTable.$convertertrackingType.toSql(trackingType),
      );
    }
    map['is_custom'] = Variable<bool>(isCustom);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(archivedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || defaultRestSeconds != null) {
      map['default_rest_seconds'] = Variable<int>(defaultRestSeconds);
    }
    if (!nullToAbsent || defaultBarId != null) {
      map['default_bar_id'] = Variable<String>(defaultBarId);
    }
    {
      map['weight_entry_mode'] = Variable<String>(
        $ExercisesTable.$converterweightEntryMode.toSql(weightEntryMode),
      );
    }
    if (!nullToAbsent || incrementGrams != null) {
      map['increment_grams'] = Variable<int>(incrementGrams);
    }
    if (!nullToAbsent || bodyweightCoefficient != null) {
      map['bodyweight_coefficient'] = Variable<double>(bodyweightCoefficient);
    }
    {
      map['weight_source'] = Variable<String>(
        $ExercisesTable.$converterweightSource.toSql(weightSource),
      );
    }
    {
      map['fixed_increments_grams'] = Variable<String>(
        $ExercisesTable.$converterfixedIncrementsGrams.toSql(
          fixedIncrementsGrams,
        ),
      );
    }
    if (!nullToAbsent || stackBaseGrams != null) {
      map['stack_base_grams'] = Variable<int>(stackBaseGrams);
    }
    if (!nullToAbsent || stackStepGrams != null) {
      map['stack_step_grams'] = Variable<int>(stackStepGrams);
    }
    if (!nullToAbsent || stackHalfStepGrams != null) {
      map['stack_half_step_grams'] = Variable<int>(stackHalfStepGrams);
    }
    if (!nullToAbsent || warmupRuleset != null) {
      map['warmup_ruleset'] = Variable<String>(warmupRuleset);
    }
    if (!nullToAbsent || trainingMaxGrams != null) {
      map['training_max_grams'] = Variable<int>(trainingMaxGrams);
    }
    if (!nullToAbsent || seedUpdatedAt != null) {
      map['seed_updated_at'] = Variable<int>(seedUpdatedAt);
    }
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      externalId: externalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalId),
      name: Value(name),
      aliases: Value(aliases),
      primaryMuscle: Value(primaryMuscle),
      secondaryMuscles: Value(secondaryMuscles),
      equipment: Value(equipment),
      trackingType: Value(trackingType),
      isCustom: Value(isCustom),
      isFavorite: Value(isFavorite),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      defaultRestSeconds: defaultRestSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultRestSeconds),
      defaultBarId: defaultBarId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultBarId),
      weightEntryMode: Value(weightEntryMode),
      incrementGrams: incrementGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(incrementGrams),
      bodyweightCoefficient: bodyweightCoefficient == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyweightCoefficient),
      weightSource: Value(weightSource),
      fixedIncrementsGrams: Value(fixedIncrementsGrams),
      stackBaseGrams: stackBaseGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(stackBaseGrams),
      stackStepGrams: stackStepGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(stackStepGrams),
      stackHalfStepGrams: stackHalfStepGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(stackHalfStepGrams),
      warmupRuleset: warmupRuleset == null && nullToAbsent
          ? const Value.absent()
          : Value(warmupRuleset),
      trainingMaxGrams: trainingMaxGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(trainingMaxGrams),
      seedUpdatedAt: seedUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(seedUpdatedAt),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      externalId: serializer.fromJson<String?>(json['externalId']),
      name: serializer.fromJson<String>(json['name']),
      aliases: $ExercisesTable.$converteraliases.fromJson(
        serializer.fromJson<String>(json['aliases']),
      ),
      primaryMuscle: $ExercisesTable.$converterprimaryMuscle.fromJson(
        serializer.fromJson<String>(json['primaryMuscle']),
      ),
      secondaryMuscles: $ExercisesTable.$convertersecondaryMuscles.fromJson(
        serializer.fromJson<String>(json['secondaryMuscles']),
      ),
      equipment: $ExercisesTable.$converterequipment.fromJson(
        serializer.fromJson<String>(json['equipment']),
      ),
      trackingType: $ExercisesTable.$convertertrackingType.fromJson(
        serializer.fromJson<String>(json['trackingType']),
      ),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      archivedAt: serializer.fromJson<int?>(json['archivedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      defaultRestSeconds: serializer.fromJson<int?>(json['defaultRestSeconds']),
      defaultBarId: serializer.fromJson<String?>(json['defaultBarId']),
      weightEntryMode: $ExercisesTable.$converterweightEntryMode.fromJson(
        serializer.fromJson<String>(json['weightEntryMode']),
      ),
      incrementGrams: serializer.fromJson<int?>(json['incrementGrams']),
      bodyweightCoefficient: serializer.fromJson<double?>(
        json['bodyweightCoefficient'],
      ),
      weightSource: $ExercisesTable.$converterweightSource.fromJson(
        serializer.fromJson<String>(json['weightSource']),
      ),
      fixedIncrementsGrams: serializer.fromJson<List<int>>(
        json['fixedIncrementsGrams'],
      ),
      stackBaseGrams: serializer.fromJson<int?>(json['stackBaseGrams']),
      stackStepGrams: serializer.fromJson<int?>(json['stackStepGrams']),
      stackHalfStepGrams: serializer.fromJson<int?>(json['stackHalfStepGrams']),
      warmupRuleset: serializer.fromJson<String?>(json['warmupRuleset']),
      trainingMaxGrams: serializer.fromJson<int?>(json['trainingMaxGrams']),
      seedUpdatedAt: serializer.fromJson<int?>(json['seedUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'externalId': serializer.toJson<String?>(externalId),
      'name': serializer.toJson<String>(name),
      'aliases': serializer.toJson<String>(
        $ExercisesTable.$converteraliases.toJson(aliases),
      ),
      'primaryMuscle': serializer.toJson<String>(
        $ExercisesTable.$converterprimaryMuscle.toJson(primaryMuscle),
      ),
      'secondaryMuscles': serializer.toJson<String>(
        $ExercisesTable.$convertersecondaryMuscles.toJson(secondaryMuscles),
      ),
      'equipment': serializer.toJson<String>(
        $ExercisesTable.$converterequipment.toJson(equipment),
      ),
      'trackingType': serializer.toJson<String>(
        $ExercisesTable.$convertertrackingType.toJson(trackingType),
      ),
      'isCustom': serializer.toJson<bool>(isCustom),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'archivedAt': serializer.toJson<int?>(archivedAt),
      'notes': serializer.toJson<String?>(notes),
      'defaultRestSeconds': serializer.toJson<int?>(defaultRestSeconds),
      'defaultBarId': serializer.toJson<String?>(defaultBarId),
      'weightEntryMode': serializer.toJson<String>(
        $ExercisesTable.$converterweightEntryMode.toJson(weightEntryMode),
      ),
      'incrementGrams': serializer.toJson<int?>(incrementGrams),
      'bodyweightCoefficient': serializer.toJson<double?>(
        bodyweightCoefficient,
      ),
      'weightSource': serializer.toJson<String>(
        $ExercisesTable.$converterweightSource.toJson(weightSource),
      ),
      'fixedIncrementsGrams': serializer.toJson<List<int>>(
        fixedIncrementsGrams,
      ),
      'stackBaseGrams': serializer.toJson<int?>(stackBaseGrams),
      'stackStepGrams': serializer.toJson<int?>(stackStepGrams),
      'stackHalfStepGrams': serializer.toJson<int?>(stackHalfStepGrams),
      'warmupRuleset': serializer.toJson<String?>(warmupRuleset),
      'trainingMaxGrams': serializer.toJson<int?>(trainingMaxGrams),
      'seedUpdatedAt': serializer.toJson<int?>(seedUpdatedAt),
    };
  }

  Exercise copyWith({
    String? id,
    String? userId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    Value<String?> externalId = const Value.absent(),
    String? name,
    List<String>? aliases,
    Muscle? primaryMuscle,
    List<String>? secondaryMuscles,
    Equipment? equipment,
    TrackingType? trackingType,
    bool? isCustom,
    bool? isFavorite,
    Value<int?> archivedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> defaultRestSeconds = const Value.absent(),
    Value<String?> defaultBarId = const Value.absent(),
    WeightEntryMode? weightEntryMode,
    Value<int?> incrementGrams = const Value.absent(),
    Value<double?> bodyweightCoefficient = const Value.absent(),
    WeightSource? weightSource,
    List<int>? fixedIncrementsGrams,
    Value<int?> stackBaseGrams = const Value.absent(),
    Value<int?> stackStepGrams = const Value.absent(),
    Value<int?> stackHalfStepGrams = const Value.absent(),
    Value<String?> warmupRuleset = const Value.absent(),
    Value<int?> trainingMaxGrams = const Value.absent(),
    Value<int?> seedUpdatedAt = const Value.absent(),
  }) => Exercise(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    externalId: externalId.present ? externalId.value : this.externalId,
    name: name ?? this.name,
    aliases: aliases ?? this.aliases,
    primaryMuscle: primaryMuscle ?? this.primaryMuscle,
    secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
    equipment: equipment ?? this.equipment,
    trackingType: trackingType ?? this.trackingType,
    isCustom: isCustom ?? this.isCustom,
    isFavorite: isFavorite ?? this.isFavorite,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    notes: notes.present ? notes.value : this.notes,
    defaultRestSeconds: defaultRestSeconds.present
        ? defaultRestSeconds.value
        : this.defaultRestSeconds,
    defaultBarId: defaultBarId.present ? defaultBarId.value : this.defaultBarId,
    weightEntryMode: weightEntryMode ?? this.weightEntryMode,
    incrementGrams: incrementGrams.present
        ? incrementGrams.value
        : this.incrementGrams,
    bodyweightCoefficient: bodyweightCoefficient.present
        ? bodyweightCoefficient.value
        : this.bodyweightCoefficient,
    weightSource: weightSource ?? this.weightSource,
    fixedIncrementsGrams: fixedIncrementsGrams ?? this.fixedIncrementsGrams,
    stackBaseGrams: stackBaseGrams.present
        ? stackBaseGrams.value
        : this.stackBaseGrams,
    stackStepGrams: stackStepGrams.present
        ? stackStepGrams.value
        : this.stackStepGrams,
    stackHalfStepGrams: stackHalfStepGrams.present
        ? stackHalfStepGrams.value
        : this.stackHalfStepGrams,
    warmupRuleset: warmupRuleset.present
        ? warmupRuleset.value
        : this.warmupRuleset,
    trainingMaxGrams: trainingMaxGrams.present
        ? trainingMaxGrams.value
        : this.trainingMaxGrams,
    seedUpdatedAt: seedUpdatedAt.present
        ? seedUpdatedAt.value
        : this.seedUpdatedAt,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      name: data.name.present ? data.name.value : this.name,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
      primaryMuscle: data.primaryMuscle.present
          ? data.primaryMuscle.value
          : this.primaryMuscle,
      secondaryMuscles: data.secondaryMuscles.present
          ? data.secondaryMuscles.value
          : this.secondaryMuscles,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      trackingType: data.trackingType.present
          ? data.trackingType.value
          : this.trackingType,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      defaultRestSeconds: data.defaultRestSeconds.present
          ? data.defaultRestSeconds.value
          : this.defaultRestSeconds,
      defaultBarId: data.defaultBarId.present
          ? data.defaultBarId.value
          : this.defaultBarId,
      weightEntryMode: data.weightEntryMode.present
          ? data.weightEntryMode.value
          : this.weightEntryMode,
      incrementGrams: data.incrementGrams.present
          ? data.incrementGrams.value
          : this.incrementGrams,
      bodyweightCoefficient: data.bodyweightCoefficient.present
          ? data.bodyweightCoefficient.value
          : this.bodyweightCoefficient,
      weightSource: data.weightSource.present
          ? data.weightSource.value
          : this.weightSource,
      fixedIncrementsGrams: data.fixedIncrementsGrams.present
          ? data.fixedIncrementsGrams.value
          : this.fixedIncrementsGrams,
      stackBaseGrams: data.stackBaseGrams.present
          ? data.stackBaseGrams.value
          : this.stackBaseGrams,
      stackStepGrams: data.stackStepGrams.present
          ? data.stackStepGrams.value
          : this.stackStepGrams,
      stackHalfStepGrams: data.stackHalfStepGrams.present
          ? data.stackHalfStepGrams.value
          : this.stackHalfStepGrams,
      warmupRuleset: data.warmupRuleset.present
          ? data.warmupRuleset.value
          : this.warmupRuleset,
      trainingMaxGrams: data.trainingMaxGrams.present
          ? data.trainingMaxGrams.value
          : this.trainingMaxGrams,
      seedUpdatedAt: data.seedUpdatedAt.present
          ? data.seedUpdatedAt.value
          : this.seedUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('aliases: $aliases, ')
          ..write('primaryMuscle: $primaryMuscle, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('equipment: $equipment, ')
          ..write('trackingType: $trackingType, ')
          ..write('isCustom: $isCustom, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('notes: $notes, ')
          ..write('defaultRestSeconds: $defaultRestSeconds, ')
          ..write('defaultBarId: $defaultBarId, ')
          ..write('weightEntryMode: $weightEntryMode, ')
          ..write('incrementGrams: $incrementGrams, ')
          ..write('bodyweightCoefficient: $bodyweightCoefficient, ')
          ..write('weightSource: $weightSource, ')
          ..write('fixedIncrementsGrams: $fixedIncrementsGrams, ')
          ..write('stackBaseGrams: $stackBaseGrams, ')
          ..write('stackStepGrams: $stackStepGrams, ')
          ..write('stackHalfStepGrams: $stackHalfStepGrams, ')
          ..write('warmupRuleset: $warmupRuleset, ')
          ..write('trainingMaxGrams: $trainingMaxGrams, ')
          ..write('seedUpdatedAt: $seedUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    externalId,
    name,
    aliases,
    primaryMuscle,
    secondaryMuscles,
    equipment,
    trackingType,
    isCustom,
    isFavorite,
    archivedAt,
    notes,
    defaultRestSeconds,
    defaultBarId,
    weightEntryMode,
    incrementGrams,
    bodyweightCoefficient,
    weightSource,
    fixedIncrementsGrams,
    stackBaseGrams,
    stackStepGrams,
    stackHalfStepGrams,
    warmupRuleset,
    trainingMaxGrams,
    seedUpdatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.externalId == this.externalId &&
          other.name == this.name &&
          other.aliases == this.aliases &&
          other.primaryMuscle == this.primaryMuscle &&
          other.secondaryMuscles == this.secondaryMuscles &&
          other.equipment == this.equipment &&
          other.trackingType == this.trackingType &&
          other.isCustom == this.isCustom &&
          other.isFavorite == this.isFavorite &&
          other.archivedAt == this.archivedAt &&
          other.notes == this.notes &&
          other.defaultRestSeconds == this.defaultRestSeconds &&
          other.defaultBarId == this.defaultBarId &&
          other.weightEntryMode == this.weightEntryMode &&
          other.incrementGrams == this.incrementGrams &&
          other.bodyweightCoefficient == this.bodyweightCoefficient &&
          other.weightSource == this.weightSource &&
          other.fixedIncrementsGrams == this.fixedIncrementsGrams &&
          other.stackBaseGrams == this.stackBaseGrams &&
          other.stackStepGrams == this.stackStepGrams &&
          other.stackHalfStepGrams == this.stackHalfStepGrams &&
          other.warmupRuleset == this.warmupRuleset &&
          other.trainingMaxGrams == this.trainingMaxGrams &&
          other.seedUpdatedAt == this.seedUpdatedAt);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String?> externalId;
  final Value<String> name;
  final Value<List<String>> aliases;
  final Value<Muscle> primaryMuscle;
  final Value<List<String>> secondaryMuscles;
  final Value<Equipment> equipment;
  final Value<TrackingType> trackingType;
  final Value<bool> isCustom;
  final Value<bool> isFavorite;
  final Value<int?> archivedAt;
  final Value<String?> notes;
  final Value<int?> defaultRestSeconds;
  final Value<String?> defaultBarId;
  final Value<WeightEntryMode> weightEntryMode;
  final Value<int?> incrementGrams;
  final Value<double?> bodyweightCoefficient;
  final Value<WeightSource> weightSource;
  final Value<List<int>> fixedIncrementsGrams;
  final Value<int?> stackBaseGrams;
  final Value<int?> stackStepGrams;
  final Value<int?> stackHalfStepGrams;
  final Value<String?> warmupRuleset;
  final Value<int?> trainingMaxGrams;
  final Value<int?> seedUpdatedAt;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.externalId = const Value.absent(),
    this.name = const Value.absent(),
    this.aliases = const Value.absent(),
    this.primaryMuscle = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.equipment = const Value.absent(),
    this.trackingType = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.defaultRestSeconds = const Value.absent(),
    this.defaultBarId = const Value.absent(),
    this.weightEntryMode = const Value.absent(),
    this.incrementGrams = const Value.absent(),
    this.bodyweightCoefficient = const Value.absent(),
    this.weightSource = const Value.absent(),
    this.fixedIncrementsGrams = const Value.absent(),
    this.stackBaseGrams = const Value.absent(),
    this.stackStepGrams = const Value.absent(),
    this.stackHalfStepGrams = const Value.absent(),
    this.warmupRuleset = const Value.absent(),
    this.trainingMaxGrams = const Value.absent(),
    this.seedUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.externalId = const Value.absent(),
    required String name,
    this.aliases = const Value.absent(),
    required Muscle primaryMuscle,
    this.secondaryMuscles = const Value.absent(),
    required Equipment equipment,
    required TrackingType trackingType,
    this.isCustom = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.defaultRestSeconds = const Value.absent(),
    this.defaultBarId = const Value.absent(),
    this.weightEntryMode = const Value.absent(),
    this.incrementGrams = const Value.absent(),
    this.bodyweightCoefficient = const Value.absent(),
    this.weightSource = const Value.absent(),
    this.fixedIncrementsGrams = const Value.absent(),
    this.stackBaseGrams = const Value.absent(),
    this.stackStepGrams = const Value.absent(),
    this.stackHalfStepGrams = const Value.absent(),
    this.warmupRuleset = const Value.absent(),
    this.trainingMaxGrams = const Value.absent(),
    this.seedUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       primaryMuscle = Value(primaryMuscle),
       equipment = Value(equipment),
       trackingType = Value(trackingType);
  static Insertable<Exercise> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? externalId,
    Expression<String>? name,
    Expression<String>? aliases,
    Expression<String>? primaryMuscle,
    Expression<String>? secondaryMuscles,
    Expression<String>? equipment,
    Expression<String>? trackingType,
    Expression<bool>? isCustom,
    Expression<bool>? isFavorite,
    Expression<int>? archivedAt,
    Expression<String>? notes,
    Expression<int>? defaultRestSeconds,
    Expression<String>? defaultBarId,
    Expression<String>? weightEntryMode,
    Expression<int>? incrementGrams,
    Expression<double>? bodyweightCoefficient,
    Expression<String>? weightSource,
    Expression<String>? fixedIncrementsGrams,
    Expression<int>? stackBaseGrams,
    Expression<int>? stackStepGrams,
    Expression<int>? stackHalfStepGrams,
    Expression<String>? warmupRuleset,
    Expression<int>? trainingMaxGrams,
    Expression<int>? seedUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (externalId != null) 'external_id': externalId,
      if (name != null) 'name': name,
      if (aliases != null) 'aliases': aliases,
      if (primaryMuscle != null) 'primary_muscle': primaryMuscle,
      if (secondaryMuscles != null) 'secondary_muscles': secondaryMuscles,
      if (equipment != null) 'equipment': equipment,
      if (trackingType != null) 'tracking_type': trackingType,
      if (isCustom != null) 'is_custom': isCustom,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (notes != null) 'notes': notes,
      if (defaultRestSeconds != null)
        'default_rest_seconds': defaultRestSeconds,
      if (defaultBarId != null) 'default_bar_id': defaultBarId,
      if (weightEntryMode != null) 'weight_entry_mode': weightEntryMode,
      if (incrementGrams != null) 'increment_grams': incrementGrams,
      if (bodyweightCoefficient != null)
        'bodyweight_coefficient': bodyweightCoefficient,
      if (weightSource != null) 'weight_source': weightSource,
      if (fixedIncrementsGrams != null)
        'fixed_increments_grams': fixedIncrementsGrams,
      if (stackBaseGrams != null) 'stack_base_grams': stackBaseGrams,
      if (stackStepGrams != null) 'stack_step_grams': stackStepGrams,
      if (stackHalfStepGrams != null)
        'stack_half_step_grams': stackHalfStepGrams,
      if (warmupRuleset != null) 'warmup_ruleset': warmupRuleset,
      if (trainingMaxGrams != null) 'training_max_grams': trainingMaxGrams,
      if (seedUpdatedAt != null) 'seed_updated_at': seedUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String?>? externalId,
    Value<String>? name,
    Value<List<String>>? aliases,
    Value<Muscle>? primaryMuscle,
    Value<List<String>>? secondaryMuscles,
    Value<Equipment>? equipment,
    Value<TrackingType>? trackingType,
    Value<bool>? isCustom,
    Value<bool>? isFavorite,
    Value<int?>? archivedAt,
    Value<String?>? notes,
    Value<int?>? defaultRestSeconds,
    Value<String?>? defaultBarId,
    Value<WeightEntryMode>? weightEntryMode,
    Value<int?>? incrementGrams,
    Value<double?>? bodyweightCoefficient,
    Value<WeightSource>? weightSource,
    Value<List<int>>? fixedIncrementsGrams,
    Value<int?>? stackBaseGrams,
    Value<int?>? stackStepGrams,
    Value<int?>? stackHalfStepGrams,
    Value<String?>? warmupRuleset,
    Value<int?>? trainingMaxGrams,
    Value<int?>? seedUpdatedAt,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      externalId: externalId ?? this.externalId,
      name: name ?? this.name,
      aliases: aliases ?? this.aliases,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      equipment: equipment ?? this.equipment,
      trackingType: trackingType ?? this.trackingType,
      isCustom: isCustom ?? this.isCustom,
      isFavorite: isFavorite ?? this.isFavorite,
      archivedAt: archivedAt ?? this.archivedAt,
      notes: notes ?? this.notes,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      defaultBarId: defaultBarId ?? this.defaultBarId,
      weightEntryMode: weightEntryMode ?? this.weightEntryMode,
      incrementGrams: incrementGrams ?? this.incrementGrams,
      bodyweightCoefficient:
          bodyweightCoefficient ?? this.bodyweightCoefficient,
      weightSource: weightSource ?? this.weightSource,
      fixedIncrementsGrams: fixedIncrementsGrams ?? this.fixedIncrementsGrams,
      stackBaseGrams: stackBaseGrams ?? this.stackBaseGrams,
      stackStepGrams: stackStepGrams ?? this.stackStepGrams,
      stackHalfStepGrams: stackHalfStepGrams ?? this.stackHalfStepGrams,
      warmupRuleset: warmupRuleset ?? this.warmupRuleset,
      trainingMaxGrams: trainingMaxGrams ?? this.trainingMaxGrams,
      seedUpdatedAt: seedUpdatedAt ?? this.seedUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(
        $ExercisesTable.$converteraliases.toSql(aliases.value),
      );
    }
    if (primaryMuscle.present) {
      map['primary_muscle'] = Variable<String>(
        $ExercisesTable.$converterprimaryMuscle.toSql(primaryMuscle.value),
      );
    }
    if (secondaryMuscles.present) {
      map['secondary_muscles'] = Variable<String>(
        $ExercisesTable.$convertersecondaryMuscles.toSql(
          secondaryMuscles.value,
        ),
      );
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(
        $ExercisesTable.$converterequipment.toSql(equipment.value),
      );
    }
    if (trackingType.present) {
      map['tracking_type'] = Variable<String>(
        $ExercisesTable.$convertertrackingType.toSql(trackingType.value),
      );
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(archivedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (defaultRestSeconds.present) {
      map['default_rest_seconds'] = Variable<int>(defaultRestSeconds.value);
    }
    if (defaultBarId.present) {
      map['default_bar_id'] = Variable<String>(defaultBarId.value);
    }
    if (weightEntryMode.present) {
      map['weight_entry_mode'] = Variable<String>(
        $ExercisesTable.$converterweightEntryMode.toSql(weightEntryMode.value),
      );
    }
    if (incrementGrams.present) {
      map['increment_grams'] = Variable<int>(incrementGrams.value);
    }
    if (bodyweightCoefficient.present) {
      map['bodyweight_coefficient'] = Variable<double>(
        bodyweightCoefficient.value,
      );
    }
    if (weightSource.present) {
      map['weight_source'] = Variable<String>(
        $ExercisesTable.$converterweightSource.toSql(weightSource.value),
      );
    }
    if (fixedIncrementsGrams.present) {
      map['fixed_increments_grams'] = Variable<String>(
        $ExercisesTable.$converterfixedIncrementsGrams.toSql(
          fixedIncrementsGrams.value,
        ),
      );
    }
    if (stackBaseGrams.present) {
      map['stack_base_grams'] = Variable<int>(stackBaseGrams.value);
    }
    if (stackStepGrams.present) {
      map['stack_step_grams'] = Variable<int>(stackStepGrams.value);
    }
    if (stackHalfStepGrams.present) {
      map['stack_half_step_grams'] = Variable<int>(stackHalfStepGrams.value);
    }
    if (warmupRuleset.present) {
      map['warmup_ruleset'] = Variable<String>(warmupRuleset.value);
    }
    if (trainingMaxGrams.present) {
      map['training_max_grams'] = Variable<int>(trainingMaxGrams.value);
    }
    if (seedUpdatedAt.present) {
      map['seed_updated_at'] = Variable<int>(seedUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('externalId: $externalId, ')
          ..write('name: $name, ')
          ..write('aliases: $aliases, ')
          ..write('primaryMuscle: $primaryMuscle, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('equipment: $equipment, ')
          ..write('trackingType: $trackingType, ')
          ..write('isCustom: $isCustom, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('notes: $notes, ')
          ..write('defaultRestSeconds: $defaultRestSeconds, ')
          ..write('defaultBarId: $defaultBarId, ')
          ..write('weightEntryMode: $weightEntryMode, ')
          ..write('incrementGrams: $incrementGrams, ')
          ..write('bodyweightCoefficient: $bodyweightCoefficient, ')
          ..write('weightSource: $weightSource, ')
          ..write('fixedIncrementsGrams: $fixedIncrementsGrams, ')
          ..write('stackBaseGrams: $stackBaseGrams, ')
          ..write('stackStepGrams: $stackStepGrams, ')
          ..write('stackHalfStepGrams: $stackHalfStepGrams, ')
          ..write('warmupRuleset: $warmupRuleset, ')
          ..write('trainingMaxGrams: $trainingMaxGrams, ')
          ..write('seedUpdatedAt: $seedUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlatesTable extends Plates with TableInfo<$PlatesTable, Plate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local-user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightGramsMeta = const VerificationMeta(
    'weightGrams',
  );
  @override
  late final GeneratedColumn<int> weightGrams = GeneratedColumn<int>(
    'weight_grams',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countAvailableMeta = const VerificationMeta(
    'countAvailable',
  );
  @override
  late final GeneratedColumn<int> countAvailable = GeneratedColumn<int>(
    'count_available',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    weightGrams,
    countAvailable,
    isEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plates';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('weight_grams')) {
      context.handle(
        _weightGramsMeta,
        weightGrams.isAcceptableOrUnknown(
          data['weight_grams']!,
          _weightGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weightGramsMeta);
    }
    if (data.containsKey('count_available')) {
      context.handle(
        _countAvailableMeta,
        countAvailable.isAcceptableOrUnknown(
          data['count_available']!,
          _countAvailableMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      weightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight_grams'],
      )!,
      countAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count_available'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
    );
  }

  @override
  $PlatesTable createAlias(String alias) {
    return $PlatesTable(attachedDatabase, alias);
  }
}

class Plate extends DataClass implements Insertable<Plate> {
  /// UUID v4, generated client-side.
  ///
  /// Not an autoincrementing integer: an ID that exists before the insert
  /// completes lets the UI render optimistically, which matters directly for
  /// write-through set logging (`F-LOG-007`), and removes the collision problem
  /// from any future sync.
  final String id;

  /// Constant `'local-user'` for now. Adding a `NOT NULL` foreign key to
  /// populated tables later is painful; adding a column that is already there
  /// and already correct is free.
  final String userId;

  /// UTC epoch milliseconds.
  final int createdAt;

  /// UTC epoch milliseconds, rewritten on **every** modification. The basis for
  /// last-write-wins resolution if sync ever ships.
  final int updatedAt;

  /// Soft-delete tombstone. **Nothing is ever hard-deleted.**
  ///
  /// Every read filters `deleted_at IS NULL`. A query that forgets silently
  /// resurrects deleted rows — the single most likely bug this schema
  /// introduces, which is why the filter is centralised in the DAOs rather than
  /// written per query.
  final int? deletedAt;
  final int weightGrams;
  final int countAvailable;
  final bool isEnabled;
  const Plate({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.weightGrams,
    required this.countAvailable,
    required this.isEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['weight_grams'] = Variable<int>(weightGrams);
    map['count_available'] = Variable<int>(countAvailable);
    map['is_enabled'] = Variable<bool>(isEnabled);
    return map;
  }

  PlatesCompanion toCompanion(bool nullToAbsent) {
    return PlatesCompanion(
      id: Value(id),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      weightGrams: Value(weightGrams),
      countAvailable: Value(countAvailable),
      isEnabled: Value(isEnabled),
    );
  }

  factory Plate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plate(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      weightGrams: serializer.fromJson<int>(json['weightGrams']),
      countAvailable: serializer.fromJson<int>(json['countAvailable']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'weightGrams': serializer.toJson<int>(weightGrams),
      'countAvailable': serializer.toJson<int>(countAvailable),
      'isEnabled': serializer.toJson<bool>(isEnabled),
    };
  }

  Plate copyWith({
    String? id,
    String? userId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? weightGrams,
    int? countAvailable,
    bool? isEnabled,
  }) => Plate(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    weightGrams: weightGrams ?? this.weightGrams,
    countAvailable: countAvailable ?? this.countAvailable,
    isEnabled: isEnabled ?? this.isEnabled,
  );
  Plate copyWithCompanion(PlatesCompanion data) {
    return Plate(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      weightGrams: data.weightGrams.present
          ? data.weightGrams.value
          : this.weightGrams,
      countAvailable: data.countAvailable.present
          ? data.countAvailable.value
          : this.countAvailable,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plate(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('countAvailable: $countAvailable, ')
          ..write('isEnabled: $isEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    weightGrams,
    countAvailable,
    isEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plate &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.weightGrams == this.weightGrams &&
          other.countAvailable == this.countAvailable &&
          other.isEnabled == this.isEnabled);
}

class PlatesCompanion extends UpdateCompanion<Plate> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> weightGrams;
  final Value<int> countAvailable;
  final Value<bool> isEnabled;
  final Value<int> rowid;
  const PlatesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.weightGrams = const Value.absent(),
    this.countAvailable = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlatesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required int weightGrams,
    this.countAvailable = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       weightGrams = Value(weightGrams);
  static Insertable<Plate> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? weightGrams,
    Expression<int>? countAvailable,
    Expression<bool>? isEnabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (weightGrams != null) 'weight_grams': weightGrams,
      if (countAvailable != null) 'count_available': countAvailable,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlatesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? weightGrams,
    Value<int>? countAvailable,
    Value<bool>? isEnabled,
    Value<int>? rowid,
  }) {
    return PlatesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      weightGrams: weightGrams ?? this.weightGrams,
      countAvailable: countAvailable ?? this.countAvailable,
      isEnabled: isEnabled ?? this.isEnabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (weightGrams.present) {
      map['weight_grams'] = Variable<int>(weightGrams.value);
    }
    if (countAvailable.present) {
      map['count_available'] = Variable<int>(countAvailable.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlatesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('countAvailable: $countAvailable, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineFoldersTable extends RoutineFolders
    with TableInfo<$RoutineFoldersTable, RoutineFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local-user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineFolder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineFolder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $RoutineFoldersTable createAlias(String alias) {
    return $RoutineFoldersTable(attachedDatabase, alias);
  }
}

class RoutineFolder extends DataClass implements Insertable<RoutineFolder> {
  /// UUID v4, generated client-side.
  ///
  /// Not an autoincrementing integer: an ID that exists before the insert
  /// completes lets the UI render optimistically, which matters directly for
  /// write-through set logging (`F-LOG-007`), and removes the collision problem
  /// from any future sync.
  final String id;

  /// Constant `'local-user'` for now. Adding a `NOT NULL` foreign key to
  /// populated tables later is painful; adding a column that is already there
  /// and already correct is free.
  final String userId;

  /// UTC epoch milliseconds.
  final int createdAt;

  /// UTC epoch milliseconds, rewritten on **every** modification. The basis for
  /// last-write-wins resolution if sync ever ships.
  final int updatedAt;

  /// Soft-delete tombstone. **Nothing is ever hard-deleted.**
  ///
  /// Every read filters `deleted_at IS NULL`. A query that forgets silently
  /// resurrects deleted rows — the single most likely bug this schema
  /// introduces, which is why the filter is centralised in the DAOs rather than
  /// written per query.
  final int? deletedAt;
  final String name;
  final int position;
  const RoutineFolder({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    return map;
  }

  RoutineFoldersCompanion toCompanion(bool nullToAbsent) {
    return RoutineFoldersCompanion(
      id: Value(id),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      position: Value(position),
    );
  }

  factory RoutineFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineFolder(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
    };
  }

  RoutineFolder copyWith({
    String? id,
    String? userId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? name,
    int? position,
  }) => RoutineFolder(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    position: position ?? this.position,
  );
  RoutineFolder copyWithCompanion(RoutineFoldersCompanion data) {
    return RoutineFolder(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineFolder(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, createdAt, updatedAt, deletedAt, name, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineFolder &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.position == this.position);
}

class RoutineFoldersCompanion extends UpdateCompanion<RoutineFolder> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> name;
  final Value<int> position;
  final Value<int> rowid;
  const RoutineFoldersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineFoldersCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       position = Value(position);
  static Insertable<RoutineFolder> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? name,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineFoldersCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? name,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return RoutineFoldersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineFoldersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines with TableInfo<$RoutinesTable, Routine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local-user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_folders (id)',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<int> archivedAt = GeneratedColumn<int>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    folderId,
    notes,
    position,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<Routine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Routine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Routine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class Routine extends DataClass implements Insertable<Routine> {
  /// UUID v4, generated client-side.
  ///
  /// Not an autoincrementing integer: an ID that exists before the insert
  /// completes lets the UI render optimistically, which matters directly for
  /// write-through set logging (`F-LOG-007`), and removes the collision problem
  /// from any future sync.
  final String id;

  /// Constant `'local-user'` for now. Adding a `NOT NULL` foreign key to
  /// populated tables later is painful; adding a column that is already there
  /// and already correct is free.
  final String userId;

  /// UTC epoch milliseconds.
  final int createdAt;

  /// UTC epoch milliseconds, rewritten on **every** modification. The basis for
  /// last-write-wins resolution if sync ever ships.
  final int updatedAt;

  /// Soft-delete tombstone. **Nothing is ever hard-deleted.**
  ///
  /// Every read filters `deleted_at IS NULL`. A query that forgets silently
  /// resurrects deleted rows — the single most likely bug this schema
  /// introduces, which is why the filter is centralised in the DAOs rather than
  /// written per query.
  final int? deletedAt;
  final String name;
  final String? folderId;
  final String? notes;

  /// Explicit ordering. Never inferred from `createdAt` — that breaks the
  /// moment anything is reordered.
  final int position;
  final int? archivedAt;
  const Routine({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    this.folderId,
    this.notes,
    required this.position,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(archivedAt);
    }
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      position: Value(position),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Routine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Routine(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      notes: serializer.fromJson<String?>(json['notes']),
      position: serializer.fromJson<int>(json['position']),
      archivedAt: serializer.fromJson<int?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'folderId': serializer.toJson<String?>(folderId),
      'notes': serializer.toJson<String?>(notes),
      'position': serializer.toJson<int>(position),
      'archivedAt': serializer.toJson<int?>(archivedAt),
    };
  }

  Routine copyWith({
    String? id,
    String? userId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? name,
    Value<String?> folderId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? position,
    Value<int?> archivedAt = const Value.absent(),
  }) => Routine(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    folderId: folderId.present ? folderId.value : this.folderId,
    notes: notes.present ? notes.value : this.notes,
    position: position ?? this.position,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Routine copyWithCompanion(RoutinesCompanion data) {
    return Routine(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      notes: data.notes.present ? data.notes.value : this.notes,
      position: data.position.present ? data.position.value : this.position,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Routine(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('folderId: $folderId, ')
          ..write('notes: $notes, ')
          ..write('position: $position, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    folderId,
    notes,
    position,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Routine &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.folderId == this.folderId &&
          other.notes == this.notes &&
          other.position == this.position &&
          other.archivedAt == this.archivedAt);
}

class RoutinesCompanion extends UpdateCompanion<Routine> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> name;
  final Value<String?> folderId;
  final Value<String?> notes;
  final Value<int> position;
  final Value<int?> archivedAt;
  final Value<int> rowid;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.folderId = const Value.absent(),
    this.notes = const Value.absent(),
    this.position = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutinesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    this.folderId = const Value.absent(),
    this.notes = const Value.absent(),
    required int position,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       position = Value(position);
  static Insertable<Routine> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? name,
    Expression<String>? folderId,
    Expression<String>? notes,
    Expression<int>? position,
    Expression<int>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (folderId != null) 'folder_id': folderId,
      if (notes != null) 'notes': notes,
      if (position != null) 'position': position,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutinesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? name,
    Value<String?>? folderId,
    Value<String?>? notes,
    Value<int>? position,
    Value<int?>? archivedAt,
    Value<int>? rowid,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      folderId: folderId ?? this.folderId,
      notes: notes ?? this.notes,
      position: position ?? this.position,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('folderId: $folderId, ')
          ..write('notes: $notes, ')
          ..write('position: $position, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineDaysTable extends RoutineDays
    with TableInfo<$RoutineDaysTable, RoutineDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local-user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String>
  scheduledWeekdays = GeneratedColumn<String>(
    'scheduled_weekdays',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  ).withConverter<List<int>>($RoutineDaysTable.$converterscheduledWeekdays);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    routineId,
    name,
    position,
    scheduledWeekdays,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      scheduledWeekdays: $RoutineDaysTable.$converterscheduledWeekdays.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}scheduled_weekdays'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $RoutineDaysTable createAlias(String alias) {
    return $RoutineDaysTable(attachedDatabase, alias);
  }

  static TypeConverter<List<int>, String> $converterscheduledWeekdays =
      const IntListConverter();
}

class RoutineDay extends DataClass implements Insertable<RoutineDay> {
  /// UUID v4, generated client-side.
  ///
  /// Not an autoincrementing integer: an ID that exists before the insert
  /// completes lets the UI render optimistically, which matters directly for
  /// write-through set logging (`F-LOG-007`), and removes the collision problem
  /// from any future sync.
  final String id;

  /// Constant `'local-user'` for now. Adding a `NOT NULL` foreign key to
  /// populated tables later is painful; adding a column that is already there
  /// and already correct is free.
  final String userId;

  /// UTC epoch milliseconds.
  final int createdAt;

  /// UTC epoch milliseconds, rewritten on **every** modification. The basis for
  /// last-write-wins resolution if sync ever ships.
  final int updatedAt;

  /// Soft-delete tombstone. **Nothing is ever hard-deleted.**
  ///
  /// Every read filters `deleted_at IS NULL`. A query that forgets silently
  /// resurrects deleted rows — the single most likely bug this schema
  /// introduces, which is why the filter is centralised in the DAOs rather than
  /// written per query.
  final int? deletedAt;
  final String routineId;
  final String name;
  final int position;

  /// ISO weekday numbers (`F-ROU-012`).
  final List<int> scheduledWeekdays;
  final String? notes;
  const RoutineDay({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.routineId,
    required this.name,
    required this.position,
    required this.scheduledWeekdays,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['routine_id'] = Variable<String>(routineId);
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    {
      map['scheduled_weekdays'] = Variable<String>(
        $RoutineDaysTable.$converterscheduledWeekdays.toSql(scheduledWeekdays),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  RoutineDaysCompanion toCompanion(bool nullToAbsent) {
    return RoutineDaysCompanion(
      id: Value(id),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      routineId: Value(routineId),
      name: Value(name),
      position: Value(position),
      scheduledWeekdays: Value(scheduledWeekdays),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory RoutineDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineDay(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      routineId: serializer.fromJson<String>(json['routineId']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<int>(json['position']),
      scheduledWeekdays: serializer.fromJson<List<int>>(
        json['scheduledWeekdays'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'routineId': serializer.toJson<String>(routineId),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
      'scheduledWeekdays': serializer.toJson<List<int>>(scheduledWeekdays),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  RoutineDay copyWith({
    String? id,
    String? userId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? routineId,
    String? name,
    int? position,
    List<int>? scheduledWeekdays,
    Value<String?> notes = const Value.absent(),
  }) => RoutineDay(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    routineId: routineId ?? this.routineId,
    name: name ?? this.name,
    position: position ?? this.position,
    scheduledWeekdays: scheduledWeekdays ?? this.scheduledWeekdays,
    notes: notes.present ? notes.value : this.notes,
  );
  RoutineDay copyWithCompanion(RoutineDaysCompanion data) {
    return RoutineDay(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
      scheduledWeekdays: data.scheduledWeekdays.present
          ? data.scheduledWeekdays.value
          : this.scheduledWeekdays,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineDay(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('routineId: $routineId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('scheduledWeekdays: $scheduledWeekdays, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    routineId,
    name,
    position,
    scheduledWeekdays,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineDay &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.routineId == this.routineId &&
          other.name == this.name &&
          other.position == this.position &&
          other.scheduledWeekdays == this.scheduledWeekdays &&
          other.notes == this.notes);
}

class RoutineDaysCompanion extends UpdateCompanion<RoutineDay> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> routineId;
  final Value<String> name;
  final Value<int> position;
  final Value<List<int>> scheduledWeekdays;
  final Value<String?> notes;
  final Value<int> rowid;
  const RoutineDaysCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.routineId = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.scheduledWeekdays = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineDaysCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String routineId,
    required String name,
    required int position,
    this.scheduledWeekdays = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       routineId = Value(routineId),
       name = Value(name),
       position = Value(position);
  static Insertable<RoutineDay> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? routineId,
    Expression<String>? name,
    Expression<int>? position,
    Expression<String>? scheduledWeekdays,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (routineId != null) 'routine_id': routineId,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (scheduledWeekdays != null) 'scheduled_weekdays': scheduledWeekdays,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineDaysCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? routineId,
    Value<String>? name,
    Value<int>? position,
    Value<List<int>>? scheduledWeekdays,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return RoutineDaysCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      routineId: routineId ?? this.routineId,
      name: name ?? this.name,
      position: position ?? this.position,
      scheduledWeekdays: scheduledWeekdays ?? this.scheduledWeekdays,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (scheduledWeekdays.present) {
      map['scheduled_weekdays'] = Variable<String>(
        $RoutineDaysTable.$converterscheduledWeekdays.toSql(
          scheduledWeekdays.value,
        ),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineDaysCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('routineId: $routineId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('scheduledWeekdays: $scheduledWeekdays, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineExercisesTable extends RoutineExercises
    with TableInfo<$RoutineExercisesTable, RoutineExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local-user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routineDayIdMeta = const VerificationMeta(
    'routineDayId',
  );
  @override
  late final GeneratedColumn<String> routineDayId = GeneratedColumn<String>(
    'routine_day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_days (id)',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetSetsMeta = const VerificationMeta(
    'targetSets',
  );
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
    'target_sets',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetRepsMinMeta = const VerificationMeta(
    'targetRepsMin',
  );
  @override
  late final GeneratedColumn<int> targetRepsMin = GeneratedColumn<int>(
    'target_reps_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetRepsMaxMeta = const VerificationMeta(
    'targetRepsMax',
  );
  @override
  late final GeneratedColumn<int> targetRepsMax = GeneratedColumn<int>(
    'target_reps_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetWeightGramsMeta = const VerificationMeta(
    'targetWeightGrams',
  );
  @override
  late final GeneratedColumn<int> targetWeightGrams = GeneratedColumn<int>(
    'target_weight_grams',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetRpeMeta = const VerificationMeta(
    'targetRpe',
  );
  @override
  late final GeneratedColumn<double> targetRpe = GeneratedColumn<double>(
    'target_rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _progressionRuleMeta = const VerificationMeta(
    'progressionRule',
  );
  @override
  late final GeneratedColumn<String> progressionRule = GeneratedColumn<String>(
    'progression_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    routineDayId,
    exerciseId,
    position,
    groupId,
    targetSets,
    targetRepsMin,
    targetRepsMax,
    targetWeightGrams,
    targetRpe,
    restSeconds,
    progressionRule,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('routine_day_id')) {
      context.handle(
        _routineDayIdMeta,
        routineDayId.isAcceptableOrUnknown(
          data['routine_day_id']!,
          _routineDayIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routineDayIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('target_sets')) {
      context.handle(
        _targetSetsMeta,
        targetSets.isAcceptableOrUnknown(data['target_sets']!, _targetSetsMeta),
      );
    }
    if (data.containsKey('target_reps_min')) {
      context.handle(
        _targetRepsMinMeta,
        targetRepsMin.isAcceptableOrUnknown(
          data['target_reps_min']!,
          _targetRepsMinMeta,
        ),
      );
    }
    if (data.containsKey('target_reps_max')) {
      context.handle(
        _targetRepsMaxMeta,
        targetRepsMax.isAcceptableOrUnknown(
          data['target_reps_max']!,
          _targetRepsMaxMeta,
        ),
      );
    }
    if (data.containsKey('target_weight_grams')) {
      context.handle(
        _targetWeightGramsMeta,
        targetWeightGrams.isAcceptableOrUnknown(
          data['target_weight_grams']!,
          _targetWeightGramsMeta,
        ),
      );
    }
    if (data.containsKey('target_rpe')) {
      context.handle(
        _targetRpeMeta,
        targetRpe.isAcceptableOrUnknown(data['target_rpe']!, _targetRpeMeta),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    }
    if (data.containsKey('progression_rule')) {
      context.handle(
        _progressionRuleMeta,
        progressionRule.isAcceptableOrUnknown(
          data['progression_rule']!,
          _progressionRuleMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      routineDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_day_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      targetSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_sets'],
      ),
      targetRepsMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps_min'],
      ),
      targetRepsMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps_max'],
      ),
      targetWeightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_weight_grams'],
      ),
      targetRpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_rpe'],
      ),
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      ),
      progressionRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}progression_rule'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $RoutineExercisesTable createAlias(String alias) {
    return $RoutineExercisesTable(attachedDatabase, alias);
  }
}

class RoutineExercise extends DataClass implements Insertable<RoutineExercise> {
  /// UUID v4, generated client-side.
  ///
  /// Not an autoincrementing integer: an ID that exists before the insert
  /// completes lets the UI render optimistically, which matters directly for
  /// write-through set logging (`F-LOG-007`), and removes the collision problem
  /// from any future sync.
  final String id;

  /// Constant `'local-user'` for now. Adding a `NOT NULL` foreign key to
  /// populated tables later is painful; adding a column that is already there
  /// and already correct is free.
  final String userId;

  /// UTC epoch milliseconds.
  final int createdAt;

  /// UTC epoch milliseconds, rewritten on **every** modification. The basis for
  /// last-write-wins resolution if sync ever ships.
  final int updatedAt;

  /// Soft-delete tombstone. **Nothing is ever hard-deleted.**
  ///
  /// Every read filters `deleted_at IS NULL`. A query that forgets silently
  /// resurrects deleted rows — the single most likely bug this schema
  /// introduces, which is why the filter is centralised in the DAOs rather than
  /// written per query.
  final int? deletedAt;
  final String routineDayId;
  final String exerciseId;
  final int position;

  /// Same value = same superset (`F-ROU-005`). Null = standalone.
  final String? groupId;
  final int? targetSets;

  /// Rep **ranges**, not single numbers — real programming says 8-12, and
  /// collapsing that to one value is what makes most template features useless.
  final int? targetRepsMin;
  final int? targetRepsMax;
  final int? targetWeightGrams;
  final double? targetRpe;
  final int? restSeconds;

  /// JSON-serialised progression rule (`F-PRG-001`).
  final String? progressionRule;
  final String? notes;
  const RoutineExercise({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.routineDayId,
    required this.exerciseId,
    required this.position,
    this.groupId,
    this.targetSets,
    this.targetRepsMin,
    this.targetRepsMax,
    this.targetWeightGrams,
    this.targetRpe,
    this.restSeconds,
    this.progressionRule,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['routine_day_id'] = Variable<String>(routineDayId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    if (!nullToAbsent || targetSets != null) {
      map['target_sets'] = Variable<int>(targetSets);
    }
    if (!nullToAbsent || targetRepsMin != null) {
      map['target_reps_min'] = Variable<int>(targetRepsMin);
    }
    if (!nullToAbsent || targetRepsMax != null) {
      map['target_reps_max'] = Variable<int>(targetRepsMax);
    }
    if (!nullToAbsent || targetWeightGrams != null) {
      map['target_weight_grams'] = Variable<int>(targetWeightGrams);
    }
    if (!nullToAbsent || targetRpe != null) {
      map['target_rpe'] = Variable<double>(targetRpe);
    }
    if (!nullToAbsent || restSeconds != null) {
      map['rest_seconds'] = Variable<int>(restSeconds);
    }
    if (!nullToAbsent || progressionRule != null) {
      map['progression_rule'] = Variable<String>(progressionRule);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  RoutineExercisesCompanion toCompanion(bool nullToAbsent) {
    return RoutineExercisesCompanion(
      id: Value(id),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      routineDayId: Value(routineDayId),
      exerciseId: Value(exerciseId),
      position: Value(position),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      targetSets: targetSets == null && nullToAbsent
          ? const Value.absent()
          : Value(targetSets),
      targetRepsMin: targetRepsMin == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRepsMin),
      targetRepsMax: targetRepsMax == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRepsMax),
      targetWeightGrams: targetWeightGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeightGrams),
      targetRpe: targetRpe == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRpe),
      restSeconds: restSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restSeconds),
      progressionRule: progressionRule == null && nullToAbsent
          ? const Value.absent()
          : Value(progressionRule),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory RoutineExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineExercise(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      routineDayId: serializer.fromJson<String>(json['routineDayId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      position: serializer.fromJson<int>(json['position']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      targetSets: serializer.fromJson<int?>(json['targetSets']),
      targetRepsMin: serializer.fromJson<int?>(json['targetRepsMin']),
      targetRepsMax: serializer.fromJson<int?>(json['targetRepsMax']),
      targetWeightGrams: serializer.fromJson<int?>(json['targetWeightGrams']),
      targetRpe: serializer.fromJson<double?>(json['targetRpe']),
      restSeconds: serializer.fromJson<int?>(json['restSeconds']),
      progressionRule: serializer.fromJson<String?>(json['progressionRule']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'routineDayId': serializer.toJson<String>(routineDayId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'position': serializer.toJson<int>(position),
      'groupId': serializer.toJson<String?>(groupId),
      'targetSets': serializer.toJson<int?>(targetSets),
      'targetRepsMin': serializer.toJson<int?>(targetRepsMin),
      'targetRepsMax': serializer.toJson<int?>(targetRepsMax),
      'targetWeightGrams': serializer.toJson<int?>(targetWeightGrams),
      'targetRpe': serializer.toJson<double?>(targetRpe),
      'restSeconds': serializer.toJson<int?>(restSeconds),
      'progressionRule': serializer.toJson<String?>(progressionRule),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  RoutineExercise copyWith({
    String? id,
    String? userId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? routineDayId,
    String? exerciseId,
    int? position,
    Value<String?> groupId = const Value.absent(),
    Value<int?> targetSets = const Value.absent(),
    Value<int?> targetRepsMin = const Value.absent(),
    Value<int?> targetRepsMax = const Value.absent(),
    Value<int?> targetWeightGrams = const Value.absent(),
    Value<double?> targetRpe = const Value.absent(),
    Value<int?> restSeconds = const Value.absent(),
    Value<String?> progressionRule = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => RoutineExercise(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    routineDayId: routineDayId ?? this.routineDayId,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
    groupId: groupId.present ? groupId.value : this.groupId,
    targetSets: targetSets.present ? targetSets.value : this.targetSets,
    targetRepsMin: targetRepsMin.present
        ? targetRepsMin.value
        : this.targetRepsMin,
    targetRepsMax: targetRepsMax.present
        ? targetRepsMax.value
        : this.targetRepsMax,
    targetWeightGrams: targetWeightGrams.present
        ? targetWeightGrams.value
        : this.targetWeightGrams,
    targetRpe: targetRpe.present ? targetRpe.value : this.targetRpe,
    restSeconds: restSeconds.present ? restSeconds.value : this.restSeconds,
    progressionRule: progressionRule.present
        ? progressionRule.value
        : this.progressionRule,
    notes: notes.present ? notes.value : this.notes,
  );
  RoutineExercise copyWithCompanion(RoutineExercisesCompanion data) {
    return RoutineExercise(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      routineDayId: data.routineDayId.present
          ? data.routineDayId.value
          : this.routineDayId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      position: data.position.present ? data.position.value : this.position,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      targetSets: data.targetSets.present
          ? data.targetSets.value
          : this.targetSets,
      targetRepsMin: data.targetRepsMin.present
          ? data.targetRepsMin.value
          : this.targetRepsMin,
      targetRepsMax: data.targetRepsMax.present
          ? data.targetRepsMax.value
          : this.targetRepsMax,
      targetWeightGrams: data.targetWeightGrams.present
          ? data.targetWeightGrams.value
          : this.targetWeightGrams,
      targetRpe: data.targetRpe.present ? data.targetRpe.value : this.targetRpe,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
      progressionRule: data.progressionRule.present
          ? data.progressionRule.value
          : this.progressionRule,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineExercise(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('routineDayId: $routineDayId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('groupId: $groupId, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetRepsMin: $targetRepsMin, ')
          ..write('targetRepsMax: $targetRepsMax, ')
          ..write('targetWeightGrams: $targetWeightGrams, ')
          ..write('targetRpe: $targetRpe, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('progressionRule: $progressionRule, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    routineDayId,
    exerciseId,
    position,
    groupId,
    targetSets,
    targetRepsMin,
    targetRepsMax,
    targetWeightGrams,
    targetRpe,
    restSeconds,
    progressionRule,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineExercise &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.routineDayId == this.routineDayId &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position &&
          other.groupId == this.groupId &&
          other.targetSets == this.targetSets &&
          other.targetRepsMin == this.targetRepsMin &&
          other.targetRepsMax == this.targetRepsMax &&
          other.targetWeightGrams == this.targetWeightGrams &&
          other.targetRpe == this.targetRpe &&
          other.restSeconds == this.restSeconds &&
          other.progressionRule == this.progressionRule &&
          other.notes == this.notes);
}

class RoutineExercisesCompanion extends UpdateCompanion<RoutineExercise> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> routineDayId;
  final Value<String> exerciseId;
  final Value<int> position;
  final Value<String?> groupId;
  final Value<int?> targetSets;
  final Value<int?> targetRepsMin;
  final Value<int?> targetRepsMax;
  final Value<int?> targetWeightGrams;
  final Value<double?> targetRpe;
  final Value<int?> restSeconds;
  final Value<String?> progressionRule;
  final Value<String?> notes;
  final Value<int> rowid;
  const RoutineExercisesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.routineDayId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.groupId = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetRepsMin = const Value.absent(),
    this.targetRepsMax = const Value.absent(),
    this.targetWeightGrams = const Value.absent(),
    this.targetRpe = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.progressionRule = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineExercisesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String routineDayId,
    required String exerciseId,
    required int position,
    this.groupId = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetRepsMin = const Value.absent(),
    this.targetRepsMax = const Value.absent(),
    this.targetWeightGrams = const Value.absent(),
    this.targetRpe = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.progressionRule = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       routineDayId = Value(routineDayId),
       exerciseId = Value(exerciseId),
       position = Value(position);
  static Insertable<RoutineExercise> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? routineDayId,
    Expression<String>? exerciseId,
    Expression<int>? position,
    Expression<String>? groupId,
    Expression<int>? targetSets,
    Expression<int>? targetRepsMin,
    Expression<int>? targetRepsMax,
    Expression<int>? targetWeightGrams,
    Expression<double>? targetRpe,
    Expression<int>? restSeconds,
    Expression<String>? progressionRule,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (routineDayId != null) 'routine_day_id': routineDayId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
      if (groupId != null) 'group_id': groupId,
      if (targetSets != null) 'target_sets': targetSets,
      if (targetRepsMin != null) 'target_reps_min': targetRepsMin,
      if (targetRepsMax != null) 'target_reps_max': targetRepsMax,
      if (targetWeightGrams != null) 'target_weight_grams': targetWeightGrams,
      if (targetRpe != null) 'target_rpe': targetRpe,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (progressionRule != null) 'progression_rule': progressionRule,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? routineDayId,
    Value<String>? exerciseId,
    Value<int>? position,
    Value<String?>? groupId,
    Value<int?>? targetSets,
    Value<int?>? targetRepsMin,
    Value<int?>? targetRepsMax,
    Value<int?>? targetWeightGrams,
    Value<double?>? targetRpe,
    Value<int?>? restSeconds,
    Value<String?>? progressionRule,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return RoutineExercisesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      routineDayId: routineDayId ?? this.routineDayId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      groupId: groupId ?? this.groupId,
      targetSets: targetSets ?? this.targetSets,
      targetRepsMin: targetRepsMin ?? this.targetRepsMin,
      targetRepsMax: targetRepsMax ?? this.targetRepsMax,
      targetWeightGrams: targetWeightGrams ?? this.targetWeightGrams,
      targetRpe: targetRpe ?? this.targetRpe,
      restSeconds: restSeconds ?? this.restSeconds,
      progressionRule: progressionRule ?? this.progressionRule,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (routineDayId.present) {
      map['routine_day_id'] = Variable<String>(routineDayId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (targetRepsMin.present) {
      map['target_reps_min'] = Variable<int>(targetRepsMin.value);
    }
    if (targetRepsMax.present) {
      map['target_reps_max'] = Variable<int>(targetRepsMax.value);
    }
    if (targetWeightGrams.present) {
      map['target_weight_grams'] = Variable<int>(targetWeightGrams.value);
    }
    if (targetRpe.present) {
      map['target_rpe'] = Variable<double>(targetRpe.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (progressionRule.present) {
      map['progression_rule'] = Variable<String>(progressionRule.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineExercisesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('routineDayId: $routineDayId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('groupId: $groupId, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetRepsMin: $targetRepsMin, ')
          ..write('targetRepsMax: $targetRepsMax, ')
          ..write('targetWeightGrams: $targetWeightGrams, ')
          ..write('targetRpe: $targetRpe, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('progressionRule: $progressionRule, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, Workout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local-user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceRoutineDayIdMeta =
      const VerificationMeta('sourceRoutineDayId');
  @override
  late final GeneratedColumn<String> sourceRoutineDayId =
      GeneratedColumn<String>(
        'source_routine_day_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES routine_days (id)',
        ),
      );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtTzOffsetMinutesMeta =
      const VerificationMeta('startedAtTzOffsetMinutes');
  @override
  late final GeneratedColumn<int> startedAtTzOffsetMinutes =
      GeneratedColumn<int>(
        'started_at_tz_offset_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyweightGramsMeta = const VerificationMeta(
    'bodyweightGrams',
  );
  @override
  late final GeneratedColumn<int> bodyweightGrams = GeneratedColumn<int>(
    'bodyweight_grams',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _perceivedFatigueMeta = const VerificationMeta(
    'perceivedFatigue',
  );
  @override
  late final GeneratedColumn<int> perceivedFatigue = GeneratedColumn<int>(
    'perceived_fatigue',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    sourceRoutineDayId,
    startedAt,
    startedAtTzOffsetMinutes,
    endedAt,
    notes,
    bodyweightGrams,
    perceivedFatigue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Workout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source_routine_day_id')) {
      context.handle(
        _sourceRoutineDayIdMeta,
        sourceRoutineDayId.isAcceptableOrUnknown(
          data['source_routine_day_id']!,
          _sourceRoutineDayIdMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('started_at_tz_offset_minutes')) {
      context.handle(
        _startedAtTzOffsetMinutesMeta,
        startedAtTzOffsetMinutes.isAcceptableOrUnknown(
          data['started_at_tz_offset_minutes']!,
          _startedAtTzOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtTzOffsetMinutesMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('bodyweight_grams')) {
      context.handle(
        _bodyweightGramsMeta,
        bodyweightGrams.isAcceptableOrUnknown(
          data['bodyweight_grams']!,
          _bodyweightGramsMeta,
        ),
      );
    }
    if (data.containsKey('perceived_fatigue')) {
      context.handle(
        _perceivedFatigueMeta,
        perceivedFatigue.isAcceptableOrUnknown(
          data['perceived_fatigue']!,
          _perceivedFatigueMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workout(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sourceRoutineDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_routine_day_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      startedAtTzOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_tz_offset_minutes'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      bodyweightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bodyweight_grams'],
      ),
      perceivedFatigue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}perceived_fatigue'],
      ),
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class Workout extends DataClass implements Insertable<Workout> {
  /// UUID v4, generated client-side.
  ///
  /// Not an autoincrementing integer: an ID that exists before the insert
  /// completes lets the UI render optimistically, which matters directly for
  /// write-through set logging (`F-LOG-007`), and removes the collision problem
  /// from any future sync.
  final String id;

  /// Constant `'local-user'` for now. Adding a `NOT NULL` foreign key to
  /// populated tables later is painful; adding a column that is already there
  /// and already correct is free.
  final String userId;

  /// UTC epoch milliseconds.
  final int createdAt;

  /// UTC epoch milliseconds, rewritten on **every** modification. The basis for
  /// last-write-wins resolution if sync ever ships.
  final int updatedAt;

  /// Soft-delete tombstone. **Nothing is ever hard-deleted.**
  ///
  /// Every read filters `deleted_at IS NULL`. A query that forgets silently
  /// resurrects deleted rows — the single most likely bug this schema
  /// introduces, which is why the filter is centralised in the DAOs rather than
  /// written per query.
  final int? deletedAt;
  final String name;

  /// Provenance only. Nullable, and never used for display.
  final String? sourceRoutineDayId;

  /// UTC epoch milliseconds.
  final int startedAt;

  /// Local UTC offset in minutes at the moment of starting (ADR-0008).
  ///
  /// Determines the session's **local** calendar date, which is what every
  /// weekly aggregate and streak groups by. A 22:00 session in UTC+10 is not
  /// the next day, and this cannot be reconstructed from UTC alone.
  final int startedAtTzOffsetMinutes;

  /// Null = in progress. At most one row may be null at a time (`F-LOG-007`),
  /// which is what makes crash recovery a query rather than a state restore.
  final int? endedAt;
  final String? notes;

  /// Captured at session time; needed for bodyweight-loaded exercises
  /// (`F-LOG-019`).
  final int? bodyweightGrams;
  final int? perceivedFatigue;
  const Workout({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    this.sourceRoutineDayId,
    required this.startedAt,
    required this.startedAtTzOffsetMinutes,
    this.endedAt,
    this.notes,
    this.bodyweightGrams,
    this.perceivedFatigue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sourceRoutineDayId != null) {
      map['source_routine_day_id'] = Variable<String>(sourceRoutineDayId);
    }
    map['started_at'] = Variable<int>(startedAt);
    map['started_at_tz_offset_minutes'] = Variable<int>(
      startedAtTzOffsetMinutes,
    );
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || bodyweightGrams != null) {
      map['bodyweight_grams'] = Variable<int>(bodyweightGrams);
    }
    if (!nullToAbsent || perceivedFatigue != null) {
      map['perceived_fatigue'] = Variable<int>(perceivedFatigue);
    }
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      sourceRoutineDayId: sourceRoutineDayId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRoutineDayId),
      startedAt: Value(startedAt),
      startedAtTzOffsetMinutes: Value(startedAtTzOffsetMinutes),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      bodyweightGrams: bodyweightGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyweightGrams),
      perceivedFatigue: perceivedFatigue == null && nullToAbsent
          ? const Value.absent()
          : Value(perceivedFatigue),
    );
  }

  factory Workout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workout(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      sourceRoutineDayId: serializer.fromJson<String?>(
        json['sourceRoutineDayId'],
      ),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      startedAtTzOffsetMinutes: serializer.fromJson<int>(
        json['startedAtTzOffsetMinutes'],
      ),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      bodyweightGrams: serializer.fromJson<int?>(json['bodyweightGrams']),
      perceivedFatigue: serializer.fromJson<int?>(json['perceivedFatigue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'sourceRoutineDayId': serializer.toJson<String?>(sourceRoutineDayId),
      'startedAt': serializer.toJson<int>(startedAt),
      'startedAtTzOffsetMinutes': serializer.toJson<int>(
        startedAtTzOffsetMinutes,
      ),
      'endedAt': serializer.toJson<int?>(endedAt),
      'notes': serializer.toJson<String?>(notes),
      'bodyweightGrams': serializer.toJson<int?>(bodyweightGrams),
      'perceivedFatigue': serializer.toJson<int?>(perceivedFatigue),
    };
  }

  Workout copyWith({
    String? id,
    String? userId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? name,
    Value<String?> sourceRoutineDayId = const Value.absent(),
    int? startedAt,
    int? startedAtTzOffsetMinutes,
    Value<int?> endedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> bodyweightGrams = const Value.absent(),
    Value<int?> perceivedFatigue = const Value.absent(),
  }) => Workout(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    sourceRoutineDayId: sourceRoutineDayId.present
        ? sourceRoutineDayId.value
        : this.sourceRoutineDayId,
    startedAt: startedAt ?? this.startedAt,
    startedAtTzOffsetMinutes:
        startedAtTzOffsetMinutes ?? this.startedAtTzOffsetMinutes,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    notes: notes.present ? notes.value : this.notes,
    bodyweightGrams: bodyweightGrams.present
        ? bodyweightGrams.value
        : this.bodyweightGrams,
    perceivedFatigue: perceivedFatigue.present
        ? perceivedFatigue.value
        : this.perceivedFatigue,
  );
  Workout copyWithCompanion(WorkoutsCompanion data) {
    return Workout(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      sourceRoutineDayId: data.sourceRoutineDayId.present
          ? data.sourceRoutineDayId.value
          : this.sourceRoutineDayId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      startedAtTzOffsetMinutes: data.startedAtTzOffsetMinutes.present
          ? data.startedAtTzOffsetMinutes.value
          : this.startedAtTzOffsetMinutes,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      bodyweightGrams: data.bodyweightGrams.present
          ? data.bodyweightGrams.value
          : this.bodyweightGrams,
      perceivedFatigue: data.perceivedFatigue.present
          ? data.perceivedFatigue.value
          : this.perceivedFatigue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workout(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('sourceRoutineDayId: $sourceRoutineDayId, ')
          ..write('startedAt: $startedAt, ')
          ..write('startedAtTzOffsetMinutes: $startedAtTzOffsetMinutes, ')
          ..write('endedAt: $endedAt, ')
          ..write('notes: $notes, ')
          ..write('bodyweightGrams: $bodyweightGrams, ')
          ..write('perceivedFatigue: $perceivedFatigue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    sourceRoutineDayId,
    startedAt,
    startedAtTzOffsetMinutes,
    endedAt,
    notes,
    bodyweightGrams,
    perceivedFatigue,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workout &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.sourceRoutineDayId == this.sourceRoutineDayId &&
          other.startedAt == this.startedAt &&
          other.startedAtTzOffsetMinutes == this.startedAtTzOffsetMinutes &&
          other.endedAt == this.endedAt &&
          other.notes == this.notes &&
          other.bodyweightGrams == this.bodyweightGrams &&
          other.perceivedFatigue == this.perceivedFatigue);
}

class WorkoutsCompanion extends UpdateCompanion<Workout> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> name;
  final Value<String?> sourceRoutineDayId;
  final Value<int> startedAt;
  final Value<int> startedAtTzOffsetMinutes;
  final Value<int?> endedAt;
  final Value<String?> notes;
  final Value<int?> bodyweightGrams;
  final Value<int?> perceivedFatigue;
  final Value<int> rowid;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.sourceRoutineDayId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.startedAtTzOffsetMinutes = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.bodyweightGrams = const Value.absent(),
    this.perceivedFatigue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    this.sourceRoutineDayId = const Value.absent(),
    required int startedAt,
    required int startedAtTzOffsetMinutes,
    this.endedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.bodyweightGrams = const Value.absent(),
    this.perceivedFatigue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       startedAt = Value(startedAt),
       startedAtTzOffsetMinutes = Value(startedAtTzOffsetMinutes);
  static Insertable<Workout> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? name,
    Expression<String>? sourceRoutineDayId,
    Expression<int>? startedAt,
    Expression<int>? startedAtTzOffsetMinutes,
    Expression<int>? endedAt,
    Expression<String>? notes,
    Expression<int>? bodyweightGrams,
    Expression<int>? perceivedFatigue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (sourceRoutineDayId != null)
        'source_routine_day_id': sourceRoutineDayId,
      if (startedAt != null) 'started_at': startedAt,
      if (startedAtTzOffsetMinutes != null)
        'started_at_tz_offset_minutes': startedAtTzOffsetMinutes,
      if (endedAt != null) 'ended_at': endedAt,
      if (notes != null) 'notes': notes,
      if (bodyweightGrams != null) 'bodyweight_grams': bodyweightGrams,
      if (perceivedFatigue != null) 'perceived_fatigue': perceivedFatigue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? name,
    Value<String?>? sourceRoutineDayId,
    Value<int>? startedAt,
    Value<int>? startedAtTzOffsetMinutes,
    Value<int?>? endedAt,
    Value<String?>? notes,
    Value<int?>? bodyweightGrams,
    Value<int?>? perceivedFatigue,
    Value<int>? rowid,
  }) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      sourceRoutineDayId: sourceRoutineDayId ?? this.sourceRoutineDayId,
      startedAt: startedAt ?? this.startedAt,
      startedAtTzOffsetMinutes:
          startedAtTzOffsetMinutes ?? this.startedAtTzOffsetMinutes,
      endedAt: endedAt ?? this.endedAt,
      notes: notes ?? this.notes,
      bodyweightGrams: bodyweightGrams ?? this.bodyweightGrams,
      perceivedFatigue: perceivedFatigue ?? this.perceivedFatigue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sourceRoutineDayId.present) {
      map['source_routine_day_id'] = Variable<String>(sourceRoutineDayId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (startedAtTzOffsetMinutes.present) {
      map['started_at_tz_offset_minutes'] = Variable<int>(
        startedAtTzOffsetMinutes.value,
      );
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (bodyweightGrams.present) {
      map['bodyweight_grams'] = Variable<int>(bodyweightGrams.value);
    }
    if (perceivedFatigue.present) {
      map['perceived_fatigue'] = Variable<int>(perceivedFatigue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('sourceRoutineDayId: $sourceRoutineDayId, ')
          ..write('startedAt: $startedAt, ')
          ..write('startedAtTzOffsetMinutes: $startedAtTzOffsetMinutes, ')
          ..write('endedAt: $endedAt, ')
          ..write('notes: $notes, ')
          ..write('bodyweightGrams: $bodyweightGrams, ')
          ..write('perceivedFatigue: $perceivedFatigue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutExercisesTable extends WorkoutExercises
    with TableInfo<$WorkoutExercisesTable, WorkoutExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local-user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workouts (id)',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetSnapshotMeta = const VerificationMeta(
    'targetSnapshot',
  );
  @override
  late final GeneratedColumn<String> targetSnapshot = GeneratedColumn<String>(
    'target_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    workoutId,
    exerciseId,
    position,
    groupId,
    notes,
    targetSnapshot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('target_snapshot')) {
      context.handle(
        _targetSnapshotMeta,
        targetSnapshot.isAcceptableOrUnknown(
          data['target_snapshot']!,
          _targetSnapshotMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      targetSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_snapshot'],
      ),
    );
  }

  @override
  $WorkoutExercisesTable createAlias(String alias) {
    return $WorkoutExercisesTable(attachedDatabase, alias);
  }
}

class WorkoutExercise extends DataClass implements Insertable<WorkoutExercise> {
  /// UUID v4, generated client-side.
  ///
  /// Not an autoincrementing integer: an ID that exists before the insert
  /// completes lets the UI render optimistically, which matters directly for
  /// write-through set logging (`F-LOG-007`), and removes the collision problem
  /// from any future sync.
  final String id;

  /// Constant `'local-user'` for now. Adding a `NOT NULL` foreign key to
  /// populated tables later is painful; adding a column that is already there
  /// and already correct is free.
  final String userId;

  /// UTC epoch milliseconds.
  final int createdAt;

  /// UTC epoch milliseconds, rewritten on **every** modification. The basis for
  /// last-write-wins resolution if sync ever ships.
  final int updatedAt;

  /// Soft-delete tombstone. **Nothing is ever hard-deleted.**
  ///
  /// Every read filters `deleted_at IS NULL`. A query that forgets silently
  /// resurrects deleted rows — the single most likely bug this schema
  /// introduces, which is why the filter is centralised in the DAOs rather than
  /// written per query.
  final int? deletedAt;
  final String workoutId;
  final String exerciseId;
  final int position;

  /// Snapshotted superset grouping.
  final String? groupId;

  /// Session-specific, distinct from the exercise's persistent sticky note.
  final String? notes;

  /// JSON of the routine targets as they were at start — what progression
  /// proposed, kept so it can be audited against what actually happened
  /// (`F-PRG-008`).
  final String? targetSnapshot;
  const WorkoutExercise({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.workoutId,
    required this.exerciseId,
    required this.position,
    this.groupId,
    this.notes,
    this.targetSnapshot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['workout_id'] = Variable<String>(workoutId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || targetSnapshot != null) {
      map['target_snapshot'] = Variable<String>(targetSnapshot);
    }
    return map;
  }

  WorkoutExercisesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutExercisesCompanion(
      id: Value(id),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      workoutId: Value(workoutId),
      exerciseId: Value(exerciseId),
      position: Value(position),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      targetSnapshot: targetSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(targetSnapshot),
    );
  }

  factory WorkoutExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutExercise(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      workoutId: serializer.fromJson<String>(json['workoutId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      position: serializer.fromJson<int>(json['position']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      notes: serializer.fromJson<String?>(json['notes']),
      targetSnapshot: serializer.fromJson<String?>(json['targetSnapshot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'workoutId': serializer.toJson<String>(workoutId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'position': serializer.toJson<int>(position),
      'groupId': serializer.toJson<String?>(groupId),
      'notes': serializer.toJson<String?>(notes),
      'targetSnapshot': serializer.toJson<String?>(targetSnapshot),
    };
  }

  WorkoutExercise copyWith({
    String? id,
    String? userId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? workoutId,
    String? exerciseId,
    int? position,
    Value<String?> groupId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> targetSnapshot = const Value.absent(),
  }) => WorkoutExercise(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    workoutId: workoutId ?? this.workoutId,
    exerciseId: exerciseId ?? this.exerciseId,
    position: position ?? this.position,
    groupId: groupId.present ? groupId.value : this.groupId,
    notes: notes.present ? notes.value : this.notes,
    targetSnapshot: targetSnapshot.present
        ? targetSnapshot.value
        : this.targetSnapshot,
  );
  WorkoutExercise copyWithCompanion(WorkoutExercisesCompanion data) {
    return WorkoutExercise(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      position: data.position.present ? data.position.value : this.position,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      notes: data.notes.present ? data.notes.value : this.notes,
      targetSnapshot: data.targetSnapshot.present
          ? data.targetSnapshot.value
          : this.targetSnapshot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExercise(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('groupId: $groupId, ')
          ..write('notes: $notes, ')
          ..write('targetSnapshot: $targetSnapshot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    workoutId,
    exerciseId,
    position,
    groupId,
    notes,
    targetSnapshot,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutExercise &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.workoutId == this.workoutId &&
          other.exerciseId == this.exerciseId &&
          other.position == this.position &&
          other.groupId == this.groupId &&
          other.notes == this.notes &&
          other.targetSnapshot == this.targetSnapshot);
}

class WorkoutExercisesCompanion extends UpdateCompanion<WorkoutExercise> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> workoutId;
  final Value<String> exerciseId;
  final Value<int> position;
  final Value<String?> groupId;
  final Value<String?> notes;
  final Value<String?> targetSnapshot;
  final Value<int> rowid;
  const WorkoutExercisesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.groupId = const Value.absent(),
    this.notes = const Value.absent(),
    this.targetSnapshot = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutExercisesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String workoutId,
    required String exerciseId,
    required int position,
    this.groupId = const Value.absent(),
    this.notes = const Value.absent(),
    this.targetSnapshot = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       workoutId = Value(workoutId),
       exerciseId = Value(exerciseId),
       position = Value(position);
  static Insertable<WorkoutExercise> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? workoutId,
    Expression<String>? exerciseId,
    Expression<int>? position,
    Expression<String>? groupId,
    Expression<String>? notes,
    Expression<String>? targetSnapshot,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (workoutId != null) 'workout_id': workoutId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (position != null) 'position': position,
      if (groupId != null) 'group_id': groupId,
      if (notes != null) 'notes': notes,
      if (targetSnapshot != null) 'target_snapshot': targetSnapshot,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? workoutId,
    Value<String>? exerciseId,
    Value<int>? position,
    Value<String?>? groupId,
    Value<String?>? notes,
    Value<String?>? targetSnapshot,
    Value<int>? rowid,
  }) {
    return WorkoutExercisesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      position: position ?? this.position,
      groupId: groupId ?? this.groupId,
      notes: notes ?? this.notes,
      targetSnapshot: targetSnapshot ?? this.targetSnapshot,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (targetSnapshot.present) {
      map['target_snapshot'] = Variable<String>(targetSnapshot.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExercisesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('workoutId: $workoutId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('position: $position, ')
          ..write('groupId: $groupId, ')
          ..write('notes: $notes, ')
          ..write('targetSnapshot: $targetSnapshot, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SetsTable extends Sets with TableInfo<$SetsTable, WorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local-user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workoutExerciseIdMeta = const VerificationMeta(
    'workoutExerciseId',
  );
  @override
  late final GeneratedColumn<String> workoutExerciseId =
      GeneratedColumn<String>(
        'workout_exercise_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES workout_exercises (id)',
        ),
      );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SetType, String> setType =
      GeneratedColumn<String>(
        'set_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('working'),
      ).withConverter<SetType>($SetsTable.$convertersetType);
  static const VerificationMeta _weightGramsMeta = const VerificationMeta(
    'weightGrams',
  );
  @override
  late final GeneratedColumn<int> weightGrams = GeneratedColumn<int>(
    'weight_grams',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<double> rpe = GeneratedColumn<double>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetresMeta = const VerificationMeta(
    'distanceMetres',
  );
  @override
  late final GeneratedColumn<int> distanceMetres = GeneratedColumn<int>(
    'distance_metres',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtTzOffsetMinutesMeta =
      const VerificationMeta('completedAtTzOffsetMinutes');
  @override
  late final GeneratedColumn<int> completedAtTzOffsetMinutes =
      GeneratedColumn<int>(
        'completed_at_tz_offset_minutes',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _restTakenSecondsMeta = const VerificationMeta(
    'restTakenSeconds',
  );
  @override
  late final GeneratedColumn<int> restTakenSeconds = GeneratedColumn<int>(
    'rest_taken_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    workoutExerciseId,
    position,
    setType,
    weightGrams,
    reps,
    rpe,
    distanceMetres,
    durationSeconds,
    isCompleted,
    completedAt,
    completedAtTzOffsetMinutes,
    restTakenSeconds,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('workout_exercise_id')) {
      context.handle(
        _workoutExerciseIdMeta,
        workoutExerciseId.isAcceptableOrUnknown(
          data['workout_exercise_id']!,
          _workoutExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutExerciseIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('weight_grams')) {
      context.handle(
        _weightGramsMeta,
        weightGrams.isAcceptableOrUnknown(
          data['weight_grams']!,
          _weightGramsMeta,
        ),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('distance_metres')) {
      context.handle(
        _distanceMetresMeta,
        distanceMetres.isAcceptableOrUnknown(
          data['distance_metres']!,
          _distanceMetresMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('completed_at_tz_offset_minutes')) {
      context.handle(
        _completedAtTzOffsetMinutesMeta,
        completedAtTzOffsetMinutes.isAcceptableOrUnknown(
          data['completed_at_tz_offset_minutes']!,
          _completedAtTzOffsetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('rest_taken_seconds')) {
      context.handle(
        _restTakenSecondsMeta,
        restTakenSeconds.isAcceptableOrUnknown(
          data['rest_taken_seconds']!,
          _restTakenSecondsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      workoutExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_exercise_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      setType: $SetsTable.$convertersetType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}set_type'],
        )!,
      ),
      weightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight_grams'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      ),
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rpe'],
      ),
      distanceMetres: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_metres'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      completedAtTzOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_tz_offset_minutes'],
      ),
      restTakenSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_taken_seconds'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SetsTable createAlias(String alias) {
    return $SetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SetType, String, String> $convertersetType =
      const EnumNameConverter<SetType>(SetType.values);
}

class WorkoutSet extends DataClass implements Insertable<WorkoutSet> {
  /// UUID v4, generated client-side.
  ///
  /// Not an autoincrementing integer: an ID that exists before the insert
  /// completes lets the UI render optimistically, which matters directly for
  /// write-through set logging (`F-LOG-007`), and removes the collision problem
  /// from any future sync.
  final String id;

  /// Constant `'local-user'` for now. Adding a `NOT NULL` foreign key to
  /// populated tables later is painful; adding a column that is already there
  /// and already correct is free.
  final String userId;

  /// UTC epoch milliseconds.
  final int createdAt;

  /// UTC epoch milliseconds, rewritten on **every** modification. The basis for
  /// last-write-wins resolution if sync ever ships.
  final int updatedAt;

  /// Soft-delete tombstone. **Nothing is ever hard-deleted.**
  ///
  /// Every read filters `deleted_at IS NULL`. A query that forgets silently
  /// resurrects deleted rows — the single most likely bug this schema
  /// introduces, which is why the filter is centralised in the DAOs rather than
  /// written per query.
  final int? deletedAt;
  final String workoutExerciseId;
  final int position;

  /// **Only `warmup` is excluded from analytics.** Must exist in v1: the
  /// information cannot be recovered later, and without it every volume, PR and
  /// e1RM figure is quietly wrong from the first session.
  final SetType setType;

  /// Canonical grams, and **always total load** — per-side entry is converted
  /// on input (`F-LOG-017`).
  final int? weightGrams;
  final int? reps;

  /// 6.0-10.0 in 0.5 steps (`F-LOG-014`). Nullable, and Phase 1 never populates
  /// it — but the column exists from v1, because a year of missing RPE cannot
  /// be backfilled.
  final double? rpe;
  final int? distanceMetres;
  final int? durationSeconds;

  /// A row may exist as a planned-but-unfinished target. Incomplete sets are
  /// excluded from analytics.
  final bool isCompleted;

  /// **The only way to derive actual rest intervals after the fact**
  /// (`F-TIM-007`).
  final int? completedAt;
  final int? completedAtTzOffsetMinutes;
  final int? restTakenSeconds;

  /// Free text per set (`F-LOG-023`). The catch-all for what the schema did not
  /// anticipate — "left shoulder twinged", "belt too loose". Unrecoverable: the
  /// observation exists for about ten seconds and then it is gone.
  final String? notes;
  const WorkoutSet({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.workoutExerciseId,
    required this.position,
    required this.setType,
    this.weightGrams,
    this.reps,
    this.rpe,
    this.distanceMetres,
    this.durationSeconds,
    required this.isCompleted,
    this.completedAt,
    this.completedAtTzOffsetMinutes,
    this.restTakenSeconds,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['workout_exercise_id'] = Variable<String>(workoutExerciseId);
    map['position'] = Variable<int>(position);
    {
      map['set_type'] = Variable<String>(
        $SetsTable.$convertersetType.toSql(setType),
      );
    }
    if (!nullToAbsent || weightGrams != null) {
      map['weight_grams'] = Variable<int>(weightGrams);
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<double>(rpe);
    }
    if (!nullToAbsent || distanceMetres != null) {
      map['distance_metres'] = Variable<int>(distanceMetres);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    if (!nullToAbsent || completedAtTzOffsetMinutes != null) {
      map['completed_at_tz_offset_minutes'] = Variable<int>(
        completedAtTzOffsetMinutes,
      );
    }
    if (!nullToAbsent || restTakenSeconds != null) {
      map['rest_taken_seconds'] = Variable<int>(restTakenSeconds);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SetsCompanion toCompanion(bool nullToAbsent) {
    return SetsCompanion(
      id: Value(id),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      workoutExerciseId: Value(workoutExerciseId),
      position: Value(position),
      setType: Value(setType),
      weightGrams: weightGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(weightGrams),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      distanceMetres: distanceMetres == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMetres),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      completedAtTzOffsetMinutes:
          completedAtTzOffsetMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtTzOffsetMinutes),
      restTakenSeconds: restTakenSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restTakenSeconds),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory WorkoutSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSet(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      workoutExerciseId: serializer.fromJson<String>(json['workoutExerciseId']),
      position: serializer.fromJson<int>(json['position']),
      setType: $SetsTable.$convertersetType.fromJson(
        serializer.fromJson<String>(json['setType']),
      ),
      weightGrams: serializer.fromJson<int?>(json['weightGrams']),
      reps: serializer.fromJson<int?>(json['reps']),
      rpe: serializer.fromJson<double?>(json['rpe']),
      distanceMetres: serializer.fromJson<int?>(json['distanceMetres']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      completedAtTzOffsetMinutes: serializer.fromJson<int?>(
        json['completedAtTzOffsetMinutes'],
      ),
      restTakenSeconds: serializer.fromJson<int?>(json['restTakenSeconds']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'workoutExerciseId': serializer.toJson<String>(workoutExerciseId),
      'position': serializer.toJson<int>(position),
      'setType': serializer.toJson<String>(
        $SetsTable.$convertersetType.toJson(setType),
      ),
      'weightGrams': serializer.toJson<int?>(weightGrams),
      'reps': serializer.toJson<int?>(reps),
      'rpe': serializer.toJson<double?>(rpe),
      'distanceMetres': serializer.toJson<int?>(distanceMetres),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<int?>(completedAt),
      'completedAtTzOffsetMinutes': serializer.toJson<int?>(
        completedAtTzOffsetMinutes,
      ),
      'restTakenSeconds': serializer.toJson<int?>(restTakenSeconds),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  WorkoutSet copyWith({
    String? id,
    String? userId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? workoutExerciseId,
    int? position,
    SetType? setType,
    Value<int?> weightGrams = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    Value<double?> rpe = const Value.absent(),
    Value<int?> distanceMetres = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    bool? isCompleted,
    Value<int?> completedAt = const Value.absent(),
    Value<int?> completedAtTzOffsetMinutes = const Value.absent(),
    Value<int?> restTakenSeconds = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => WorkoutSet(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
    position: position ?? this.position,
    setType: setType ?? this.setType,
    weightGrams: weightGrams.present ? weightGrams.value : this.weightGrams,
    reps: reps.present ? reps.value : this.reps,
    rpe: rpe.present ? rpe.value : this.rpe,
    distanceMetres: distanceMetres.present
        ? distanceMetres.value
        : this.distanceMetres,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    completedAtTzOffsetMinutes: completedAtTzOffsetMinutes.present
        ? completedAtTzOffsetMinutes.value
        : this.completedAtTzOffsetMinutes,
    restTakenSeconds: restTakenSeconds.present
        ? restTakenSeconds.value
        : this.restTakenSeconds,
    notes: notes.present ? notes.value : this.notes,
  );
  WorkoutSet copyWithCompanion(SetsCompanion data) {
    return WorkoutSet(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      workoutExerciseId: data.workoutExerciseId.present
          ? data.workoutExerciseId.value
          : this.workoutExerciseId,
      position: data.position.present ? data.position.value : this.position,
      setType: data.setType.present ? data.setType.value : this.setType,
      weightGrams: data.weightGrams.present
          ? data.weightGrams.value
          : this.weightGrams,
      reps: data.reps.present ? data.reps.value : this.reps,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      distanceMetres: data.distanceMetres.present
          ? data.distanceMetres.value
          : this.distanceMetres,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      completedAtTzOffsetMinutes: data.completedAtTzOffsetMinutes.present
          ? data.completedAtTzOffsetMinutes.value
          : this.completedAtTzOffsetMinutes,
      restTakenSeconds: data.restTakenSeconds.present
          ? data.restTakenSeconds.value
          : this.restTakenSeconds,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSet(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('workoutExerciseId: $workoutExerciseId, ')
          ..write('position: $position, ')
          ..write('setType: $setType, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('reps: $reps, ')
          ..write('rpe: $rpe, ')
          ..write('distanceMetres: $distanceMetres, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('completedAtTzOffsetMinutes: $completedAtTzOffsetMinutes, ')
          ..write('restTakenSeconds: $restTakenSeconds, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    workoutExerciseId,
    position,
    setType,
    weightGrams,
    reps,
    rpe,
    distanceMetres,
    durationSeconds,
    isCompleted,
    completedAt,
    completedAtTzOffsetMinutes,
    restTakenSeconds,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSet &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.workoutExerciseId == this.workoutExerciseId &&
          other.position == this.position &&
          other.setType == this.setType &&
          other.weightGrams == this.weightGrams &&
          other.reps == this.reps &&
          other.rpe == this.rpe &&
          other.distanceMetres == this.distanceMetres &&
          other.durationSeconds == this.durationSeconds &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.completedAtTzOffsetMinutes == this.completedAtTzOffsetMinutes &&
          other.restTakenSeconds == this.restTakenSeconds &&
          other.notes == this.notes);
}

class SetsCompanion extends UpdateCompanion<WorkoutSet> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> workoutExerciseId;
  final Value<int> position;
  final Value<SetType> setType;
  final Value<int?> weightGrams;
  final Value<int?> reps;
  final Value<double?> rpe;
  final Value<int?> distanceMetres;
  final Value<int?> durationSeconds;
  final Value<bool> isCompleted;
  final Value<int?> completedAt;
  final Value<int?> completedAtTzOffsetMinutes;
  final Value<int?> restTakenSeconds;
  final Value<String?> notes;
  final Value<int> rowid;
  const SetsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.workoutExerciseId = const Value.absent(),
    this.position = const Value.absent(),
    this.setType = const Value.absent(),
    this.weightGrams = const Value.absent(),
    this.reps = const Value.absent(),
    this.rpe = const Value.absent(),
    this.distanceMetres = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completedAtTzOffsetMinutes = const Value.absent(),
    this.restTakenSeconds = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SetsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String workoutExerciseId,
    required int position,
    this.setType = const Value.absent(),
    this.weightGrams = const Value.absent(),
    this.reps = const Value.absent(),
    this.rpe = const Value.absent(),
    this.distanceMetres = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completedAtTzOffsetMinutes = const Value.absent(),
    this.restTakenSeconds = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       workoutExerciseId = Value(workoutExerciseId),
       position = Value(position);
  static Insertable<WorkoutSet> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? workoutExerciseId,
    Expression<int>? position,
    Expression<String>? setType,
    Expression<int>? weightGrams,
    Expression<int>? reps,
    Expression<double>? rpe,
    Expression<int>? distanceMetres,
    Expression<int>? durationSeconds,
    Expression<bool>? isCompleted,
    Expression<int>? completedAt,
    Expression<int>? completedAtTzOffsetMinutes,
    Expression<int>? restTakenSeconds,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (workoutExerciseId != null) 'workout_exercise_id': workoutExerciseId,
      if (position != null) 'position': position,
      if (setType != null) 'set_type': setType,
      if (weightGrams != null) 'weight_grams': weightGrams,
      if (reps != null) 'reps': reps,
      if (rpe != null) 'rpe': rpe,
      if (distanceMetres != null) 'distance_metres': distanceMetres,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (completedAtTzOffsetMinutes != null)
        'completed_at_tz_offset_minutes': completedAtTzOffsetMinutes,
      if (restTakenSeconds != null) 'rest_taken_seconds': restTakenSeconds,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SetsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? workoutExerciseId,
    Value<int>? position,
    Value<SetType>? setType,
    Value<int?>? weightGrams,
    Value<int?>? reps,
    Value<double?>? rpe,
    Value<int?>? distanceMetres,
    Value<int?>? durationSeconds,
    Value<bool>? isCompleted,
    Value<int?>? completedAt,
    Value<int?>? completedAtTzOffsetMinutes,
    Value<int?>? restTakenSeconds,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return SetsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
      position: position ?? this.position,
      setType: setType ?? this.setType,
      weightGrams: weightGrams ?? this.weightGrams,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      distanceMetres: distanceMetres ?? this.distanceMetres,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      completedAtTzOffsetMinutes:
          completedAtTzOffsetMinutes ?? this.completedAtTzOffsetMinutes,
      restTakenSeconds: restTakenSeconds ?? this.restTakenSeconds,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (workoutExerciseId.present) {
      map['workout_exercise_id'] = Variable<String>(workoutExerciseId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (setType.present) {
      map['set_type'] = Variable<String>(
        $SetsTable.$convertersetType.toSql(setType.value),
      );
    }
    if (weightGrams.present) {
      map['weight_grams'] = Variable<int>(weightGrams.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<double>(rpe.value);
    }
    if (distanceMetres.present) {
      map['distance_metres'] = Variable<int>(distanceMetres.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (completedAtTzOffsetMinutes.present) {
      map['completed_at_tz_offset_minutes'] = Variable<int>(
        completedAtTzOffsetMinutes.value,
      );
    }
    if (restTakenSeconds.present) {
      map['rest_taken_seconds'] = Variable<int>(restTakenSeconds.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('workoutExerciseId: $workoutExerciseId, ')
          ..write('position: $position, ')
          ..write('setType: $setType, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('reps: $reps, ')
          ..write('rpe: $rpe, ')
          ..write('distanceMetres: $distanceMetres, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('completedAtTzOffsetMinutes: $completedAtTzOffsetMinutes, ')
          ..write('restTakenSeconds: $restTakenSeconds, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BodyMeasurementsTable extends BodyMeasurements
    with TableInfo<$BodyMeasurementsTable, BodyMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local-user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<int> measuredAt = GeneratedColumn<int>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measuredAtTzOffsetMinutesMeta =
      const VerificationMeta('measuredAtTzOffsetMinutes');
  @override
  late final GeneratedColumn<int> measuredAtTzOffsetMinutes =
      GeneratedColumn<int>(
        'measured_at_tz_offset_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<MeasurementType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MeasurementType>($BodyMeasurementsTable.$convertertype);
  static const VerificationMeta _valueCanonicalMeta = const VerificationMeta(
    'valueCanonical',
  );
  @override
  late final GeneratedColumn<int> valueCanonical = GeneratedColumn<int>(
    'value_canonical',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    measuredAt,
    measuredAtTzOffsetMinutes,
    type,
    valueCanonical,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyMeasurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('measured_at_tz_offset_minutes')) {
      context.handle(
        _measuredAtTzOffsetMinutesMeta,
        measuredAtTzOffsetMinutes.isAcceptableOrUnknown(
          data['measured_at_tz_offset_minutes']!,
          _measuredAtTzOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_measuredAtTzOffsetMinutesMeta);
    }
    if (data.containsKey('value_canonical')) {
      context.handle(
        _valueCanonicalMeta,
        valueCanonical.isAcceptableOrUnknown(
          data['value_canonical']!,
          _valueCanonicalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valueCanonicalMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}measured_at'],
      )!,
      measuredAtTzOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}measured_at_tz_offset_minutes'],
      )!,
      type: $BodyMeasurementsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      valueCanonical: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_canonical'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $BodyMeasurementsTable createAlias(String alias) {
    return $BodyMeasurementsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MeasurementType, String, String> $convertertype =
      const EnumNameConverter<MeasurementType>(MeasurementType.values);
}

class BodyMeasurement extends DataClass implements Insertable<BodyMeasurement> {
  /// UUID v4, generated client-side.
  ///
  /// Not an autoincrementing integer: an ID that exists before the insert
  /// completes lets the UI render optimistically, which matters directly for
  /// write-through set logging (`F-LOG-007`), and removes the collision problem
  /// from any future sync.
  final String id;

  /// Constant `'local-user'` for now. Adding a `NOT NULL` foreign key to
  /// populated tables later is painful; adding a column that is already there
  /// and already correct is free.
  final String userId;

  /// UTC epoch milliseconds.
  final int createdAt;

  /// UTC epoch milliseconds, rewritten on **every** modification. The basis for
  /// last-write-wins resolution if sync ever ships.
  final int updatedAt;

  /// Soft-delete tombstone. **Nothing is ever hard-deleted.**
  ///
  /// Every read filters `deleted_at IS NULL`. A query that forgets silently
  /// resurrects deleted rows — the single most likely bug this schema
  /// introduces, which is why the filter is centralised in the DAOs rather than
  /// written per query.
  final int? deletedAt;
  final int measuredAt;
  final int measuredAtTzOffsetMinutes;
  final MeasurementType type;

  /// Grams for masses, millimetres for lengths, basis points for percentages —
  /// fixed per [type], never ambiguous.
  final int valueCanonical;
  final String? notes;
  const BodyMeasurement({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.measuredAt,
    required this.measuredAtTzOffsetMinutes,
    required this.type,
    required this.valueCanonical,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['measured_at'] = Variable<int>(measuredAt);
    map['measured_at_tz_offset_minutes'] = Variable<int>(
      measuredAtTzOffsetMinutes,
    );
    {
      map['type'] = Variable<String>(
        $BodyMeasurementsTable.$convertertype.toSql(type),
      );
    }
    map['value_canonical'] = Variable<int>(valueCanonical);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  BodyMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return BodyMeasurementsCompanion(
      id: Value(id),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      measuredAt: Value(measuredAt),
      measuredAtTzOffsetMinutes: Value(measuredAtTzOffsetMinutes),
      type: Value(type),
      valueCanonical: Value(valueCanonical),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory BodyMeasurement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyMeasurement(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      measuredAt: serializer.fromJson<int>(json['measuredAt']),
      measuredAtTzOffsetMinutes: serializer.fromJson<int>(
        json['measuredAtTzOffsetMinutes'],
      ),
      type: $BodyMeasurementsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      valueCanonical: serializer.fromJson<int>(json['valueCanonical']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'measuredAt': serializer.toJson<int>(measuredAt),
      'measuredAtTzOffsetMinutes': serializer.toJson<int>(
        measuredAtTzOffsetMinutes,
      ),
      'type': serializer.toJson<String>(
        $BodyMeasurementsTable.$convertertype.toJson(type),
      ),
      'valueCanonical': serializer.toJson<int>(valueCanonical),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  BodyMeasurement copyWith({
    String? id,
    String? userId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? measuredAt,
    int? measuredAtTzOffsetMinutes,
    MeasurementType? type,
    int? valueCanonical,
    Value<String?> notes = const Value.absent(),
  }) => BodyMeasurement(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    measuredAt: measuredAt ?? this.measuredAt,
    measuredAtTzOffsetMinutes:
        measuredAtTzOffsetMinutes ?? this.measuredAtTzOffsetMinutes,
    type: type ?? this.type,
    valueCanonical: valueCanonical ?? this.valueCanonical,
    notes: notes.present ? notes.value : this.notes,
  );
  BodyMeasurement copyWithCompanion(BodyMeasurementsCompanion data) {
    return BodyMeasurement(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
      measuredAtTzOffsetMinutes: data.measuredAtTzOffsetMinutes.present
          ? data.measuredAtTzOffsetMinutes.value
          : this.measuredAtTzOffsetMinutes,
      type: data.type.present ? data.type.value : this.type,
      valueCanonical: data.valueCanonical.present
          ? data.valueCanonical.value
          : this.valueCanonical,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurement(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('measuredAtTzOffsetMinutes: $measuredAtTzOffsetMinutes, ')
          ..write('type: $type, ')
          ..write('valueCanonical: $valueCanonical, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    measuredAt,
    measuredAtTzOffsetMinutes,
    type,
    valueCanonical,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyMeasurement &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.measuredAt == this.measuredAt &&
          other.measuredAtTzOffsetMinutes == this.measuredAtTzOffsetMinutes &&
          other.type == this.type &&
          other.valueCanonical == this.valueCanonical &&
          other.notes == this.notes);
}

class BodyMeasurementsCompanion extends UpdateCompanion<BodyMeasurement> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> measuredAt;
  final Value<int> measuredAtTzOffsetMinutes;
  final Value<MeasurementType> type;
  final Value<int> valueCanonical;
  final Value<String?> notes;
  final Value<int> rowid;
  const BodyMeasurementsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.measuredAtTzOffsetMinutes = const Value.absent(),
    this.type = const Value.absent(),
    this.valueCanonical = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodyMeasurementsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required int measuredAt,
    required int measuredAtTzOffsetMinutes,
    required MeasurementType type,
    required int valueCanonical,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       measuredAt = Value(measuredAt),
       measuredAtTzOffsetMinutes = Value(measuredAtTzOffsetMinutes),
       type = Value(type),
       valueCanonical = Value(valueCanonical);
  static Insertable<BodyMeasurement> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? measuredAt,
    Expression<int>? measuredAtTzOffsetMinutes,
    Expression<String>? type,
    Expression<int>? valueCanonical,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (measuredAtTzOffsetMinutes != null)
        'measured_at_tz_offset_minutes': measuredAtTzOffsetMinutes,
      if (type != null) 'type': type,
      if (valueCanonical != null) 'value_canonical': valueCanonical,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodyMeasurementsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? measuredAt,
    Value<int>? measuredAtTzOffsetMinutes,
    Value<MeasurementType>? type,
    Value<int>? valueCanonical,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return BodyMeasurementsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      measuredAt: measuredAt ?? this.measuredAt,
      measuredAtTzOffsetMinutes:
          measuredAtTzOffsetMinutes ?? this.measuredAtTzOffsetMinutes,
      type: type ?? this.type,
      valueCanonical: valueCanonical ?? this.valueCanonical,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<int>(measuredAt.value);
    }
    if (measuredAtTzOffsetMinutes.present) {
      map['measured_at_tz_offset_minutes'] = Variable<int>(
        measuredAtTzOffsetMinutes.value,
      );
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $BodyMeasurementsTable.$convertertype.toSql(type.value),
      );
    }
    if (valueCanonical.present) {
      map['value_canonical'] = Variable<int>(valueCanonical.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('measuredAtTzOffsetMinutes: $measuredAtTzOffsetMinutes, ')
          ..write('type: $type, ')
          ..write('valueCanonical: $valueCanonical, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalRecordsTable extends PersonalRecords
    with TableInfo<$PersonalRecordsTable, PersonalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local-user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PrKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PrKind>($PersonalRecordsTable.$converterkind);
  static const VerificationMeta _qualifierMeta = const VerificationMeta(
    'qualifier',
  );
  @override
  late final GeneratedColumn<int> qualifier = GeneratedColumn<int>(
    'qualifier',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setIdMeta = const VerificationMeta('setId');
  @override
  late final GeneratedColumn<String> setId = GeneratedColumn<String>(
    'set_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sets (id)',
    ),
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workout_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workouts (id)',
    ),
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<int> achievedAt = GeneratedColumn<int>(
    'achieved_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    exerciseId,
    kind,
    qualifier,
    value,
    setId,
    workoutId,
    achievedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('qualifier')) {
      context.handle(
        _qualifierMeta,
        qualifier.isAcceptableOrUnknown(data['qualifier']!, _qualifierMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('set_id')) {
      context.handle(
        _setIdMeta,
        setId.isAcceptableOrUnknown(data['set_id']!, _setIdMeta),
      );
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_achievedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      kind: $PersonalRecordsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      qualifier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qualifier'],
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      setId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_id'],
      ),
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_id'],
      ),
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}achieved_at'],
      )!,
    );
  }

  @override
  $PersonalRecordsTable createAlias(String alias) {
    return $PersonalRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PrKind, String, String> $converterkind =
      const EnumNameConverter<PrKind>(PrKind.values);
}

class PersonalRecord extends DataClass implements Insertable<PersonalRecord> {
  /// UUID v4, generated client-side.
  ///
  /// Not an autoincrementing integer: an ID that exists before the insert
  /// completes lets the UI render optimistically, which matters directly for
  /// write-through set logging (`F-LOG-007`), and removes the collision problem
  /// from any future sync.
  final String id;

  /// Constant `'local-user'` for now. Adding a `NOT NULL` foreign key to
  /// populated tables later is painful; adding a column that is already there
  /// and already correct is free.
  final String userId;

  /// UTC epoch milliseconds.
  final int createdAt;

  /// UTC epoch milliseconds, rewritten on **every** modification. The basis for
  /// last-write-wins resolution if sync ever ships.
  final int updatedAt;

  /// Soft-delete tombstone. **Nothing is ever hard-deleted.**
  ///
  /// Every read filters `deleted_at IS NULL`. A query that forgets silently
  /// resurrects deleted rows — the single most likely bug this schema
  /// introduces, which is why the filter is centralised in the DAOs rather than
  /// written per query.
  final int? deletedAt;
  final String exerciseId;
  final PrKind kind;

  /// For `maxRepsAtWeight`, the weight in grams.
  final int? qualifier;
  final int value;
  final String? setId;
  final String? workoutId;
  final int achievedAt;
  const PersonalRecord({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.exerciseId,
    required this.kind,
    this.qualifier,
    required this.value,
    this.setId,
    this.workoutId,
    required this.achievedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['exercise_id'] = Variable<String>(exerciseId);
    {
      map['kind'] = Variable<String>(
        $PersonalRecordsTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || qualifier != null) {
      map['qualifier'] = Variable<int>(qualifier);
    }
    map['value'] = Variable<int>(value);
    if (!nullToAbsent || setId != null) {
      map['set_id'] = Variable<String>(setId);
    }
    if (!nullToAbsent || workoutId != null) {
      map['workout_id'] = Variable<String>(workoutId);
    }
    map['achieved_at'] = Variable<int>(achievedAt);
    return map;
  }

  PersonalRecordsCompanion toCompanion(bool nullToAbsent) {
    return PersonalRecordsCompanion(
      id: Value(id),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      exerciseId: Value(exerciseId),
      kind: Value(kind),
      qualifier: qualifier == null && nullToAbsent
          ? const Value.absent()
          : Value(qualifier),
      value: Value(value),
      setId: setId == null && nullToAbsent
          ? const Value.absent()
          : Value(setId),
      workoutId: workoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(workoutId),
      achievedAt: Value(achievedAt),
    );
  }

  factory PersonalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalRecord(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      kind: $PersonalRecordsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      qualifier: serializer.fromJson<int?>(json['qualifier']),
      value: serializer.fromJson<int>(json['value']),
      setId: serializer.fromJson<String?>(json['setId']),
      workoutId: serializer.fromJson<String?>(json['workoutId']),
      achievedAt: serializer.fromJson<int>(json['achievedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'kind': serializer.toJson<String>(
        $PersonalRecordsTable.$converterkind.toJson(kind),
      ),
      'qualifier': serializer.toJson<int?>(qualifier),
      'value': serializer.toJson<int>(value),
      'setId': serializer.toJson<String?>(setId),
      'workoutId': serializer.toJson<String?>(workoutId),
      'achievedAt': serializer.toJson<int>(achievedAt),
    };
  }

  PersonalRecord copyWith({
    String? id,
    String? userId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? exerciseId,
    PrKind? kind,
    Value<int?> qualifier = const Value.absent(),
    int? value,
    Value<String?> setId = const Value.absent(),
    Value<String?> workoutId = const Value.absent(),
    int? achievedAt,
  }) => PersonalRecord(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    exerciseId: exerciseId ?? this.exerciseId,
    kind: kind ?? this.kind,
    qualifier: qualifier.present ? qualifier.value : this.qualifier,
    value: value ?? this.value,
    setId: setId.present ? setId.value : this.setId,
    workoutId: workoutId.present ? workoutId.value : this.workoutId,
    achievedAt: achievedAt ?? this.achievedAt,
  );
  PersonalRecord copyWithCompanion(PersonalRecordsCompanion data) {
    return PersonalRecord(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      kind: data.kind.present ? data.kind.value : this.kind,
      qualifier: data.qualifier.present ? data.qualifier.value : this.qualifier,
      value: data.value.present ? data.value.value : this.value,
      setId: data.setId.present ? data.setId.value : this.setId,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecord(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('kind: $kind, ')
          ..write('qualifier: $qualifier, ')
          ..write('value: $value, ')
          ..write('setId: $setId, ')
          ..write('workoutId: $workoutId, ')
          ..write('achievedAt: $achievedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    exerciseId,
    kind,
    qualifier,
    value,
    setId,
    workoutId,
    achievedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalRecord &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.exerciseId == this.exerciseId &&
          other.kind == this.kind &&
          other.qualifier == this.qualifier &&
          other.value == this.value &&
          other.setId == this.setId &&
          other.workoutId == this.workoutId &&
          other.achievedAt == this.achievedAt);
}

class PersonalRecordsCompanion extends UpdateCompanion<PersonalRecord> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> exerciseId;
  final Value<PrKind> kind;
  final Value<int?> qualifier;
  final Value<int> value;
  final Value<String?> setId;
  final Value<String?> workoutId;
  final Value<int> achievedAt;
  final Value<int> rowid;
  const PersonalRecordsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.kind = const Value.absent(),
    this.qualifier = const Value.absent(),
    this.value = const Value.absent(),
    this.setId = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalRecordsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String exerciseId,
    required PrKind kind,
    this.qualifier = const Value.absent(),
    required int value,
    this.setId = const Value.absent(),
    this.workoutId = const Value.absent(),
    required int achievedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       exerciseId = Value(exerciseId),
       kind = Value(kind),
       value = Value(value),
       achievedAt = Value(achievedAt);
  static Insertable<PersonalRecord> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? exerciseId,
    Expression<String>? kind,
    Expression<int>? qualifier,
    Expression<int>? value,
    Expression<String>? setId,
    Expression<String>? workoutId,
    Expression<int>? achievedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (kind != null) 'kind': kind,
      if (qualifier != null) 'qualifier': qualifier,
      if (value != null) 'value': value,
      if (setId != null) 'set_id': setId,
      if (workoutId != null) 'workout_id': workoutId,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? exerciseId,
    Value<PrKind>? kind,
    Value<int?>? qualifier,
    Value<int>? value,
    Value<String?>? setId,
    Value<String?>? workoutId,
    Value<int>? achievedAt,
    Value<int>? rowid,
  }) {
    return PersonalRecordsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      exerciseId: exerciseId ?? this.exerciseId,
      kind: kind ?? this.kind,
      qualifier: qualifier ?? this.qualifier,
      value: value ?? this.value,
      setId: setId ?? this.setId,
      workoutId: workoutId ?? this.workoutId,
      achievedAt: achievedAt ?? this.achievedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $PersonalRecordsTable.$converterkind.toSql(kind.value),
      );
    }
    if (qualifier.present) {
      map['qualifier'] = Variable<int>(qualifier.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (setId.present) {
      map['set_id'] = Variable<String>(setId.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<int>(achievedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('kind: $kind, ')
          ..write('qualifier: $qualifier, ')
          ..write('value: $value, ')
          ..write('setId: $setId, ')
          ..write('workoutId: $workoutId, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local-user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
    key,
    value,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  /// UUID v4, generated client-side.
  ///
  /// Not an autoincrementing integer: an ID that exists before the insert
  /// completes lets the UI render optimistically, which matters directly for
  /// write-through set logging (`F-LOG-007`), and removes the collision problem
  /// from any future sync.
  final String id;

  /// Constant `'local-user'` for now. Adding a `NOT NULL` foreign key to
  /// populated tables later is painful; adding a column that is already there
  /// and already correct is free.
  final String userId;

  /// UTC epoch milliseconds.
  final int createdAt;

  /// UTC epoch milliseconds, rewritten on **every** modification. The basis for
  /// last-write-wins resolution if sync ever ships.
  final int updatedAt;

  /// Soft-delete tombstone. **Nothing is ever hard-deleted.**
  ///
  /// Every read filters `deleted_at IS NULL`. A query that forgets silently
  /// resurrects deleted rows — the single most likely bug this schema
  /// introduces, which is why the filter is centralised in the DAOs rather than
  /// written per query.
  final int? deletedAt;
  final String key;
  final String value;
  const AppSetting({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.key,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({
    String? id,
    String? userId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? key,
    String? value,
  }) => AppSetting(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    key: key ?? this.key,
    value: value ?? this.value,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, createdAt, updatedAt, deletedAt, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BarsTable bars = $BarsTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $PlatesTable plates = $PlatesTable(this);
  late final $RoutineFoldersTable routineFolders = $RoutineFoldersTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $RoutineDaysTable routineDays = $RoutineDaysTable(this);
  late final $RoutineExercisesTable routineExercises = $RoutineExercisesTable(
    this,
  );
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $WorkoutExercisesTable workoutExercises = $WorkoutExercisesTable(
    this,
  );
  late final $SetsTable sets = $SetsTable(this);
  late final $BodyMeasurementsTable bodyMeasurements = $BodyMeasurementsTable(
    this,
  );
  late final $PersonalRecordsTable personalRecords = $PersonalRecordsTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bars,
    exercises,
    plates,
    routineFolders,
    routines,
    routineDays,
    routineExercises,
    workouts,
    workoutExercises,
    sets,
    bodyMeasurements,
    personalRecords,
    appSettings,
  ];
}

typedef $$BarsTableCreateCompanionBuilder =
    BarsCompanion Function({
      required String id,
      Value<String> userId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String name,
      required int weightGrams,
      Value<bool> isDefault,
      Value<int> rowid,
    });
typedef $$BarsTableUpdateCompanionBuilder =
    BarsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> name,
      Value<int> weightGrams,
      Value<bool> isDefault,
      Value<int> rowid,
    });

final class $$BarsTableReferences
    extends BaseReferences<_$AppDatabase, $BarsTable, Bar> {
  $$BarsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExercisesTable, List<Exercise>>
  _exercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exercises,
    aliasName: 'bars__id__exercises__default_bar_id',
  );

  $$ExercisesTableProcessedTableManager get exercisesRefs {
    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.defaultBarId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exercisesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BarsTableFilterComposer extends Composer<_$AppDatabase, $BarsTable> {
  $$BarsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exercisesRefs(
    Expression<bool> Function($$ExercisesTableFilterComposer f) f,
  ) {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.defaultBarId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BarsTableOrderingComposer extends Composer<_$AppDatabase, $BarsTable> {
  $$BarsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BarsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BarsTable> {
  $$BarsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  Expression<T> exercisesRefs<T extends Object>(
    Expression<T> Function($$ExercisesTableAnnotationComposer a) f,
  ) {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.defaultBarId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BarsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BarsTable,
          Bar,
          $$BarsTableFilterComposer,
          $$BarsTableOrderingComposer,
          $$BarsTableAnnotationComposer,
          $$BarsTableCreateCompanionBuilder,
          $$BarsTableUpdateCompanionBuilder,
          (Bar, $$BarsTableReferences),
          Bar,
          PrefetchHooks Function({bool exercisesRefs})
        > {
  $$BarsTableTableManager(_$AppDatabase db, $BarsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BarsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BarsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BarsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> weightGrams = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BarsCompanion(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                weightGrams: weightGrams,
                isDefault: isDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String name,
                required int weightGrams,
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BarsCompanion.insert(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                weightGrams: weightGrams,
                isDefault: isDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BarsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({exercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (exercisesRefs) db.exercises],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exercisesRefs)
                    await $_getPrefetchedData<Bar, $BarsTable, Exercise>(
                      currentTable: table,
                      referencedTable: $$BarsTableReferences
                          ._exercisesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BarsTableReferences(db, table, p0).exercisesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.defaultBarId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BarsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BarsTable,
      Bar,
      $$BarsTableFilterComposer,
      $$BarsTableOrderingComposer,
      $$BarsTableAnnotationComposer,
      $$BarsTableCreateCompanionBuilder,
      $$BarsTableUpdateCompanionBuilder,
      (Bar, $$BarsTableReferences),
      Bar,
      PrefetchHooks Function({bool exercisesRefs})
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      required String id,
      Value<String> userId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<String?> externalId,
      required String name,
      Value<List<String>> aliases,
      required Muscle primaryMuscle,
      Value<List<String>> secondaryMuscles,
      required Equipment equipment,
      required TrackingType trackingType,
      Value<bool> isCustom,
      Value<bool> isFavorite,
      Value<int?> archivedAt,
      Value<String?> notes,
      Value<int?> defaultRestSeconds,
      Value<String?> defaultBarId,
      Value<WeightEntryMode> weightEntryMode,
      Value<int?> incrementGrams,
      Value<double?> bodyweightCoefficient,
      Value<WeightSource> weightSource,
      Value<List<int>> fixedIncrementsGrams,
      Value<int?> stackBaseGrams,
      Value<int?> stackStepGrams,
      Value<int?> stackHalfStepGrams,
      Value<String?> warmupRuleset,
      Value<int?> trainingMaxGrams,
      Value<int?> seedUpdatedAt,
      Value<int> rowid,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String?> externalId,
      Value<String> name,
      Value<List<String>> aliases,
      Value<Muscle> primaryMuscle,
      Value<List<String>> secondaryMuscles,
      Value<Equipment> equipment,
      Value<TrackingType> trackingType,
      Value<bool> isCustom,
      Value<bool> isFavorite,
      Value<int?> archivedAt,
      Value<String?> notes,
      Value<int?> defaultRestSeconds,
      Value<String?> defaultBarId,
      Value<WeightEntryMode> weightEntryMode,
      Value<int?> incrementGrams,
      Value<double?> bodyweightCoefficient,
      Value<WeightSource> weightSource,
      Value<List<int>> fixedIncrementsGrams,
      Value<int?> stackBaseGrams,
      Value<int?> stackStepGrams,
      Value<int?> stackHalfStepGrams,
      Value<String?> warmupRuleset,
      Value<int?> trainingMaxGrams,
      Value<int?> seedUpdatedAt,
      Value<int> rowid,
    });

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BarsTable _defaultBarIdTable(_$AppDatabase db) =>
      db.bars.createAlias('exercises__default_bar_id__bars__id');

  $$BarsTableProcessedTableManager? get defaultBarId {
    final $_column = $_itemColumn<String>('default_bar_id');
    if ($_column == null) return null;
    final manager = $$BarsTableTableManager(
      $_db,
      $_db.bars,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_defaultBarIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RoutineExercisesTable, List<RoutineExercise>>
  _routineExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineExercises,
    aliasName: 'exercises__id__routine_exercises__exercise_id',
  );

  $$RoutineExercisesTableProcessedTableManager get routineExercisesRefs {
    final manager = $$RoutineExercisesTableTableManager(
      $_db,
      $_db.routineExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutExercisesTable, List<WorkoutExercise>>
  _workoutExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutExercises,
    aliasName: 'exercises__id__workout_exercises__exercise_id',
  );

  $$WorkoutExercisesTableProcessedTableManager get workoutExercisesRefs {
    final manager = $$WorkoutExercisesTableTableManager(
      $_db,
      $_db.workoutExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PersonalRecordsTable, List<PersonalRecord>>
  _personalRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalRecords,
    aliasName: 'exercises__id__personal_records__exercise_id',
  );

  $$PersonalRecordsTableProcessedTableManager get personalRecordsRefs {
    final manager = $$PersonalRecordsTableTableManager(
      $_db,
      $_db.personalRecords,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Muscle, Muscle, String> get primaryMuscle =>
      $composableBuilder(
        column: $table.primaryMuscle,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Equipment, Equipment, String> get equipment =>
      $composableBuilder(
        column: $table.equipment,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<TrackingType, TrackingType, String>
  get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultRestSeconds => $composableBuilder(
    column: $table.defaultRestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WeightEntryMode, WeightEntryMode, String>
  get weightEntryMode => $composableBuilder(
    column: $table.weightEntryMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get incrementGrams => $composableBuilder(
    column: $table.incrementGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyweightCoefficient => $composableBuilder(
    column: $table.bodyweightCoefficient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WeightSource, WeightSource, String>
  get weightSource => $composableBuilder(
    column: $table.weightSource,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String>
  get fixedIncrementsGrams => $composableBuilder(
    column: $table.fixedIncrementsGrams,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get stackBaseGrams => $composableBuilder(
    column: $table.stackBaseGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stackStepGrams => $composableBuilder(
    column: $table.stackStepGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stackHalfStepGrams => $composableBuilder(
    column: $table.stackHalfStepGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warmupRuleset => $composableBuilder(
    column: $table.warmupRuleset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trainingMaxGrams => $composableBuilder(
    column: $table.trainingMaxGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seedUpdatedAt => $composableBuilder(
    column: $table.seedUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BarsTableFilterComposer get defaultBarId {
    final $$BarsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultBarId,
      referencedTable: $db.bars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BarsTableFilterComposer(
            $db: $db,
            $table: $db.bars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> routineExercisesRefs(
    Expression<bool> Function($$RoutineExercisesTableFilterComposer f) f,
  ) {
    final $$RoutineExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableFilterComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutExercisesRefs(
    Expression<bool> Function($$WorkoutExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> personalRecordsRefs(
    Expression<bool> Function($$PersonalRecordsTableFilterComposer f) f,
  ) {
    final $$PersonalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMuscle => $composableBuilder(
    column: $table.primaryMuscle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultRestSeconds => $composableBuilder(
    column: $table.defaultRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightEntryMode => $composableBuilder(
    column: $table.weightEntryMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get incrementGrams => $composableBuilder(
    column: $table.incrementGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyweightCoefficient => $composableBuilder(
    column: $table.bodyweightCoefficient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightSource => $composableBuilder(
    column: $table.weightSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fixedIncrementsGrams => $composableBuilder(
    column: $table.fixedIncrementsGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stackBaseGrams => $composableBuilder(
    column: $table.stackBaseGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stackStepGrams => $composableBuilder(
    column: $table.stackStepGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stackHalfStepGrams => $composableBuilder(
    column: $table.stackHalfStepGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warmupRuleset => $composableBuilder(
    column: $table.warmupRuleset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trainingMaxGrams => $composableBuilder(
    column: $table.trainingMaxGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seedUpdatedAt => $composableBuilder(
    column: $table.seedUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BarsTableOrderingComposer get defaultBarId {
    final $$BarsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultBarId,
      referencedTable: $db.bars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BarsTableOrderingComposer(
            $db: $db,
            $table: $db.bars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Muscle, String> get primaryMuscle =>
      $composableBuilder(
        column: $table.primaryMuscle,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get secondaryMuscles =>
      $composableBuilder(
        column: $table.secondaryMuscles,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Equipment, String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TrackingType, String> get trackingType =>
      $composableBuilder(
        column: $table.trackingType,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get defaultRestSeconds => $composableBuilder(
    column: $table.defaultRestSeconds,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<WeightEntryMode, String>
  get weightEntryMode => $composableBuilder(
    column: $table.weightEntryMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get incrementGrams => $composableBuilder(
    column: $table.incrementGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bodyweightCoefficient => $composableBuilder(
    column: $table.bodyweightCoefficient,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<WeightSource, String> get weightSource =>
      $composableBuilder(
        column: $table.weightSource,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<int>, String>
  get fixedIncrementsGrams => $composableBuilder(
    column: $table.fixedIncrementsGrams,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stackBaseGrams => $composableBuilder(
    column: $table.stackBaseGrams,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stackStepGrams => $composableBuilder(
    column: $table.stackStepGrams,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stackHalfStepGrams => $composableBuilder(
    column: $table.stackHalfStepGrams,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warmupRuleset => $composableBuilder(
    column: $table.warmupRuleset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trainingMaxGrams => $composableBuilder(
    column: $table.trainingMaxGrams,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seedUpdatedAt => $composableBuilder(
    column: $table.seedUpdatedAt,
    builder: (column) => column,
  );

  $$BarsTableAnnotationComposer get defaultBarId {
    final $$BarsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultBarId,
      referencedTable: $db.bars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BarsTableAnnotationComposer(
            $db: $db,
            $table: $db.bars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> routineExercisesRefs<T extends Object>(
    Expression<T> Function($$RoutineExercisesTableAnnotationComposer a) f,
  ) {
    final $$RoutineExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutExercisesTableAnnotationComposer a) f,
  ) {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> personalRecordsRefs<T extends Object>(
    Expression<T> Function($$PersonalRecordsTableAnnotationComposer a) f,
  ) {
    final $$PersonalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool defaultBarId,
            bool routineExercisesRefs,
            bool workoutExercisesRefs,
            bool personalRecordsRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<List<String>> aliases = const Value.absent(),
                Value<Muscle> primaryMuscle = const Value.absent(),
                Value<List<String>> secondaryMuscles = const Value.absent(),
                Value<Equipment> equipment = const Value.absent(),
                Value<TrackingType> trackingType = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int?> archivedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> defaultRestSeconds = const Value.absent(),
                Value<String?> defaultBarId = const Value.absent(),
                Value<WeightEntryMode> weightEntryMode = const Value.absent(),
                Value<int?> incrementGrams = const Value.absent(),
                Value<double?> bodyweightCoefficient = const Value.absent(),
                Value<WeightSource> weightSource = const Value.absent(),
                Value<List<int>> fixedIncrementsGrams = const Value.absent(),
                Value<int?> stackBaseGrams = const Value.absent(),
                Value<int?> stackStepGrams = const Value.absent(),
                Value<int?> stackHalfStepGrams = const Value.absent(),
                Value<String?> warmupRuleset = const Value.absent(),
                Value<int?> trainingMaxGrams = const Value.absent(),
                Value<int?> seedUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                externalId: externalId,
                name: name,
                aliases: aliases,
                primaryMuscle: primaryMuscle,
                secondaryMuscles: secondaryMuscles,
                equipment: equipment,
                trackingType: trackingType,
                isCustom: isCustom,
                isFavorite: isFavorite,
                archivedAt: archivedAt,
                notes: notes,
                defaultRestSeconds: defaultRestSeconds,
                defaultBarId: defaultBarId,
                weightEntryMode: weightEntryMode,
                incrementGrams: incrementGrams,
                bodyweightCoefficient: bodyweightCoefficient,
                weightSource: weightSource,
                fixedIncrementsGrams: fixedIncrementsGrams,
                stackBaseGrams: stackBaseGrams,
                stackStepGrams: stackStepGrams,
                stackHalfStepGrams: stackHalfStepGrams,
                warmupRuleset: warmupRuleset,
                trainingMaxGrams: trainingMaxGrams,
                seedUpdatedAt: seedUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                required String name,
                Value<List<String>> aliases = const Value.absent(),
                required Muscle primaryMuscle,
                Value<List<String>> secondaryMuscles = const Value.absent(),
                required Equipment equipment,
                required TrackingType trackingType,
                Value<bool> isCustom = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int?> archivedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> defaultRestSeconds = const Value.absent(),
                Value<String?> defaultBarId = const Value.absent(),
                Value<WeightEntryMode> weightEntryMode = const Value.absent(),
                Value<int?> incrementGrams = const Value.absent(),
                Value<double?> bodyweightCoefficient = const Value.absent(),
                Value<WeightSource> weightSource = const Value.absent(),
                Value<List<int>> fixedIncrementsGrams = const Value.absent(),
                Value<int?> stackBaseGrams = const Value.absent(),
                Value<int?> stackStepGrams = const Value.absent(),
                Value<int?> stackHalfStepGrams = const Value.absent(),
                Value<String?> warmupRuleset = const Value.absent(),
                Value<int?> trainingMaxGrams = const Value.absent(),
                Value<int?> seedUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                externalId: externalId,
                name: name,
                aliases: aliases,
                primaryMuscle: primaryMuscle,
                secondaryMuscles: secondaryMuscles,
                equipment: equipment,
                trackingType: trackingType,
                isCustom: isCustom,
                isFavorite: isFavorite,
                archivedAt: archivedAt,
                notes: notes,
                defaultRestSeconds: defaultRestSeconds,
                defaultBarId: defaultBarId,
                weightEntryMode: weightEntryMode,
                incrementGrams: incrementGrams,
                bodyweightCoefficient: bodyweightCoefficient,
                weightSource: weightSource,
                fixedIncrementsGrams: fixedIncrementsGrams,
                stackBaseGrams: stackBaseGrams,
                stackStepGrams: stackStepGrams,
                stackHalfStepGrams: stackHalfStepGrams,
                warmupRuleset: warmupRuleset,
                trainingMaxGrams: trainingMaxGrams,
                seedUpdatedAt: seedUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                defaultBarId = false,
                routineExercisesRefs = false,
                workoutExercisesRefs = false,
                personalRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routineExercisesRefs) db.routineExercises,
                    if (workoutExercisesRefs) db.workoutExercises,
                    if (personalRecordsRefs) db.personalRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (defaultBarId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.defaultBarId,
                                    referencedTable: $$ExercisesTableReferences
                                        ._defaultBarIdTable(db),
                                    referencedColumn: $$ExercisesTableReferences
                                        ._defaultBarIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routineExercisesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          RoutineExercise
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._routineExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).routineExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutExercisesRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          WorkoutExercise
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._workoutExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personalRecordsRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          PersonalRecord
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._personalRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).personalRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({
        bool defaultBarId,
        bool routineExercisesRefs,
        bool workoutExercisesRefs,
        bool personalRecordsRefs,
      })
    >;
typedef $$PlatesTableCreateCompanionBuilder =
    PlatesCompanion Function({
      required String id,
      Value<String> userId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required int weightGrams,
      Value<int> countAvailable,
      Value<bool> isEnabled,
      Value<int> rowid,
    });
typedef $$PlatesTableUpdateCompanionBuilder =
    PlatesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> weightGrams,
      Value<int> countAvailable,
      Value<bool> isEnabled,
      Value<int> rowid,
    });

class $$PlatesTableFilterComposer
    extends Composer<_$AppDatabase, $PlatesTable> {
  $$PlatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countAvailable => $composableBuilder(
    column: $table.countAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlatesTable> {
  $$PlatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countAvailable => $composableBuilder(
    column: $table.countAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlatesTable> {
  $$PlatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<int> get countAvailable => $composableBuilder(
    column: $table.countAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);
}

class $$PlatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlatesTable,
          Plate,
          $$PlatesTableFilterComposer,
          $$PlatesTableOrderingComposer,
          $$PlatesTableAnnotationComposer,
          $$PlatesTableCreateCompanionBuilder,
          $$PlatesTableUpdateCompanionBuilder,
          (Plate, BaseReferences<_$AppDatabase, $PlatesTable, Plate>),
          Plate,
          PrefetchHooks Function()
        > {
  $$PlatesTableTableManager(_$AppDatabase db, $PlatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> weightGrams = const Value.absent(),
                Value<int> countAvailable = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlatesCompanion(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                weightGrams: weightGrams,
                countAvailable: countAvailable,
                isEnabled: isEnabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required int weightGrams,
                Value<int> countAvailable = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlatesCompanion.insert(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                weightGrams: weightGrams,
                countAvailable: countAvailable,
                isEnabled: isEnabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlatesTable,
      Plate,
      $$PlatesTableFilterComposer,
      $$PlatesTableOrderingComposer,
      $$PlatesTableAnnotationComposer,
      $$PlatesTableCreateCompanionBuilder,
      $$PlatesTableUpdateCompanionBuilder,
      (Plate, BaseReferences<_$AppDatabase, $PlatesTable, Plate>),
      Plate,
      PrefetchHooks Function()
    >;
typedef $$RoutineFoldersTableCreateCompanionBuilder =
    RoutineFoldersCompanion Function({
      required String id,
      Value<String> userId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String name,
      required int position,
      Value<int> rowid,
    });
typedef $$RoutineFoldersTableUpdateCompanionBuilder =
    RoutineFoldersCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> name,
      Value<int> position,
      Value<int> rowid,
    });

final class $$RoutineFoldersTableReferences
    extends BaseReferences<_$AppDatabase, $RoutineFoldersTable, RoutineFolder> {
  $$RoutineFoldersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$RoutinesTable, List<Routine>> _routinesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.routines,
    aliasName: 'routine_folders__id__routines__folder_id',
  );

  $$RoutinesTableProcessedTableManager get routinesRefs {
    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutineFoldersTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineFoldersTable> {
  $$RoutineFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routinesRefs(
    Expression<bool> Function($$RoutinesTableFilterComposer f) f,
  ) {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineFoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineFoldersTable> {
  $$RoutineFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutineFoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineFoldersTable> {
  $$RoutineFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  Expression<T> routinesRefs<T extends Object>(
    Expression<T> Function($$RoutinesTableAnnotationComposer a) f,
  ) {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineFoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineFoldersTable,
          RoutineFolder,
          $$RoutineFoldersTableFilterComposer,
          $$RoutineFoldersTableOrderingComposer,
          $$RoutineFoldersTableAnnotationComposer,
          $$RoutineFoldersTableCreateCompanionBuilder,
          $$RoutineFoldersTableUpdateCompanionBuilder,
          (RoutineFolder, $$RoutineFoldersTableReferences),
          RoutineFolder,
          PrefetchHooks Function({bool routinesRefs})
        > {
  $$RoutineFoldersTableTableManager(
    _$AppDatabase db,
    $RoutineFoldersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineFoldersCompanion(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String name,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => RoutineFoldersCompanion.insert(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutineFoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routinesRefs) db.routines],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routinesRefs)
                    await $_getPrefetchedData<
                      RoutineFolder,
                      $RoutineFoldersTable,
                      Routine
                    >(
                      currentTable: table,
                      referencedTable: $$RoutineFoldersTableReferences
                          ._routinesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoutineFoldersTableReferences(
                            db,
                            table,
                            p0,
                          ).routinesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutineFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineFoldersTable,
      RoutineFolder,
      $$RoutineFoldersTableFilterComposer,
      $$RoutineFoldersTableOrderingComposer,
      $$RoutineFoldersTableAnnotationComposer,
      $$RoutineFoldersTableCreateCompanionBuilder,
      $$RoutineFoldersTableUpdateCompanionBuilder,
      (RoutineFolder, $$RoutineFoldersTableReferences),
      RoutineFolder,
      PrefetchHooks Function({bool routinesRefs})
    >;
typedef $$RoutinesTableCreateCompanionBuilder =
    RoutinesCompanion Function({
      required String id,
      Value<String> userId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String name,
      Value<String?> folderId,
      Value<String?> notes,
      required int position,
      Value<int?> archivedAt,
      Value<int> rowid,
    });
typedef $$RoutinesTableUpdateCompanionBuilder =
    RoutinesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> name,
      Value<String?> folderId,
      Value<String?> notes,
      Value<int> position,
      Value<int?> archivedAt,
      Value<int> rowid,
    });

final class $$RoutinesTableReferences
    extends BaseReferences<_$AppDatabase, $RoutinesTable, Routine> {
  $$RoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutineFoldersTable _folderIdTable(_$AppDatabase db) =>
      db.routineFolders.createAlias('routines__folder_id__routine_folders__id');

  $$RoutineFoldersTableProcessedTableManager? get folderId {
    final $_column = $_itemColumn<String>('folder_id');
    if ($_column == null) return null;
    final manager = $$RoutineFoldersTableTableManager(
      $_db,
      $_db.routineFolders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RoutineDaysTable, List<RoutineDay>>
  _routineDaysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineDays,
    aliasName: 'routines__id__routine_days__routine_id',
  );

  $$RoutineDaysTableProcessedTableManager get routineDaysRefs {
    final manager = $$RoutineDaysTableTableManager(
      $_db,
      $_db.routineDays,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineDaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutineFoldersTableFilterComposer get folderId {
    final $$RoutineFoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.routineFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineFoldersTableFilterComposer(
            $db: $db,
            $table: $db.routineFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> routineDaysRefs(
    Expression<bool> Function($$RoutineDaysTableFilterComposer f) f,
  ) {
    final $$RoutineDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableFilterComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutineFoldersTableOrderingComposer get folderId {
    final $$RoutineFoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.routineFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineFoldersTableOrderingComposer(
            $db: $db,
            $table: $db.routineFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$RoutineFoldersTableAnnotationComposer get folderId {
    final $$RoutineFoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.routineFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineFoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.routineFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> routineDaysRefs<T extends Object>(
    Expression<T> Function($$RoutineDaysTableAnnotationComposer a) f,
  ) {
    final $$RoutineDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutinesTable,
          Routine,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (Routine, $$RoutinesTableReferences),
          Routine,
          PrefetchHooks Function({bool folderId, bool routineDaysRefs})
        > {
  $$RoutinesTableTableManager(_$AppDatabase db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                folderId: folderId,
                notes: notes,
                position: position,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String name,
                Value<String?> folderId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int position,
                Value<int?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                folderId: folderId,
                notes: notes,
                position: position,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false, routineDaysRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routineDaysRefs) db.routineDays],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (folderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.folderId,
                                referencedTable: $$RoutinesTableReferences
                                    ._folderIdTable(db),
                                referencedColumn: $$RoutinesTableReferences
                                    ._folderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routineDaysRefs)
                    await $_getPrefetchedData<
                      Routine,
                      $RoutinesTable,
                      RoutineDay
                    >(
                      currentTable: table,
                      referencedTable: $$RoutinesTableReferences
                          ._routineDaysRefsTable(db),
                      managerFromTypedResult: (p0) => $$RoutinesTableReferences(
                        db,
                        table,
                        p0,
                      ).routineDaysRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.routineId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutinesTable,
      Routine,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (Routine, $$RoutinesTableReferences),
      Routine,
      PrefetchHooks Function({bool folderId, bool routineDaysRefs})
    >;
typedef $$RoutineDaysTableCreateCompanionBuilder =
    RoutineDaysCompanion Function({
      required String id,
      Value<String> userId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String routineId,
      required String name,
      required int position,
      Value<List<int>> scheduledWeekdays,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$RoutineDaysTableUpdateCompanionBuilder =
    RoutineDaysCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> routineId,
      Value<String> name,
      Value<int> position,
      Value<List<int>> scheduledWeekdays,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$RoutineDaysTableReferences
    extends BaseReferences<_$AppDatabase, $RoutineDaysTable, RoutineDay> {
  $$RoutineDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutinesTable _routineIdTable(_$AppDatabase db) =>
      db.routines.createAlias('routine_days__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RoutineExercisesTable, List<RoutineExercise>>
  _routineExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineExercises,
    aliasName: 'routine_days__id__routine_exercises__routine_day_id',
  );

  $$RoutineExercisesTableProcessedTableManager get routineExercisesRefs {
    final manager = $$RoutineExercisesTableTableManager(
      $_db,
      $_db.routineExercises,
    ).filter((f) => f.routineDayId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutsTable, List<Workout>> _workoutsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.workouts,
    aliasName: 'routine_days__id__workouts__source_routine_day_id',
  );

  $$WorkoutsTableProcessedTableManager get workoutsRefs {
    final manager = $$WorkoutsTableTableManager($_db, $_db.workouts).filter(
      (f) => f.sourceRoutineDayId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_workoutsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutineDaysTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineDaysTable> {
  $$RoutineDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String>
  get scheduledWeekdays => $composableBuilder(
    column: $table.scheduledWeekdays,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> routineExercisesRefs(
    Expression<bool> Function($$RoutineExercisesTableFilterComposer f) f,
  ) {
    final $$RoutineExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.routineDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableFilterComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutsRefs(
    Expression<bool> Function($$WorkoutsTableFilterComposer f) f,
  ) {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.sourceRoutineDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineDaysTable> {
  $$RoutineDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduledWeekdays => $composableBuilder(
    column: $table.scheduledWeekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineDaysTable> {
  $$RoutineDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>, String> get scheduledWeekdays =>
      $composableBuilder(
        column: $table.scheduledWeekdays,
        builder: (column) => column,
      );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> routineExercisesRefs<T extends Object>(
    Expression<T> Function($$RoutineExercisesTableAnnotationComposer a) f,
  ) {
    final $$RoutineExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.routineDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutsRefs<T extends Object>(
    Expression<T> Function($$WorkoutsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.sourceRoutineDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineDaysTable,
          RoutineDay,
          $$RoutineDaysTableFilterComposer,
          $$RoutineDaysTableOrderingComposer,
          $$RoutineDaysTableAnnotationComposer,
          $$RoutineDaysTableCreateCompanionBuilder,
          $$RoutineDaysTableUpdateCompanionBuilder,
          (RoutineDay, $$RoutineDaysTableReferences),
          RoutineDay,
          PrefetchHooks Function({
            bool routineId,
            bool routineExercisesRefs,
            bool workoutsRefs,
          })
        > {
  $$RoutineDaysTableTableManager(_$AppDatabase db, $RoutineDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<List<int>> scheduledWeekdays = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineDaysCompanion(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                routineId: routineId,
                name: name,
                position: position,
                scheduledWeekdays: scheduledWeekdays,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String routineId,
                required String name,
                required int position,
                Value<List<int>> scheduledWeekdays = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineDaysCompanion.insert(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                routineId: routineId,
                name: name,
                position: position,
                scheduledWeekdays: scheduledWeekdays,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutineDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                routineId = false,
                routineExercisesRefs = false,
                workoutsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routineExercisesRefs) db.routineExercises,
                    if (workoutsRefs) db.workouts,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (routineId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.routineId,
                                    referencedTable:
                                        $$RoutineDaysTableReferences
                                            ._routineIdTable(db),
                                    referencedColumn:
                                        $$RoutineDaysTableReferences
                                            ._routineIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routineExercisesRefs)
                        await $_getPrefetchedData<
                          RoutineDay,
                          $RoutineDaysTable,
                          RoutineExercise
                        >(
                          currentTable: table,
                          referencedTable: $$RoutineDaysTableReferences
                              ._routineExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutineDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).routineExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routineDayId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutsRefs)
                        await $_getPrefetchedData<
                          RoutineDay,
                          $RoutineDaysTable,
                          Workout
                        >(
                          currentTable: table,
                          referencedTable: $$RoutineDaysTableReferences
                              ._workoutsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutineDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceRoutineDayId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoutineDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineDaysTable,
      RoutineDay,
      $$RoutineDaysTableFilterComposer,
      $$RoutineDaysTableOrderingComposer,
      $$RoutineDaysTableAnnotationComposer,
      $$RoutineDaysTableCreateCompanionBuilder,
      $$RoutineDaysTableUpdateCompanionBuilder,
      (RoutineDay, $$RoutineDaysTableReferences),
      RoutineDay,
      PrefetchHooks Function({
        bool routineId,
        bool routineExercisesRefs,
        bool workoutsRefs,
      })
    >;
typedef $$RoutineExercisesTableCreateCompanionBuilder =
    RoutineExercisesCompanion Function({
      required String id,
      Value<String> userId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String routineDayId,
      required String exerciseId,
      required int position,
      Value<String?> groupId,
      Value<int?> targetSets,
      Value<int?> targetRepsMin,
      Value<int?> targetRepsMax,
      Value<int?> targetWeightGrams,
      Value<double?> targetRpe,
      Value<int?> restSeconds,
      Value<String?> progressionRule,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$RoutineExercisesTableUpdateCompanionBuilder =
    RoutineExercisesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> routineDayId,
      Value<String> exerciseId,
      Value<int> position,
      Value<String?> groupId,
      Value<int?> targetSets,
      Value<int?> targetRepsMin,
      Value<int?> targetRepsMax,
      Value<int?> targetWeightGrams,
      Value<double?> targetRpe,
      Value<int?> restSeconds,
      Value<String?> progressionRule,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$RoutineExercisesTableReferences
    extends
        BaseReferences<_$AppDatabase, $RoutineExercisesTable, RoutineExercise> {
  $$RoutineExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutineDaysTable _routineDayIdTable(_$AppDatabase db) => db
      .routineDays
      .createAlias('routine_exercises__routine_day_id__routine_days__id');

  $$RoutineDaysTableProcessedTableManager get routineDayId {
    final $_column = $_itemColumn<String>('routine_day_id')!;

    final manager = $$RoutineDaysTableTableManager(
      $_db,
      $_db.routineDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('routine_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutineExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineExercisesTable> {
  $$RoutineExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetRepsMin => $composableBuilder(
    column: $table.targetRepsMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetRepsMax => $composableBuilder(
    column: $table.targetRepsMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetWeightGrams => $composableBuilder(
    column: $table.targetWeightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetRpe => $composableBuilder(
    column: $table.targetRpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get progressionRule => $composableBuilder(
    column: $table.progressionRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutineDaysTableFilterComposer get routineDayId {
    final $$RoutineDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineDayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableFilterComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineExercisesTable> {
  $$RoutineExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetRepsMin => $composableBuilder(
    column: $table.targetRepsMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetRepsMax => $composableBuilder(
    column: $table.targetRepsMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetWeightGrams => $composableBuilder(
    column: $table.targetWeightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetRpe => $composableBuilder(
    column: $table.targetRpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get progressionRule => $composableBuilder(
    column: $table.progressionRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutineDaysTableOrderingComposer get routineDayId {
    final $$RoutineDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineDayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableOrderingComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineExercisesTable> {
  $$RoutineExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetRepsMin => $composableBuilder(
    column: $table.targetRepsMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetRepsMax => $composableBuilder(
    column: $table.targetRepsMax,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetWeightGrams => $composableBuilder(
    column: $table.targetWeightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetRpe =>
      $composableBuilder(column: $table.targetRpe, builder: (column) => column);

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get progressionRule => $composableBuilder(
    column: $table.progressionRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$RoutineDaysTableAnnotationComposer get routineDayId {
    final $$RoutineDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineDayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineExercisesTable,
          RoutineExercise,
          $$RoutineExercisesTableFilterComposer,
          $$RoutineExercisesTableOrderingComposer,
          $$RoutineExercisesTableAnnotationComposer,
          $$RoutineExercisesTableCreateCompanionBuilder,
          $$RoutineExercisesTableUpdateCompanionBuilder,
          (RoutineExercise, $$RoutineExercisesTableReferences),
          RoutineExercise,
          PrefetchHooks Function({bool routineDayId, bool exerciseId})
        > {
  $$RoutineExercisesTableTableManager(
    _$AppDatabase db,
    $RoutineExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> routineDayId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<int?> targetSets = const Value.absent(),
                Value<int?> targetRepsMin = const Value.absent(),
                Value<int?> targetRepsMax = const Value.absent(),
                Value<int?> targetWeightGrams = const Value.absent(),
                Value<double?> targetRpe = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<String?> progressionRule = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineExercisesCompanion(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                routineDayId: routineDayId,
                exerciseId: exerciseId,
                position: position,
                groupId: groupId,
                targetSets: targetSets,
                targetRepsMin: targetRepsMin,
                targetRepsMax: targetRepsMax,
                targetWeightGrams: targetWeightGrams,
                targetRpe: targetRpe,
                restSeconds: restSeconds,
                progressionRule: progressionRule,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String routineDayId,
                required String exerciseId,
                required int position,
                Value<String?> groupId = const Value.absent(),
                Value<int?> targetSets = const Value.absent(),
                Value<int?> targetRepsMin = const Value.absent(),
                Value<int?> targetRepsMax = const Value.absent(),
                Value<int?> targetWeightGrams = const Value.absent(),
                Value<double?> targetRpe = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<String?> progressionRule = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineExercisesCompanion.insert(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                routineDayId: routineDayId,
                exerciseId: exerciseId,
                position: position,
                groupId: groupId,
                targetSets: targetSets,
                targetRepsMin: targetRepsMin,
                targetRepsMax: targetRepsMax,
                targetWeightGrams: targetWeightGrams,
                targetRpe: targetRpe,
                restSeconds: restSeconds,
                progressionRule: progressionRule,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutineExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineDayId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (routineDayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.routineDayId,
                                referencedTable:
                                    $$RoutineExercisesTableReferences
                                        ._routineDayIdTable(db),
                                referencedColumn:
                                    $$RoutineExercisesTableReferences
                                        ._routineDayIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$RoutineExercisesTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$RoutineExercisesTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutineExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineExercisesTable,
      RoutineExercise,
      $$RoutineExercisesTableFilterComposer,
      $$RoutineExercisesTableOrderingComposer,
      $$RoutineExercisesTableAnnotationComposer,
      $$RoutineExercisesTableCreateCompanionBuilder,
      $$RoutineExercisesTableUpdateCompanionBuilder,
      (RoutineExercise, $$RoutineExercisesTableReferences),
      RoutineExercise,
      PrefetchHooks Function({bool routineDayId, bool exerciseId})
    >;
typedef $$WorkoutsTableCreateCompanionBuilder =
    WorkoutsCompanion Function({
      required String id,
      Value<String> userId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String name,
      Value<String?> sourceRoutineDayId,
      required int startedAt,
      required int startedAtTzOffsetMinutes,
      Value<int?> endedAt,
      Value<String?> notes,
      Value<int?> bodyweightGrams,
      Value<int?> perceivedFatigue,
      Value<int> rowid,
    });
typedef $$WorkoutsTableUpdateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> name,
      Value<String?> sourceRoutineDayId,
      Value<int> startedAt,
      Value<int> startedAtTzOffsetMinutes,
      Value<int?> endedAt,
      Value<String?> notes,
      Value<int?> bodyweightGrams,
      Value<int?> perceivedFatigue,
      Value<int> rowid,
    });

final class $$WorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutsTable, Workout> {
  $$WorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutineDaysTable _sourceRoutineDayIdTable(_$AppDatabase db) => db
      .routineDays
      .createAlias('workouts__source_routine_day_id__routine_days__id');

  $$RoutineDaysTableProcessedTableManager? get sourceRoutineDayId {
    final $_column = $_itemColumn<String>('source_routine_day_id');
    if ($_column == null) return null;
    final manager = $$RoutineDaysTableTableManager(
      $_db,
      $_db.routineDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceRoutineDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WorkoutExercisesTable, List<WorkoutExercise>>
  _workoutExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutExercises,
    aliasName: 'workouts__id__workout_exercises__workout_id',
  );

  $$WorkoutExercisesTableProcessedTableManager get workoutExercisesRefs {
    final manager = $$WorkoutExercisesTableTableManager(
      $_db,
      $_db.workoutExercises,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PersonalRecordsTable, List<PersonalRecord>>
  _personalRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalRecords,
    aliasName: 'workouts__id__personal_records__workout_id',
  );

  $$PersonalRecordsTableProcessedTableManager get personalRecordsRefs {
    final manager = $$PersonalRecordsTableTableManager(
      $_db,
      $_db.personalRecords,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtTzOffsetMinutes => $composableBuilder(
    column: $table.startedAtTzOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bodyweightGrams => $composableBuilder(
    column: $table.bodyweightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get perceivedFatigue => $composableBuilder(
    column: $table.perceivedFatigue,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutineDaysTableFilterComposer get sourceRoutineDayId {
    final $$RoutineDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceRoutineDayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableFilterComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> workoutExercisesRefs(
    Expression<bool> Function($$WorkoutExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> personalRecordsRefs(
    Expression<bool> Function($$PersonalRecordsTableFilterComposer f) f,
  ) {
    final $$PersonalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtTzOffsetMinutes => $composableBuilder(
    column: $table.startedAtTzOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bodyweightGrams => $composableBuilder(
    column: $table.bodyweightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get perceivedFatigue => $composableBuilder(
    column: $table.perceivedFatigue,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutineDaysTableOrderingComposer get sourceRoutineDayId {
    final $$RoutineDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceRoutineDayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableOrderingComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get startedAtTzOffsetMinutes => $composableBuilder(
    column: $table.startedAtTzOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get bodyweightGrams => $composableBuilder(
    column: $table.bodyweightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<int> get perceivedFatigue => $composableBuilder(
    column: $table.perceivedFatigue,
    builder: (column) => column,
  );

  $$RoutineDaysTableAnnotationComposer get sourceRoutineDayId {
    final $$RoutineDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceRoutineDayId,
      referencedTable: $db.routineDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.routineDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> workoutExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutExercisesTableAnnotationComposer a) f,
  ) {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> personalRecordsRefs<T extends Object>(
    Expression<T> Function($$PersonalRecordsTableAnnotationComposer a) f,
  ) {
    final $$PersonalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutsTable,
          Workout,
          $$WorkoutsTableFilterComposer,
          $$WorkoutsTableOrderingComposer,
          $$WorkoutsTableAnnotationComposer,
          $$WorkoutsTableCreateCompanionBuilder,
          $$WorkoutsTableUpdateCompanionBuilder,
          (Workout, $$WorkoutsTableReferences),
          Workout,
          PrefetchHooks Function({
            bool sourceRoutineDayId,
            bool workoutExercisesRefs,
            bool personalRecordsRefs,
          })
        > {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> sourceRoutineDayId = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> startedAtTzOffsetMinutes = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> bodyweightGrams = const Value.absent(),
                Value<int?> perceivedFatigue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutsCompanion(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                sourceRoutineDayId: sourceRoutineDayId,
                startedAt: startedAt,
                startedAtTzOffsetMinutes: startedAtTzOffsetMinutes,
                endedAt: endedAt,
                notes: notes,
                bodyweightGrams: bodyweightGrams,
                perceivedFatigue: perceivedFatigue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String name,
                Value<String?> sourceRoutineDayId = const Value.absent(),
                required int startedAt,
                required int startedAtTzOffsetMinutes,
                Value<int?> endedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> bodyweightGrams = const Value.absent(),
                Value<int?> perceivedFatigue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutsCompanion.insert(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                sourceRoutineDayId: sourceRoutineDayId,
                startedAt: startedAt,
                startedAtTzOffsetMinutes: startedAtTzOffsetMinutes,
                endedAt: endedAt,
                notes: notes,
                bodyweightGrams: bodyweightGrams,
                perceivedFatigue: perceivedFatigue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceRoutineDayId = false,
                workoutExercisesRefs = false,
                personalRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutExercisesRefs) db.workoutExercises,
                    if (personalRecordsRefs) db.personalRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceRoutineDayId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceRoutineDayId,
                                    referencedTable: $$WorkoutsTableReferences
                                        ._sourceRoutineDayIdTable(db),
                                    referencedColumn: $$WorkoutsTableReferences
                                        ._sourceRoutineDayIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutExercisesRefs)
                        await $_getPrefetchedData<
                          Workout,
                          $WorkoutsTable,
                          WorkoutExercise
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutsTableReferences
                              ._workoutExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personalRecordsRefs)
                        await $_getPrefetchedData<
                          Workout,
                          $WorkoutsTable,
                          PersonalRecord
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutsTableReferences
                              ._personalRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).personalRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutsTable,
      Workout,
      $$WorkoutsTableFilterComposer,
      $$WorkoutsTableOrderingComposer,
      $$WorkoutsTableAnnotationComposer,
      $$WorkoutsTableCreateCompanionBuilder,
      $$WorkoutsTableUpdateCompanionBuilder,
      (Workout, $$WorkoutsTableReferences),
      Workout,
      PrefetchHooks Function({
        bool sourceRoutineDayId,
        bool workoutExercisesRefs,
        bool personalRecordsRefs,
      })
    >;
typedef $$WorkoutExercisesTableCreateCompanionBuilder =
    WorkoutExercisesCompanion Function({
      required String id,
      Value<String> userId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String workoutId,
      required String exerciseId,
      required int position,
      Value<String?> groupId,
      Value<String?> notes,
      Value<String?> targetSnapshot,
      Value<int> rowid,
    });
typedef $$WorkoutExercisesTableUpdateCompanionBuilder =
    WorkoutExercisesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> workoutId,
      Value<String> exerciseId,
      Value<int> position,
      Value<String?> groupId,
      Value<String?> notes,
      Value<String?> targetSnapshot,
      Value<int> rowid,
    });

final class $$WorkoutExercisesTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkoutExercisesTable, WorkoutExercise> {
  $$WorkoutExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias('workout_exercises__workout_id__workouts__id');

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<String>('workout_id')!;

    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('workout_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SetsTable, List<WorkoutSet>> _setsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sets,
    aliasName: 'workout_exercises__id__sets__workout_exercise_id',
  );

  $$SetsTableProcessedTableManager get setsRefs {
    final manager = $$SetsTableTableManager($_db, $_db.sets).filter(
      (f) => f.workoutExerciseId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_setsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetSnapshot => $composableBuilder(
    column: $table.targetSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> setsRefs(
    Expression<bool> Function($$SetsTableFilterComposer f) f,
  ) {
    final $$SetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sets,
      getReferencedColumn: (t) => t.workoutExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetsTableFilterComposer(
            $db: $db,
            $table: $db.sets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetSnapshot => $composableBuilder(
    column: $table.targetSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get targetSnapshot => $composableBuilder(
    column: $table.targetSnapshot,
    builder: (column) => column,
  );

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> setsRefs<T extends Object>(
    Expression<T> Function($$SetsTableAnnotationComposer a) f,
  ) {
    final $$SetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sets,
      getReferencedColumn: (t) => t.workoutExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetsTableAnnotationComposer(
            $db: $db,
            $table: $db.sets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutExercisesTable,
          WorkoutExercise,
          $$WorkoutExercisesTableFilterComposer,
          $$WorkoutExercisesTableOrderingComposer,
          $$WorkoutExercisesTableAnnotationComposer,
          $$WorkoutExercisesTableCreateCompanionBuilder,
          $$WorkoutExercisesTableUpdateCompanionBuilder,
          (WorkoutExercise, $$WorkoutExercisesTableReferences),
          WorkoutExercise,
          PrefetchHooks Function({
            bool workoutId,
            bool exerciseId,
            bool setsRefs,
          })
        > {
  $$WorkoutExercisesTableTableManager(
    _$AppDatabase db,
    $WorkoutExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> workoutId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> targetSnapshot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutExercisesCompanion(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                workoutId: workoutId,
                exerciseId: exerciseId,
                position: position,
                groupId: groupId,
                notes: notes,
                targetSnapshot: targetSnapshot,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String workoutId,
                required String exerciseId,
                required int position,
                Value<String?> groupId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> targetSnapshot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutExercisesCompanion.insert(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                workoutId: workoutId,
                exerciseId: exerciseId,
                position: position,
                groupId: groupId,
                notes: notes,
                targetSnapshot: targetSnapshot,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutId = false, exerciseId = false, setsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (setsRefs) db.sets],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workoutId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutId,
                                    referencedTable:
                                        $$WorkoutExercisesTableReferences
                                            ._workoutIdTable(db),
                                    referencedColumn:
                                        $$WorkoutExercisesTableReferences
                                            ._workoutIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable:
                                        $$WorkoutExercisesTableReferences
                                            ._exerciseIdTable(db),
                                    referencedColumn:
                                        $$WorkoutExercisesTableReferences
                                            ._exerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (setsRefs)
                        await $_getPrefetchedData<
                          WorkoutExercise,
                          $WorkoutExercisesTable,
                          WorkoutSet
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutExercisesTableReferences
                              ._setsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).setsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutExerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutExercisesTable,
      WorkoutExercise,
      $$WorkoutExercisesTableFilterComposer,
      $$WorkoutExercisesTableOrderingComposer,
      $$WorkoutExercisesTableAnnotationComposer,
      $$WorkoutExercisesTableCreateCompanionBuilder,
      $$WorkoutExercisesTableUpdateCompanionBuilder,
      (WorkoutExercise, $$WorkoutExercisesTableReferences),
      WorkoutExercise,
      PrefetchHooks Function({bool workoutId, bool exerciseId, bool setsRefs})
    >;
typedef $$SetsTableCreateCompanionBuilder =
    SetsCompanion Function({
      required String id,
      Value<String> userId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String workoutExerciseId,
      required int position,
      Value<SetType> setType,
      Value<int?> weightGrams,
      Value<int?> reps,
      Value<double?> rpe,
      Value<int?> distanceMetres,
      Value<int?> durationSeconds,
      Value<bool> isCompleted,
      Value<int?> completedAt,
      Value<int?> completedAtTzOffsetMinutes,
      Value<int?> restTakenSeconds,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$SetsTableUpdateCompanionBuilder =
    SetsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> workoutExerciseId,
      Value<int> position,
      Value<SetType> setType,
      Value<int?> weightGrams,
      Value<int?> reps,
      Value<double?> rpe,
      Value<int?> distanceMetres,
      Value<int?> durationSeconds,
      Value<bool> isCompleted,
      Value<int?> completedAt,
      Value<int?> completedAtTzOffsetMinutes,
      Value<int?> restTakenSeconds,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$SetsTableReferences
    extends BaseReferences<_$AppDatabase, $SetsTable, WorkoutSet> {
  $$SetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutExercisesTable _workoutExerciseIdTable(_$AppDatabase db) => db
      .workoutExercises
      .createAlias('sets__workout_exercise_id__workout_exercises__id');

  $$WorkoutExercisesTableProcessedTableManager get workoutExerciseId {
    final $_column = $_itemColumn<String>('workout_exercise_id')!;

    final manager = $$WorkoutExercisesTableTableManager(
      $_db,
      $_db.workoutExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PersonalRecordsTable, List<PersonalRecord>>
  _personalRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalRecords,
    aliasName: 'sets__id__personal_records__set_id',
  );

  $$PersonalRecordsTableProcessedTableManager get personalRecordsRefs {
    final manager = $$PersonalRecordsTableTableManager(
      $_db,
      $_db.personalRecords,
    ).filter((f) => f.setId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SetsTableFilterComposer extends Composer<_$AppDatabase, $SetsTable> {
  $$SetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SetType, SetType, String> get setType =>
      $composableBuilder(
        column: $table.setType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceMetres => $composableBuilder(
    column: $table.distanceMetres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtTzOffsetMinutes => $composableBuilder(
    column: $table.completedAtTzOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restTakenSeconds => $composableBuilder(
    column: $table.restTakenSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutExercisesTableFilterComposer get workoutExerciseId {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutExerciseId,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> personalRecordsRefs(
    Expression<bool> Function($$PersonalRecordsTableFilterComposer f) f,
  ) {
    final $$PersonalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.setId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SetsTableOrderingComposer extends Composer<_$AppDatabase, $SetsTable> {
  $$SetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setType => $composableBuilder(
    column: $table.setType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceMetres => $composableBuilder(
    column: $table.distanceMetres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtTzOffsetMinutes => $composableBuilder(
    column: $table.completedAtTzOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restTakenSeconds => $composableBuilder(
    column: $table.restTakenSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutExercisesTableOrderingComposer get workoutExerciseId {
    final $$WorkoutExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutExerciseId,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetsTable> {
  $$SetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SetType, String> get setType =>
      $composableBuilder(column: $table.setType, builder: (column) => column);

  GeneratedColumn<int> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<int> get distanceMetres => $composableBuilder(
    column: $table.distanceMetres,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAtTzOffsetMinutes => $composableBuilder(
    column: $table.completedAtTzOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restTakenSeconds => $composableBuilder(
    column: $table.restTakenSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$WorkoutExercisesTableAnnotationComposer get workoutExerciseId {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutExerciseId,
      referencedTable: $db.workoutExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> personalRecordsRefs<T extends Object>(
    Expression<T> Function($$PersonalRecordsTableAnnotationComposer a) f,
  ) {
    final $$PersonalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.setId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetsTable,
          WorkoutSet,
          $$SetsTableFilterComposer,
          $$SetsTableOrderingComposer,
          $$SetsTableAnnotationComposer,
          $$SetsTableCreateCompanionBuilder,
          $$SetsTableUpdateCompanionBuilder,
          (WorkoutSet, $$SetsTableReferences),
          WorkoutSet,
          PrefetchHooks Function({
            bool workoutExerciseId,
            bool personalRecordsRefs,
          })
        > {
  $$SetsTableTableManager(_$AppDatabase db, $SetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> workoutExerciseId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<SetType> setType = const Value.absent(),
                Value<int?> weightGrams = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<int?> distanceMetres = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int?> completedAtTzOffsetMinutes = const Value.absent(),
                Value<int?> restTakenSeconds = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetsCompanion(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                workoutExerciseId: workoutExerciseId,
                position: position,
                setType: setType,
                weightGrams: weightGrams,
                reps: reps,
                rpe: rpe,
                distanceMetres: distanceMetres,
                durationSeconds: durationSeconds,
                isCompleted: isCompleted,
                completedAt: completedAt,
                completedAtTzOffsetMinutes: completedAtTzOffsetMinutes,
                restTakenSeconds: restTakenSeconds,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String workoutExerciseId,
                required int position,
                Value<SetType> setType = const Value.absent(),
                Value<int?> weightGrams = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<int?> distanceMetres = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int?> completedAtTzOffsetMinutes = const Value.absent(),
                Value<int?> restTakenSeconds = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetsCompanion.insert(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                workoutExerciseId: workoutExerciseId,
                position: position,
                setType: setType,
                weightGrams: weightGrams,
                reps: reps,
                rpe: rpe,
                distanceMetres: distanceMetres,
                durationSeconds: durationSeconds,
                isCompleted: isCompleted,
                completedAt: completedAt,
                completedAtTzOffsetMinutes: completedAtTzOffsetMinutes,
                restTakenSeconds: restTakenSeconds,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SetsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutExerciseId = false, personalRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (personalRecordsRefs) db.personalRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workoutExerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutExerciseId,
                                    referencedTable: $$SetsTableReferences
                                        ._workoutExerciseIdTable(db),
                                    referencedColumn: $$SetsTableReferences
                                        ._workoutExerciseIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (personalRecordsRefs)
                        await $_getPrefetchedData<
                          WorkoutSet,
                          $SetsTable,
                          PersonalRecord
                        >(
                          currentTable: table,
                          referencedTable: $$SetsTableReferences
                              ._personalRecordsRefsTable(db),
                          managerFromTypedResult: (p0) => $$SetsTableReferences(
                            db,
                            table,
                            p0,
                          ).personalRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.setId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetsTable,
      WorkoutSet,
      $$SetsTableFilterComposer,
      $$SetsTableOrderingComposer,
      $$SetsTableAnnotationComposer,
      $$SetsTableCreateCompanionBuilder,
      $$SetsTableUpdateCompanionBuilder,
      (WorkoutSet, $$SetsTableReferences),
      WorkoutSet,
      PrefetchHooks Function({bool workoutExerciseId, bool personalRecordsRefs})
    >;
typedef $$BodyMeasurementsTableCreateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      required String id,
      Value<String> userId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required int measuredAt,
      required int measuredAtTzOffsetMinutes,
      required MeasurementType type,
      required int valueCanonical,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$BodyMeasurementsTableUpdateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> measuredAt,
      Value<int> measuredAtTzOffsetMinutes,
      Value<MeasurementType> type,
      Value<int> valueCanonical,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$BodyMeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get measuredAtTzOffsetMinutes => $composableBuilder(
    column: $table.measuredAtTzOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MeasurementType, MeasurementType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get valueCanonical => $composableBuilder(
    column: $table.valueCanonical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyMeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get measuredAtTzOffsetMinutes => $composableBuilder(
    column: $table.measuredAtTzOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valueCanonical => $composableBuilder(
    column: $table.valueCanonical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyMeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get measuredAtTzOffsetMinutes => $composableBuilder(
    column: $table.measuredAtTzOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MeasurementType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get valueCanonical => $composableBuilder(
    column: $table.valueCanonical,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$BodyMeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyMeasurementsTable,
          BodyMeasurement,
          $$BodyMeasurementsTableFilterComposer,
          $$BodyMeasurementsTableOrderingComposer,
          $$BodyMeasurementsTableAnnotationComposer,
          $$BodyMeasurementsTableCreateCompanionBuilder,
          $$BodyMeasurementsTableUpdateCompanionBuilder,
          (
            BodyMeasurement,
            BaseReferences<
              _$AppDatabase,
              $BodyMeasurementsTable,
              BodyMeasurement
            >,
          ),
          BodyMeasurement,
          PrefetchHooks Function()
        > {
  $$BodyMeasurementsTableTableManager(
    _$AppDatabase db,
    $BodyMeasurementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyMeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> measuredAt = const Value.absent(),
                Value<int> measuredAtTzOffsetMinutes = const Value.absent(),
                Value<MeasurementType> type = const Value.absent(),
                Value<int> valueCanonical = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyMeasurementsCompanion(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                measuredAt: measuredAt,
                measuredAtTzOffsetMinutes: measuredAtTzOffsetMinutes,
                type: type,
                valueCanonical: valueCanonical,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required int measuredAt,
                required int measuredAtTzOffsetMinutes,
                required MeasurementType type,
                required int valueCanonical,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyMeasurementsCompanion.insert(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                measuredAt: measuredAt,
                measuredAtTzOffsetMinutes: measuredAtTzOffsetMinutes,
                type: type,
                valueCanonical: valueCanonical,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyMeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyMeasurementsTable,
      BodyMeasurement,
      $$BodyMeasurementsTableFilterComposer,
      $$BodyMeasurementsTableOrderingComposer,
      $$BodyMeasurementsTableAnnotationComposer,
      $$BodyMeasurementsTableCreateCompanionBuilder,
      $$BodyMeasurementsTableUpdateCompanionBuilder,
      (
        BodyMeasurement,
        BaseReferences<_$AppDatabase, $BodyMeasurementsTable, BodyMeasurement>,
      ),
      BodyMeasurement,
      PrefetchHooks Function()
    >;
typedef $$PersonalRecordsTableCreateCompanionBuilder =
    PersonalRecordsCompanion Function({
      required String id,
      Value<String> userId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String exerciseId,
      required PrKind kind,
      Value<int?> qualifier,
      required int value,
      Value<String?> setId,
      Value<String?> workoutId,
      required int achievedAt,
      Value<int> rowid,
    });
typedef $$PersonalRecordsTableUpdateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> exerciseId,
      Value<PrKind> kind,
      Value<int?> qualifier,
      Value<int> value,
      Value<String?> setId,
      Value<String?> workoutId,
      Value<int> achievedAt,
      Value<int> rowid,
    });

final class $$PersonalRecordsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PersonalRecordsTable, PersonalRecord> {
  $$PersonalRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('personal_records__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SetsTable _setIdTable(_$AppDatabase db) =>
      db.sets.createAlias('personal_records__set_id__sets__id');

  $$SetsTableProcessedTableManager? get setId {
    final $_column = $_itemColumn<String>('set_id');
    if ($_column == null) return null;
    final manager = $$SetsTableTableManager(
      $_db,
      $_db.sets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_setIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias('personal_records__workout_id__workouts__id');

  $$WorkoutsTableProcessedTableManager? get workoutId {
    final $_column = $_itemColumn<String>('workout_id');
    if ($_column == null) return null;
    final manager = $$WorkoutsTableTableManager(
      $_db,
      $_db.workouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PrKind, PrKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get qualifier => $composableBuilder(
    column: $table.qualifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SetsTableFilterComposer get setId {
    final $$SetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setId,
      referencedTable: $db.sets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetsTableFilterComposer(
            $db: $db,
            $table: $db.sets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qualifier => $composableBuilder(
    column: $table.qualifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SetsTableOrderingComposer get setId {
    final $$SetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setId,
      referencedTable: $db.sets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetsTableOrderingComposer(
            $db: $db,
            $table: $db.sets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PrKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get qualifier =>
      $composableBuilder(column: $table.qualifier, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SetsTableAnnotationComposer get setId {
    final $$SetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setId,
      referencedTable: $db.sets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SetsTableAnnotationComposer(
            $db: $db,
            $table: $db.sets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.workouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalRecordsTable,
          PersonalRecord,
          $$PersonalRecordsTableFilterComposer,
          $$PersonalRecordsTableOrderingComposer,
          $$PersonalRecordsTableAnnotationComposer,
          $$PersonalRecordsTableCreateCompanionBuilder,
          $$PersonalRecordsTableUpdateCompanionBuilder,
          (PersonalRecord, $$PersonalRecordsTableReferences),
          PersonalRecord,
          PrefetchHooks Function({bool exerciseId, bool setId, bool workoutId})
        > {
  $$PersonalRecordsTableTableManager(
    _$AppDatabase db,
    $PersonalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<PrKind> kind = const Value.absent(),
                Value<int?> qualifier = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<String?> setId = const Value.absent(),
                Value<String?> workoutId = const Value.absent(),
                Value<int> achievedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalRecordsCompanion(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                exerciseId: exerciseId,
                kind: kind,
                qualifier: qualifier,
                value: value,
                setId: setId,
                workoutId: workoutId,
                achievedAt: achievedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String exerciseId,
                required PrKind kind,
                Value<int?> qualifier = const Value.absent(),
                required int value,
                Value<String?> setId = const Value.absent(),
                Value<String?> workoutId = const Value.absent(),
                required int achievedAt,
                Value<int> rowid = const Value.absent(),
              }) => PersonalRecordsCompanion.insert(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                exerciseId: exerciseId,
                kind: kind,
                qualifier: qualifier,
                value: value,
                setId: setId,
                workoutId: workoutId,
                achievedAt: achievedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonalRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({exerciseId = false, setId = false, workoutId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable:
                                        $$PersonalRecordsTableReferences
                                            ._exerciseIdTable(db),
                                    referencedColumn:
                                        $$PersonalRecordsTableReferences
                                            ._exerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (setId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.setId,
                                    referencedTable:
                                        $$PersonalRecordsTableReferences
                                            ._setIdTable(db),
                                    referencedColumn:
                                        $$PersonalRecordsTableReferences
                                            ._setIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (workoutId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.workoutId,
                                    referencedTable:
                                        $$PersonalRecordsTableReferences
                                            ._workoutIdTable(db),
                                    referencedColumn:
                                        $$PersonalRecordsTableReferences
                                            ._workoutIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$PersonalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalRecordsTable,
      PersonalRecord,
      $$PersonalRecordsTableFilterComposer,
      $$PersonalRecordsTableOrderingComposer,
      $$PersonalRecordsTableAnnotationComposer,
      $$PersonalRecordsTableCreateCompanionBuilder,
      $$PersonalRecordsTableUpdateCompanionBuilder,
      (PersonalRecord, $$PersonalRecordsTableReferences),
      PersonalRecord,
      PrefetchHooks Function({bool exerciseId, bool setId, bool workoutId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String id,
      Value<String> userId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BarsTableTableManager get bars => $$BarsTableTableManager(_db, _db.bars);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$PlatesTableTableManager get plates =>
      $$PlatesTableTableManager(_db, _db.plates);
  $$RoutineFoldersTableTableManager get routineFolders =>
      $$RoutineFoldersTableTableManager(_db, _db.routineFolders);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$RoutineDaysTableTableManager get routineDays =>
      $$RoutineDaysTableTableManager(_db, _db.routineDays);
  $$RoutineExercisesTableTableManager get routineExercises =>
      $$RoutineExercisesTableTableManager(_db, _db.routineExercises);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$WorkoutExercisesTableTableManager get workoutExercises =>
      $$WorkoutExercisesTableTableManager(_db, _db.workoutExercises);
  $$SetsTableTableManager get sets => $$SetsTableTableManager(_db, _db.sets);
  $$BodyMeasurementsTableTableManager get bodyMeasurements =>
      $$BodyMeasurementsTableTableManager(_db, _db.bodyMeasurements);
  $$PersonalRecordsTableTableManager get personalRecords =>
      $$PersonalRecordsTableTableManager(_db, _db.personalRecords);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
