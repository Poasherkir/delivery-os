// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conventions_fixture.dart';

// ignore_for_file: type=lint
class $OwnedThingsTable extends OwnedThings
    with TableInfo<$OwnedThingsTable, OwnedThing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnedThingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($OwnedThingsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($OwnedThingsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($OwnedThingsTable.$converterdeletedAtn);
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  late final GeneratedColumnWithTypeConverter<Centimes, int> amount =
      GeneratedColumn<int>(
        'amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Centimes>($OwnedThingsTable.$converteramount);
  @override
  late final GeneratedColumnWithTypeConverter<PhoneE164?, String> phone =
      GeneratedColumn<String>(
        'phone',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<PhoneE164?>($OwnedThingsTable.$converterphonen);
  @override
  late final GeneratedColumnWithTypeConverter<GeoConfidence, int> confidence =
      GeneratedColumn<int>(
        'confidence',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<GeoConfidence>($OwnedThingsTable.$converterconfidence);
  @override
  late final GeneratedColumnWithTypeConverter<FixtureStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FixtureStatus>($OwnedThingsTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    name,
    amount,
    phone,
    confidence,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'owned_things';
  @override
  VerificationContext validateIntegrity(
    Insertable<OwnedThing> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OwnedThing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OwnedThing(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $OwnedThingsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $OwnedThingsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $OwnedThingsTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amount: $OwnedThingsTable.$converteramount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}amount'],
        )!,
      ),
      phone: $OwnedThingsTable.$converterphonen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}phone'],
        ),
      ),
      confidence: $OwnedThingsTable.$converterconfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}confidence'],
        )!,
      ),
      status: $OwnedThingsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $OwnedThingsTable createAlias(String alias) {
    return $OwnedThingsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<Centimes, int> $converteramount =
      const CentimesConverter();
  static TypeConverter<PhoneE164, String> $converterphone =
      const PhoneE164Converter();
  static TypeConverter<PhoneE164?, String?> $converterphonen =
      NullAwareTypeConverter.wrap($converterphone);
  static TypeConverter<GeoConfidence, int> $converterconfidence =
      const GeoConfidenceConverter();
  static TypeConverter<FixtureStatus, String> $converterstatus =
      const EnumTextConverter<FixtureStatus>(
        FixtureStatus.values,
        'FixtureStatus',
      );
}

class OwnedThing extends DataClass implements Insertable<OwnedThing> {
  final String id;

  /// The driver. Becomes the RLS predicate at V2 (§14).
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Soft delete. Null means live.
  final DateTime? deletedAt;

  /// Incremented on every write. Starts at 1.
  final int version;
  final String name;
  final Centimes amount;
  final PhoneE164? phone;
  final GeoConfidence confidence;
  final FixtureStatus status;
  const OwnedThing({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.name,
    required this.amount,
    this.phone,
    required this.confidence,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $OwnedThingsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $OwnedThingsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $OwnedThingsTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['version'] = Variable<int>(version);
    map['name'] = Variable<String>(name);
    {
      map['amount'] = Variable<int>(
        $OwnedThingsTable.$converteramount.toSql(amount),
      );
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(
        $OwnedThingsTable.$converterphonen.toSql(phone),
      );
    }
    {
      map['confidence'] = Variable<int>(
        $OwnedThingsTable.$converterconfidence.toSql(confidence),
      );
    }
    {
      map['status'] = Variable<String>(
        $OwnedThingsTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  OwnedThingsCompanion toCompanion(bool nullToAbsent) {
    return OwnedThingsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      name: Value(name),
      amount: Value(amount),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      confidence: Value(confidence),
      status: Value(status),
    );
  }

  factory OwnedThing.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OwnedThing(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<Centimes>(json['amount']),
      phone: serializer.fromJson<PhoneE164?>(json['phone']),
      confidence: serializer.fromJson<GeoConfidence>(json['confidence']),
      status: serializer.fromJson<FixtureStatus>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<Centimes>(amount),
      'phone': serializer.toJson<PhoneE164?>(phone),
      'confidence': serializer.toJson<GeoConfidence>(confidence),
      'status': serializer.toJson<FixtureStatus>(status),
    };
  }

  OwnedThing copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? name,
    Centimes? amount,
    Value<PhoneE164?> phone = const Value.absent(),
    GeoConfidence? confidence,
    FixtureStatus? status,
  }) => OwnedThing(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    phone: phone.present ? phone.value : this.phone,
    confidence: confidence ?? this.confidence,
    status: status ?? this.status,
  );
  OwnedThing copyWithCompanion(OwnedThingsCompanion data) {
    return OwnedThing(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      phone: data.phone.present ? data.phone.value : this.phone,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OwnedThing(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('phone: $phone, ')
          ..write('confidence: $confidence, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    name,
    amount,
    phone,
    confidence,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnedThing &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.phone == this.phone &&
          other.confidence == this.confidence &&
          other.status == this.status);
}

class OwnedThingsCompanion extends UpdateCompanion<OwnedThing> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> name;
  final Value<Centimes> amount;
  final Value<PhoneE164?> phone;
  final Value<GeoConfidence> confidence;
  final Value<FixtureStatus> status;
  final Value<int> rowid;
  const OwnedThingsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.phone = const Value.absent(),
    this.confidence = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OwnedThingsCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required int version,
    required String name,
    required Centimes amount,
    this.phone = const Value.absent(),
    required GeoConfidence confidence,
    required FixtureStatus status,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       version = Value(version),
       name = Value(name),
       amount = Value(amount),
       confidence = Value(confidence),
       status = Value(status);
  static Insertable<OwnedThing> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? version,
    Expression<String>? name,
    Expression<int>? amount,
    Expression<String>? phone,
    Expression<int>? confidence,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (phone != null) 'phone': phone,
      if (confidence != null) 'confidence': confidence,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OwnedThingsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? name,
    Value<Centimes>? amount,
    Value<PhoneE164?>? phone,
    Value<GeoConfidence>? confidence,
    Value<FixtureStatus>? status,
    Value<int>? rowid,
  }) {
    return OwnedThingsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      phone: phone ?? this.phone,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $OwnedThingsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $OwnedThingsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $OwnedThingsTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(
        $OwnedThingsTable.$converteramount.toSql(amount.value),
      );
    }
    if (phone.present) {
      map['phone'] = Variable<String>(
        $OwnedThingsTable.$converterphonen.toSql(phone.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<int>(
        $OwnedThingsTable.$converterconfidence.toSql(confidence.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $OwnedThingsTable.$converterstatus.toSql(status.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnedThingsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('phone: $phone, ')
          ..write('confidence: $confidence, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppendOnlyThingsTable extends AppendOnlyThings
    with TableInfo<$AppendOnlyThingsTable, AppendOnlyThing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppendOnlyThingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AppendOnlyThingsTable.$convertercreatedAt);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ownerId, createdAt, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'append_only_things';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppendOnlyThing> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppendOnlyThing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppendOnlyThing(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $AppendOnlyThingsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $AppendOnlyThingsTable createAlias(String alias) {
    return $AppendOnlyThingsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
}

class AppendOnlyThing extends DataClass implements Insertable<AppendOnlyThing> {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final String note;
  const AppendOnlyThing({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $AppendOnlyThingsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    map['note'] = Variable<String>(note);
    return map;
  }

  AppendOnlyThingsCompanion toCompanion(bool nullToAbsent) {
    return AppendOnlyThingsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      note: Value(note),
    );
  }

  factory AppendOnlyThing.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppendOnlyThing(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'note': serializer.toJson<String>(note),
    };
  }

  AppendOnlyThing copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    String? note,
  }) => AppendOnlyThing(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    note: note ?? this.note,
  );
  AppendOnlyThing copyWithCompanion(AppendOnlyThingsCompanion data) {
    return AppendOnlyThing(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppendOnlyThing(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ownerId, createdAt, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppendOnlyThing &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.note == this.note);
}

class AppendOnlyThingsCompanion extends UpdateCompanion<AppendOnlyThing> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<String> note;
  final Value<int> rowid;
  const AppendOnlyThingsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppendOnlyThingsCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required String note,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       note = Value(note);
  static Insertable<AppendOnlyThing> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppendOnlyThingsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return AppendOnlyThingsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $AppendOnlyThingsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppendOnlyThingsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StopThingsTable extends StopThings
    with TableInfo<$StopThingsTable, StopThing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StopThingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($StopThingsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($StopThingsTable.$converterupdatedAt);
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, updatedAt, sequence];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stop_things';
  @override
  VerificationContext validateIntegrity(
    Insertable<StopThing> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StopThing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StopThing(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: $StopThingsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $StopThingsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
    );
  }

  @override
  $StopThingsTable createAlias(String alias) {
    return $StopThingsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisecondsConverter();
}

class StopThing extends DataClass implements Insertable<StopThing> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sequence;
  const StopThing({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.sequence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['created_at'] = Variable<int>(
        $StopThingsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $StopThingsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    map['sequence'] = Variable<int>(sequence);
    return map;
  }

  StopThingsCompanion toCompanion(bool nullToAbsent) {
    return StopThingsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sequence: Value(sequence),
    );
  }

  factory StopThing.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StopThing(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sequence: serializer.fromJson<int>(json['sequence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sequence': serializer.toJson<int>(sequence),
    };
  }

  StopThing copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sequence,
  }) => StopThing(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sequence: sequence ?? this.sequence,
  );
  StopThing copyWithCompanion(StopThingsCompanion data) {
    return StopThing(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StopThing(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, sequence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StopThing &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sequence == this.sequence);
}

class StopThingsCompanion extends UpdateCompanion<StopThing> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> sequence;
  final Value<int> rowid;
  const StopThingsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sequence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StopThingsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int sequence,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       sequence = Value(sequence);
  static Insertable<StopThing> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? sequence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sequence != null) 'sequence': sequence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StopThingsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? sequence,
    Value<int>? rowid,
  }) {
    return StopThingsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sequence: sequence ?? this.sequence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $StopThingsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $StopThingsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StopThingsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sequence: $sequence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserThingsTable extends UserThings
    with TableInfo<$UserThingsTable, UserThing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserThingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($UserThingsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($UserThingsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($UserThingsTable.$converterdeletedAtn);
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    displayName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_things';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserThing> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserThing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserThing(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: $UserThingsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $UserThingsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $UserThingsTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
    );
  }

  @override
  $UserThingsTable createAlias(String alias) {
    return $UserThingsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class UserThing extends DataClass implements Insertable<UserThing> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String displayName;
  const UserThing({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.displayName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['created_at'] = Variable<int>(
        $UserThingsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $UserThingsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $UserThingsTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['display_name'] = Variable<String>(displayName);
    return map;
  }

  UserThingsCompanion toCompanion(bool nullToAbsent) {
    return UserThingsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      displayName: Value(displayName),
    );
  }

  factory UserThing.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserThing(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      displayName: serializer.fromJson<String>(json['displayName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'displayName': serializer.toJson<String>(displayName),
    };
  }

  UserThing copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? displayName,
  }) => UserThing(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    displayName: displayName ?? this.displayName,
  );
  UserThing copyWithCompanion(UserThingsCompanion data) {
    return UserThing(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserThing(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('displayName: $displayName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deletedAt, displayName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserThing &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.displayName == this.displayName);
}

class UserThingsCompanion extends UpdateCompanion<UserThing> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> displayName;
  final Value<int> rowid;
  const UserThingsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.displayName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserThingsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String displayName,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       displayName = Value(displayName);
  static Insertable<UserThing> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? displayName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (displayName != null) 'display_name': displayName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserThingsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? displayName,
    Value<int>? rowid,
  }) {
    return UserThingsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      displayName: displayName ?? this.displayName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $UserThingsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $UserThingsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $UserThingsTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserThingsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('displayName: $displayName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ConventionsFixtureDb extends GeneratedDatabase {
  _$ConventionsFixtureDb(QueryExecutor e) : super(e);
  $ConventionsFixtureDbManager get managers =>
      $ConventionsFixtureDbManager(this);
  late final $OwnedThingsTable ownedThings = $OwnedThingsTable(this);
  late final $AppendOnlyThingsTable appendOnlyThings = $AppendOnlyThingsTable(
    this,
  );
  late final $StopThingsTable stopThings = $StopThingsTable(this);
  late final $UserThingsTable userThings = $UserThingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ownedThings,
    appendOnlyThings,
    stopThings,
    userThings,
  ];
}

typedef $$OwnedThingsTableCreateCompanionBuilder =
    OwnedThingsCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required int version,
      required String name,
      required Centimes amount,
      Value<PhoneE164?> phone,
      required GeoConfidence confidence,
      required FixtureStatus status,
      Value<int> rowid,
    });
typedef $$OwnedThingsTableUpdateCompanionBuilder =
    OwnedThingsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> name,
      Value<Centimes> amount,
      Value<PhoneE164?> phone,
      Value<GeoConfidence> confidence,
      Value<FixtureStatus> status,
      Value<int> rowid,
    });

class $$OwnedThingsTableFilterComposer
    extends Composer<_$ConventionsFixtureDb, $OwnedThingsTable> {
  $$OwnedThingsTableFilterComposer({
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

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int> get amount =>
      $composableBuilder(
        column: $table.amount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PhoneE164?, PhoneE164, String> get phone =>
      $composableBuilder(
        column: $table.phone,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<GeoConfidence, GeoConfidence, int>
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<FixtureStatus, FixtureStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$OwnedThingsTableOrderingComposer
    extends Composer<_$ConventionsFixtureDb, $OwnedThingsTable> {
  $$OwnedThingsTableOrderingComposer({
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

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
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

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OwnedThingsTableAnnotationComposer
    extends Composer<_$ConventionsFixtureDb, $OwnedThingsTable> {
  $$OwnedThingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Centimes, int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PhoneE164?, String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GeoConfidence, int> get confidence =>
      $composableBuilder(
        column: $table.confidence,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<FixtureStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$OwnedThingsTableTableManager
    extends
        RootTableManager<
          _$ConventionsFixtureDb,
          $OwnedThingsTable,
          OwnedThing,
          $$OwnedThingsTableFilterComposer,
          $$OwnedThingsTableOrderingComposer,
          $$OwnedThingsTableAnnotationComposer,
          $$OwnedThingsTableCreateCompanionBuilder,
          $$OwnedThingsTableUpdateCompanionBuilder,
          (
            OwnedThing,
            BaseReferences<
              _$ConventionsFixtureDb,
              $OwnedThingsTable,
              OwnedThing
            >,
          ),
          OwnedThing,
          PrefetchHooks Function()
        > {
  $$OwnedThingsTableTableManager(
    _$ConventionsFixtureDb db,
    $OwnedThingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OwnedThingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OwnedThingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OwnedThingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<Centimes> amount = const Value.absent(),
                Value<PhoneE164?> phone = const Value.absent(),
                Value<GeoConfidence> confidence = const Value.absent(),
                Value<FixtureStatus> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OwnedThingsCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                name: name,
                amount: amount,
                phone: phone,
                confidence: confidence,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required int version,
                required String name,
                required Centimes amount,
                Value<PhoneE164?> phone = const Value.absent(),
                required GeoConfidence confidence,
                required FixtureStatus status,
                Value<int> rowid = const Value.absent(),
              }) => OwnedThingsCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                name: name,
                amount: amount,
                phone: phone,
                confidence: confidence,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OwnedThingsTableProcessedTableManager =
    ProcessedTableManager<
      _$ConventionsFixtureDb,
      $OwnedThingsTable,
      OwnedThing,
      $$OwnedThingsTableFilterComposer,
      $$OwnedThingsTableOrderingComposer,
      $$OwnedThingsTableAnnotationComposer,
      $$OwnedThingsTableCreateCompanionBuilder,
      $$OwnedThingsTableUpdateCompanionBuilder,
      (
        OwnedThing,
        BaseReferences<_$ConventionsFixtureDb, $OwnedThingsTable, OwnedThing>,
      ),
      OwnedThing,
      PrefetchHooks Function()
    >;
typedef $$AppendOnlyThingsTableCreateCompanionBuilder =
    AppendOnlyThingsCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required String note,
      Value<int> rowid,
    });
typedef $$AppendOnlyThingsTableUpdateCompanionBuilder =
    AppendOnlyThingsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<String> note,
      Value<int> rowid,
    });

class $$AppendOnlyThingsTableFilterComposer
    extends Composer<_$ConventionsFixtureDb, $AppendOnlyThingsTable> {
  $$AppendOnlyThingsTableFilterComposer({
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

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppendOnlyThingsTableOrderingComposer
    extends Composer<_$ConventionsFixtureDb, $AppendOnlyThingsTable> {
  $$AppendOnlyThingsTableOrderingComposer({
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

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppendOnlyThingsTableAnnotationComposer
    extends Composer<_$ConventionsFixtureDb, $AppendOnlyThingsTable> {
  $$AppendOnlyThingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$AppendOnlyThingsTableTableManager
    extends
        RootTableManager<
          _$ConventionsFixtureDb,
          $AppendOnlyThingsTable,
          AppendOnlyThing,
          $$AppendOnlyThingsTableFilterComposer,
          $$AppendOnlyThingsTableOrderingComposer,
          $$AppendOnlyThingsTableAnnotationComposer,
          $$AppendOnlyThingsTableCreateCompanionBuilder,
          $$AppendOnlyThingsTableUpdateCompanionBuilder,
          (
            AppendOnlyThing,
            BaseReferences<
              _$ConventionsFixtureDb,
              $AppendOnlyThingsTable,
              AppendOnlyThing
            >,
          ),
          AppendOnlyThing,
          PrefetchHooks Function()
        > {
  $$AppendOnlyThingsTableTableManager(
    _$ConventionsFixtureDb db,
    $AppendOnlyThingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppendOnlyThingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppendOnlyThingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppendOnlyThingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppendOnlyThingsCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required DateTime createdAt,
                required String note,
                Value<int> rowid = const Value.absent(),
              }) => AppendOnlyThingsCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppendOnlyThingsTableProcessedTableManager =
    ProcessedTableManager<
      _$ConventionsFixtureDb,
      $AppendOnlyThingsTable,
      AppendOnlyThing,
      $$AppendOnlyThingsTableFilterComposer,
      $$AppendOnlyThingsTableOrderingComposer,
      $$AppendOnlyThingsTableAnnotationComposer,
      $$AppendOnlyThingsTableCreateCompanionBuilder,
      $$AppendOnlyThingsTableUpdateCompanionBuilder,
      (
        AppendOnlyThing,
        BaseReferences<
          _$ConventionsFixtureDb,
          $AppendOnlyThingsTable,
          AppendOnlyThing
        >,
      ),
      AppendOnlyThing,
      PrefetchHooks Function()
    >;
typedef $$StopThingsTableCreateCompanionBuilder =
    StopThingsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required int sequence,
      Value<int> rowid,
    });
typedef $$StopThingsTableUpdateCompanionBuilder =
    StopThingsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> sequence,
      Value<int> rowid,
    });

class $$StopThingsTableFilterComposer
    extends Composer<_$ConventionsFixtureDb, $StopThingsTable> {
  $$StopThingsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StopThingsTableOrderingComposer
    extends Composer<_$ConventionsFixtureDb, $StopThingsTable> {
  $$StopThingsTableOrderingComposer({
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

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StopThingsTableAnnotationComposer
    extends Composer<_$ConventionsFixtureDb, $StopThingsTable> {
  $$StopThingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);
}

class $$StopThingsTableTableManager
    extends
        RootTableManager<
          _$ConventionsFixtureDb,
          $StopThingsTable,
          StopThing,
          $$StopThingsTableFilterComposer,
          $$StopThingsTableOrderingComposer,
          $$StopThingsTableAnnotationComposer,
          $$StopThingsTableCreateCompanionBuilder,
          $$StopThingsTableUpdateCompanionBuilder,
          (
            StopThing,
            BaseReferences<_$ConventionsFixtureDb, $StopThingsTable, StopThing>,
          ),
          StopThing,
          PrefetchHooks Function()
        > {
  $$StopThingsTableTableManager(
    _$ConventionsFixtureDb db,
    $StopThingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StopThingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StopThingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StopThingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StopThingsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sequence: sequence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required int sequence,
                Value<int> rowid = const Value.absent(),
              }) => StopThingsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sequence: sequence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StopThingsTableProcessedTableManager =
    ProcessedTableManager<
      _$ConventionsFixtureDb,
      $StopThingsTable,
      StopThing,
      $$StopThingsTableFilterComposer,
      $$StopThingsTableOrderingComposer,
      $$StopThingsTableAnnotationComposer,
      $$StopThingsTableCreateCompanionBuilder,
      $$StopThingsTableUpdateCompanionBuilder,
      (
        StopThing,
        BaseReferences<_$ConventionsFixtureDb, $StopThingsTable, StopThing>,
      ),
      StopThing,
      PrefetchHooks Function()
    >;
typedef $$UserThingsTableCreateCompanionBuilder =
    UserThingsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String displayName,
      Value<int> rowid,
    });
typedef $$UserThingsTableUpdateCompanionBuilder =
    UserThingsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> displayName,
      Value<int> rowid,
    });

class $$UserThingsTableFilterComposer
    extends Composer<_$ConventionsFixtureDb, $UserThingsTable> {
  $$UserThingsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserThingsTableOrderingComposer
    extends Composer<_$ConventionsFixtureDb, $UserThingsTable> {
  $$UserThingsTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserThingsTableAnnotationComposer
    extends Composer<_$ConventionsFixtureDb, $UserThingsTable> {
  $$UserThingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );
}

class $$UserThingsTableTableManager
    extends
        RootTableManager<
          _$ConventionsFixtureDb,
          $UserThingsTable,
          UserThing,
          $$UserThingsTableFilterComposer,
          $$UserThingsTableOrderingComposer,
          $$UserThingsTableAnnotationComposer,
          $$UserThingsTableCreateCompanionBuilder,
          $$UserThingsTableUpdateCompanionBuilder,
          (
            UserThing,
            BaseReferences<_$ConventionsFixtureDb, $UserThingsTable, UserThing>,
          ),
          UserThing,
          PrefetchHooks Function()
        > {
  $$UserThingsTableTableManager(
    _$ConventionsFixtureDb db,
    $UserThingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserThingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserThingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserThingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserThingsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                displayName: displayName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String displayName,
                Value<int> rowid = const Value.absent(),
              }) => UserThingsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                displayName: displayName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserThingsTableProcessedTableManager =
    ProcessedTableManager<
      _$ConventionsFixtureDb,
      $UserThingsTable,
      UserThing,
      $$UserThingsTableFilterComposer,
      $$UserThingsTableOrderingComposer,
      $$UserThingsTableAnnotationComposer,
      $$UserThingsTableCreateCompanionBuilder,
      $$UserThingsTableUpdateCompanionBuilder,
      (
        UserThing,
        BaseReferences<_$ConventionsFixtureDb, $UserThingsTable, UserThing>,
      ),
      UserThing,
      PrefetchHooks Function()
    >;

class $ConventionsFixtureDbManager {
  final _$ConventionsFixtureDb _db;
  $ConventionsFixtureDbManager(this._db);
  $$OwnedThingsTableTableManager get ownedThings =>
      $$OwnedThingsTableTableManager(_db, _db.ownedThings);
  $$AppendOnlyThingsTableTableManager get appendOnlyThings =>
      $$AppendOnlyThingsTableTableManager(_db, _db.appendOnlyThings);
  $$StopThingsTableTableManager get stopThings =>
      $$StopThingsTableTableManager(_db, _db.stopThings);
  $$UserThingsTableTableManager get userThings =>
      $$UserThingsTableTableManager(_db, _db.userThings);
}
