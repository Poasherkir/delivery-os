// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
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
      ).withConverter<DateTime>($UsersTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($UsersTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($UsersTable.$converterdeletedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<PhoneE164?, String> phone =
      GeneratedColumn<String>(
        'phone',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
      ).withConverter<PhoneE164?>($UsersTable.$converterphonen);
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ar'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    phone,
    displayName,
    locale,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
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
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: $UsersTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $UsersTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $UsersTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      phone: $UsersTable.$converterphonen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}phone'],
        ),
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<PhoneE164, String> $converterphone =
      const PhoneE164Converter();
  static TypeConverter<PhoneE164?, String?> $converterphonen =
      NullAwareTypeConverter.wrap($converterphone);
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Null until an account exists.
  ///
  /// The MVP has no signup, so requiring one would mean inventing a fake number
  /// and putting it in a unique identity column, where it would eventually be
  /// treated as real. SQLite permits many nulls in a unique index, so the
  /// constraint still holds once real numbers arrive at V2.
  final PhoneE164? phone;
  final String displayName;

  /// Language tag, `ar` or `fr`.
  ///
  /// Plain text rather than an enum converter, deliberately. A locale that this
  /// build no longer ships must degrade to "follow the device" rather than
  /// throw — dropping a language must not brick the app for whoever had it
  /// selected. `AppLocales.isSupported` decides; the column just stores.
  ///
  /// This is the value that *syncs* at V2. The value the first frame reads
  /// lives in shared preferences, because the encrypted database needs an async
  /// keystore round trip to open. Reconciling the two is M0-21's problem.
  final String locale;
  const User({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.phone,
    required this.displayName,
    required this.locale,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['created_at'] = Variable<int>(
        $UsersTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $UsersTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $UsersTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(
        $UsersTable.$converterphonen.toSql(phone),
      );
    }
    map['display_name'] = Variable<String>(displayName);
    map['locale'] = Variable<String>(locale);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      displayName: Value(displayName),
      locale: Value(locale),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      phone: serializer.fromJson<PhoneE164?>(json['phone']),
      displayName: serializer.fromJson<String>(json['displayName']),
      locale: serializer.fromJson<String>(json['locale']),
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
      'phone': serializer.toJson<PhoneE164?>(phone),
      'displayName': serializer.toJson<String>(displayName),
      'locale': serializer.toJson<String>(locale),
    };
  }

  User copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<PhoneE164?> phone = const Value.absent(),
    String? displayName,
    String? locale,
  }) => User(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    phone: phone.present ? phone.value : this.phone,
    displayName: displayName ?? this.displayName,
    locale: locale ?? this.locale,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      phone: data.phone.present ? data.phone.value : this.phone,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      locale: data.locale.present ? data.locale.value : this.locale,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('phone: $phone, ')
          ..write('displayName: $displayName, ')
          ..write('locale: $locale')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    phone,
    displayName,
    locale,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.phone == this.phone &&
          other.displayName == this.displayName &&
          other.locale == this.locale);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<PhoneE164?> phone;
  final Value<String> displayName;
  final Value<String> locale;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.phone = const Value.absent(),
    this.displayName = const Value.absent(),
    this.locale = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.phone = const Value.absent(),
    required String displayName,
    this.locale = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       displayName = Value(displayName);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? phone,
    Expression<String>? displayName,
    Expression<String>? locale,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (phone != null) 'phone': phone,
      if (displayName != null) 'display_name': displayName,
      if (locale != null) 'locale': locale,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<PhoneE164?>? phone,
    Value<String>? displayName,
    Value<String>? locale,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      locale: locale ?? this.locale,
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
        $UsersTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $UsersTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $UsersTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (phone.present) {
      map['phone'] = Variable<String>(
        $UsersTable.$converterphonen.toSql(phone.value),
      );
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('phone: $phone, ')
          ..write('displayName: $displayName, ')
          ..write('locale: $locale, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompaniesTable extends Companies
    with TableInfo<$CompaniesTable, Company> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompaniesTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CompaniesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CompaniesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CompaniesTable.$converterdeletedAtn);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoPathMeta = const VerificationMeta(
    'logoPath',
  );
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
    'logo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactPhoneMeta = const VerificationMeta(
    'contactPhone',
  );
  @override
  late final GeneratedColumn<String> contactPhone = GeneratedColumn<String>(
    'contact_phone',
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
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    name,
    logoPath,
    contactPhone,
    notes,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Company> instance, {
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
    if (data.containsKey('logo_path')) {
      context.handle(
        _logoPathMeta,
        logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta),
      );
    }
    if (data.containsKey('contact_phone')) {
      context.handle(
        _contactPhoneMeta,
        contactPhone.isAcceptableOrUnknown(
          data['contact_phone']!,
          _contactPhoneMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Company map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Company(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $CompaniesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $CompaniesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $CompaniesTable.$converterdeletedAtn.fromSql(
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
      logoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_path'],
      ),
      contactPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_phone'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $CompaniesTable createAlias(String alias) {
    return $CompaniesTable(attachedDatabase, alias);
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

class Company extends DataClass implements Insertable<Company> {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Soft delete. Null means live.
  final DateTime? deletedAt;

  /// Incremented on every write. Starts at 1.
  final int version;
  final String name;

  /// App-private path, not a MediaStore URI (§13).
  final String? logoPath;

  /// Free text, and deliberately **not** a `PhoneE164`.
  ///
  /// This is dial-and-display data, never an identity key: nothing joins on it
  /// and nothing de-duplicates by it. Agencies hand out things like
  /// "0770 11 22 33 / 021 44 55 66", which is useful to a driver and not a
  /// phone number. Only `customers.phone_e164` — where duplicate detection
  /// actually depends on normalization — gets the converter.
  final String? contactPhone;
  final String? notes;

  /// Inactive companies stay in history but are hidden from pickers. Distinct
  /// from `deleted_at`, which means the row should not have existed.
  final bool isActive;
  const Company({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.name,
    this.logoPath,
    this.contactPhone,
    this.notes,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $CompaniesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $CompaniesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $CompaniesTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['version'] = Variable<int>(version);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    if (!nullToAbsent || contactPhone != null) {
      map['contact_phone'] = Variable<String>(contactPhone);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CompaniesCompanion toCompanion(bool nullToAbsent) {
    return CompaniesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      name: Value(name),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      contactPhone: contactPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPhone),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
    );
  }

  factory Company.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Company(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      name: serializer.fromJson<String>(json['name']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      contactPhone: serializer.fromJson<String?>(json['contactPhone']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
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
      'logoPath': serializer.toJson<String?>(logoPath),
      'contactPhone': serializer.toJson<String?>(contactPhone),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Company copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? name,
    Value<String?> logoPath = const Value.absent(),
    Value<String?> contactPhone = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isActive,
  }) => Company(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    name: name ?? this.name,
    logoPath: logoPath.present ? logoPath.value : this.logoPath,
    contactPhone: contactPhone.present ? contactPhone.value : this.contactPhone,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
  );
  Company copyWithCompanion(CompaniesCompanion data) {
    return Company(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      name: data.name.present ? data.name.value : this.name,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      contactPhone: data.contactPhone.present
          ? data.contactPhone.value
          : this.contactPhone,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Company(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('logoPath: $logoPath, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive')
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
    logoPath,
    contactPhone,
    notes,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Company &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.name == this.name &&
          other.logoPath == this.logoPath &&
          other.contactPhone == this.contactPhone &&
          other.notes == this.notes &&
          other.isActive == this.isActive);
}

class CompaniesCompanion extends UpdateCompanion<Company> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> name;
  final Value<String?> logoPath;
  final Value<String?> contactPhone;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CompaniesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.name = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.contactPhone = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompaniesCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required int version,
    required String name,
    this.logoPath = const Value.absent(),
    this.contactPhone = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       version = Value(version),
       name = Value(name);
  static Insertable<Company> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? version,
    Expression<String>? name,
    Expression<String>? logoPath,
    Expression<String>? contactPhone,
    Expression<String>? notes,
    Expression<bool>? isActive,
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
      if (logoPath != null) 'logo_path': logoPath,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompaniesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? name,
    Value<String?>? logoPath,
    Value<String?>? contactPhone,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return CompaniesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      name: name ?? this.name,
      logoPath: logoPath ?? this.logoPath,
      contactPhone: contactPhone ?? this.contactPhone,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
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
        $CompaniesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $CompaniesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $CompaniesTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (contactPhone.present) {
      map['contact_phone'] = Variable<String>(contactPhone.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('logoPath: $logoPath, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentRulesTable extends PaymentRules
    with TableInfo<$PaymentRulesTable, PaymentRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentRulesTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PaymentRulesTable.$convertercreatedAt);
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _ruleVersionMeta = const VerificationMeta(
    'ruleVersion',
  );
  @override
  late final GeneratedColumn<int> ruleVersion = GeneratedColumn<int>(
    'rule_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _specMeta = const VerificationMeta('spec');
  @override
  late final GeneratedColumn<String> spec = GeneratedColumn<String>(
    'spec',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<String> effectiveFrom = GeneratedColumn<String>(
    'effective_from',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    companyId,
    ruleVersion,
    spec,
    effectiveFrom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentRule> instance, {
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
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('rule_version')) {
      context.handle(
        _ruleVersionMeta,
        ruleVersion.isAcceptableOrUnknown(
          data['rule_version']!,
          _ruleVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ruleVersionMeta);
    }
    if (data.containsKey('spec')) {
      context.handle(
        _specMeta,
        spec.isAcceptableOrUnknown(data['spec']!, _specMeta),
      );
    } else if (isInserting) {
      context.missing(_specMeta);
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {companyId, ruleVersion},
  ];
  @override
  PaymentRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $PaymentRulesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      ruleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_version'],
      )!,
      spec: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spec'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_from'],
      )!,
    );
  }

  @override
  $PaymentRulesTable createAlias(String alias) {
    return $PaymentRulesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
}

class PaymentRule extends DataClass implements Insertable<PaymentRule> {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final String companyId;

  /// The rule's own version number.
  ///
  /// **Business data, not the audit column from invariant 3.** This is the
  /// value `orders.payment_rule_version` pins. It is called `rule_version`
  /// rather than `version` precisely because the collision would otherwise get
  /// "fixed" one day by attaching an `EntityStamper` to it — which would make
  /// a company's rule history mutable and break every historical settlement.
  final int ruleVersion;

  /// The rule document, as raw JSON.
  ///
  /// **Deliberately not deserialized through a typed converter**, which is what
  /// this column most looks like it wants.
  ///
  /// Specs are pinned per order, and §12.2 requires that editing a company's
  /// rule never changes a historical settlement. A typed column binds every
  /// stored row to whatever shape the model has *today*: the day the spec gains
  /// a field or renames one, every historical rule becomes unreadable or —
  /// worse — silently reinterpreted, and the settlements computed from them can
  /// no longer be reproduced or audited.
  ///
  /// So the column stores bytes and the domain decides meaning. The document's
  /// own `version` field tells a version-aware parser which shape to expect,
  /// at the use site, in M3.
  final String spec;

  /// A calendar date, `YYYY-MM-DD`. Not a timestamp: a rule takes effect on a
  /// day, not at an instant, and giving it a time invites timezone confusion
  /// for no benefit (§6.1).
  final String effectiveFrom;
  const PaymentRule({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.companyId,
    required this.ruleVersion,
    required this.spec,
    required this.effectiveFrom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $PaymentRulesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    map['company_id'] = Variable<String>(companyId);
    map['rule_version'] = Variable<int>(ruleVersion);
    map['spec'] = Variable<String>(spec);
    map['effective_from'] = Variable<String>(effectiveFrom);
    return map;
  }

  PaymentRulesCompanion toCompanion(bool nullToAbsent) {
    return PaymentRulesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      companyId: Value(companyId),
      ruleVersion: Value(ruleVersion),
      spec: Value(spec),
      effectiveFrom: Value(effectiveFrom),
    );
  }

  factory PaymentRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRule(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      companyId: serializer.fromJson<String>(json['companyId']),
      ruleVersion: serializer.fromJson<int>(json['ruleVersion']),
      spec: serializer.fromJson<String>(json['spec']),
      effectiveFrom: serializer.fromJson<String>(json['effectiveFrom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'companyId': serializer.toJson<String>(companyId),
      'ruleVersion': serializer.toJson<int>(ruleVersion),
      'spec': serializer.toJson<String>(spec),
      'effectiveFrom': serializer.toJson<String>(effectiveFrom),
    };
  }

  PaymentRule copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    String? companyId,
    int? ruleVersion,
    String? spec,
    String? effectiveFrom,
  }) => PaymentRule(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    companyId: companyId ?? this.companyId,
    ruleVersion: ruleVersion ?? this.ruleVersion,
    spec: spec ?? this.spec,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
  );
  PaymentRule copyWithCompanion(PaymentRulesCompanion data) {
    return PaymentRule(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      ruleVersion: data.ruleVersion.present
          ? data.ruleVersion.value
          : this.ruleVersion,
      spec: data.spec.present ? data.spec.value : this.spec,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRule(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('companyId: $companyId, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('spec: $spec, ')
          ..write('effectiveFrom: $effectiveFrom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    createdAt,
    companyId,
    ruleVersion,
    spec,
    effectiveFrom,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRule &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.companyId == this.companyId &&
          other.ruleVersion == this.ruleVersion &&
          other.spec == this.spec &&
          other.effectiveFrom == this.effectiveFrom);
}

class PaymentRulesCompanion extends UpdateCompanion<PaymentRule> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<String> companyId;
  final Value<int> ruleVersion;
  final Value<String> spec;
  final Value<String> effectiveFrom;
  final Value<int> rowid;
  const PaymentRulesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.companyId = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.spec = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentRulesCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required String companyId,
    required int ruleVersion,
    required String spec,
    required String effectiveFrom,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       companyId = Value(companyId),
       ruleVersion = Value(ruleVersion),
       spec = Value(spec),
       effectiveFrom = Value(effectiveFrom);
  static Insertable<PaymentRule> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<String>? companyId,
    Expression<int>? ruleVersion,
    Expression<String>? spec,
    Expression<String>? effectiveFrom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (companyId != null) 'company_id': companyId,
      if (ruleVersion != null) 'rule_version': ruleVersion,
      if (spec != null) 'spec': spec,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<String>? companyId,
    Value<int>? ruleVersion,
    Value<String>? spec,
    Value<String>? effectiveFrom,
    Value<int>? rowid,
  }) {
    return PaymentRulesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      companyId: companyId ?? this.companyId,
      ruleVersion: ruleVersion ?? this.ruleVersion,
      spec: spec ?? this.spec,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
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
        $PaymentRulesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (ruleVersion.present) {
      map['rule_version'] = Variable<int>(ruleVersion.value);
    }
    if (spec.present) {
      map['spec'] = Variable<String>(spec.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<String>(effectiveFrom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRulesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('companyId: $companyId, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('spec: $spec, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WilayasTable extends Wilayas with TableInfo<$WilayasTable, Wilaya> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WilayasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<int> code = GeneratedColumn<int>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameFrMeta = const VerificationMeta('nameFr');
  @override
  late final GeneratedColumn<String> nameFr = GeneratedColumn<String>(
    'name_fr',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameArMeta = const VerificationMeta('nameAr');
  @override
  late final GeneratedColumn<String> nameAr = GeneratedColumn<String>(
    'name_ar',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geohashMeta = const VerificationMeta(
    'geohash',
  );
  @override
  late final GeneratedColumn<String> geohash = GeneratedColumn<String>(
    'geohash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    nameFr,
    nameAr,
    latitude,
    longitude,
    geohash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wilayas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Wilaya> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('name_fr')) {
      context.handle(
        _nameFrMeta,
        nameFr.isAcceptableOrUnknown(data['name_fr']!, _nameFrMeta),
      );
    } else if (isInserting) {
      context.missing(_nameFrMeta);
    }
    if (data.containsKey('name_ar')) {
      context.handle(
        _nameArMeta,
        nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('geohash')) {
      context.handle(
        _geohashMeta,
        geohash.isAcceptableOrUnknown(data['geohash']!, _geohashMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  Wilaya map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Wilaya(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}code'],
      )!,
      nameFr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_fr'],
      )!,
      nameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ar'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      geohash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geohash'],
      ),
    );
  }

  @override
  $WilayasTable createAlias(String alias) {
    return $WilayasTable(attachedDatabase, alias);
  }
}

class Wilaya extends DataClass implements Insertable<Wilaya> {
  final int code;
  final String nameFr;
  final String nameAr;

  /// Nullable: a dataset may ship names without coordinates, and a wilaya with
  /// no centroid is still a valid wilaya for the address picker. Better a
  /// usable list than no list.
  final double? latitude;
  final double? longitude;

  /// Precision-9 geohash of the centroid, for prefix proximity queries. SQLite
  /// has no PostGIS, so this is the index.
  final String? geohash;
  const Wilaya({
    required this.code,
    required this.nameFr,
    required this.nameAr,
    this.latitude,
    this.longitude,
    this.geohash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<int>(code);
    map['name_fr'] = Variable<String>(nameFr);
    map['name_ar'] = Variable<String>(nameAr);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || geohash != null) {
      map['geohash'] = Variable<String>(geohash);
    }
    return map;
  }

  WilayasCompanion toCompanion(bool nullToAbsent) {
    return WilayasCompanion(
      code: Value(code),
      nameFr: Value(nameFr),
      nameAr: Value(nameAr),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      geohash: geohash == null && nullToAbsent
          ? const Value.absent()
          : Value(geohash),
    );
  }

  factory Wilaya.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Wilaya(
      code: serializer.fromJson<int>(json['code']),
      nameFr: serializer.fromJson<String>(json['nameFr']),
      nameAr: serializer.fromJson<String>(json['nameAr']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      geohash: serializer.fromJson<String?>(json['geohash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<int>(code),
      'nameFr': serializer.toJson<String>(nameFr),
      'nameAr': serializer.toJson<String>(nameAr),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'geohash': serializer.toJson<String?>(geohash),
    };
  }

  Wilaya copyWith({
    int? code,
    String? nameFr,
    String? nameAr,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> geohash = const Value.absent(),
  }) => Wilaya(
    code: code ?? this.code,
    nameFr: nameFr ?? this.nameFr,
    nameAr: nameAr ?? this.nameAr,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    geohash: geohash.present ? geohash.value : this.geohash,
  );
  Wilaya copyWithCompanion(WilayasCompanion data) {
    return Wilaya(
      code: data.code.present ? data.code.value : this.code,
      nameFr: data.nameFr.present ? data.nameFr.value : this.nameFr,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      geohash: data.geohash.present ? data.geohash.value : this.geohash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Wilaya(')
          ..write('code: $code, ')
          ..write('nameFr: $nameFr, ')
          ..write('nameAr: $nameAr, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geohash: $geohash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(code, nameFr, nameAr, latitude, longitude, geohash);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wilaya &&
          other.code == this.code &&
          other.nameFr == this.nameFr &&
          other.nameAr == this.nameAr &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.geohash == this.geohash);
}

class WilayasCompanion extends UpdateCompanion<Wilaya> {
  final Value<int> code;
  final Value<String> nameFr;
  final Value<String> nameAr;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> geohash;
  const WilayasCompanion({
    this.code = const Value.absent(),
    this.nameFr = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geohash = const Value.absent(),
  });
  WilayasCompanion.insert({
    this.code = const Value.absent(),
    required String nameFr,
    required String nameAr,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geohash = const Value.absent(),
  }) : nameFr = Value(nameFr),
       nameAr = Value(nameAr);
  static Insertable<Wilaya> custom({
    Expression<int>? code,
    Expression<String>? nameFr,
    Expression<String>? nameAr,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? geohash,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (nameFr != null) 'name_fr': nameFr,
      if (nameAr != null) 'name_ar': nameAr,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (geohash != null) 'geohash': geohash,
    });
  }

  WilayasCompanion copyWith({
    Value<int>? code,
    Value<String>? nameFr,
    Value<String>? nameAr,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? geohash,
  }) {
    return WilayasCompanion(
      code: code ?? this.code,
      nameFr: nameFr ?? this.nameFr,
      nameAr: nameAr ?? this.nameAr,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<int>(code.value);
    }
    if (nameFr.present) {
      map['name_fr'] = Variable<String>(nameFr.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (geohash.present) {
      map['geohash'] = Variable<String>(geohash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WilayasCompanion(')
          ..write('code: $code, ')
          ..write('nameFr: $nameFr, ')
          ..write('nameAr: $nameAr, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geohash: $geohash')
          ..write(')'))
        .toString();
  }
}

class $CommunesTable extends Communes with TableInfo<$CommunesTable, Commune> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommunesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wilayaCodeMeta = const VerificationMeta(
    'wilayaCode',
  );
  @override
  late final GeneratedColumn<int> wilayaCode = GeneratedColumn<int>(
    'wilaya_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wilayas (code)',
    ),
  );
  static const VerificationMeta _nameFrMeta = const VerificationMeta('nameFr');
  @override
  late final GeneratedColumn<String> nameFr = GeneratedColumn<String>(
    'name_fr',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameArMeta = const VerificationMeta('nameAr');
  @override
  late final GeneratedColumn<String> nameAr = GeneratedColumn<String>(
    'name_ar',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geohashMeta = const VerificationMeta(
    'geohash',
  );
  @override
  late final GeneratedColumn<String> geohash = GeneratedColumn<String>(
    'geohash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boundaryMeta = const VerificationMeta(
    'boundary',
  );
  @override
  late final GeneratedColumn<String> boundary = GeneratedColumn<String>(
    'boundary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wilayaCode,
    nameFr,
    nameAr,
    latitude,
    longitude,
    geohash,
    boundary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'communes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Commune> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('wilaya_code')) {
      context.handle(
        _wilayaCodeMeta,
        wilayaCode.isAcceptableOrUnknown(data['wilaya_code']!, _wilayaCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_wilayaCodeMeta);
    }
    if (data.containsKey('name_fr')) {
      context.handle(
        _nameFrMeta,
        nameFr.isAcceptableOrUnknown(data['name_fr']!, _nameFrMeta),
      );
    } else if (isInserting) {
      context.missing(_nameFrMeta);
    }
    if (data.containsKey('name_ar')) {
      context.handle(
        _nameArMeta,
        nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('geohash')) {
      context.handle(
        _geohashMeta,
        geohash.isAcceptableOrUnknown(data['geohash']!, _geohashMeta),
      );
    }
    if (data.containsKey('boundary')) {
      context.handle(
        _boundaryMeta,
        boundary.isAcceptableOrUnknown(data['boundary']!, _boundaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Commune map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Commune(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wilayaCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wilaya_code'],
      )!,
      nameFr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_fr'],
      )!,
      nameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ar'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      geohash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geohash'],
      ),
      boundary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boundary'],
      ),
    );
  }

  @override
  $CommunesTable createAlias(String alias) {
    return $CommunesTable(attachedDatabase, alias);
  }
}

class Commune extends DataClass implements Insertable<Commune> {
  final int id;
  final int wilayaCode;
  final String nameFr;
  final String nameAr;
  final double? latitude;
  final double? longitude;
  final String? geohash;

  /// GeoJSON polygon of the commune boundary. Nullable, and unused in M0.
  ///
  /// Point-in-polygon is the correct gate for promoting a captured pin to
  /// confidence 4 (§10.5, gate 2). A fixed radius from a centroid is not: an
  /// Algiers commune is a few square kilometres and a Saharan one is thousands,
  /// so no single radius serves both, and the centroid of a large desert
  /// commune can be tens of kilometres from every address in it.
  ///
  /// Present so the column exists if the bundled dataset carries boundaries. If
  /// it does not, nothing breaks and gate 2 degrades to a wilaya-scaled radius
  /// — weakest in the sparse south, where it matters least.
  final String? boundary;
  const Commune({
    required this.id,
    required this.wilayaCode,
    required this.nameFr,
    required this.nameAr,
    this.latitude,
    this.longitude,
    this.geohash,
    this.boundary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['wilaya_code'] = Variable<int>(wilayaCode);
    map['name_fr'] = Variable<String>(nameFr);
    map['name_ar'] = Variable<String>(nameAr);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || geohash != null) {
      map['geohash'] = Variable<String>(geohash);
    }
    if (!nullToAbsent || boundary != null) {
      map['boundary'] = Variable<String>(boundary);
    }
    return map;
  }

  CommunesCompanion toCompanion(bool nullToAbsent) {
    return CommunesCompanion(
      id: Value(id),
      wilayaCode: Value(wilayaCode),
      nameFr: Value(nameFr),
      nameAr: Value(nameAr),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      geohash: geohash == null && nullToAbsent
          ? const Value.absent()
          : Value(geohash),
      boundary: boundary == null && nullToAbsent
          ? const Value.absent()
          : Value(boundary),
    );
  }

  factory Commune.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Commune(
      id: serializer.fromJson<int>(json['id']),
      wilayaCode: serializer.fromJson<int>(json['wilayaCode']),
      nameFr: serializer.fromJson<String>(json['nameFr']),
      nameAr: serializer.fromJson<String>(json['nameAr']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      geohash: serializer.fromJson<String?>(json['geohash']),
      boundary: serializer.fromJson<String?>(json['boundary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wilayaCode': serializer.toJson<int>(wilayaCode),
      'nameFr': serializer.toJson<String>(nameFr),
      'nameAr': serializer.toJson<String>(nameAr),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'geohash': serializer.toJson<String?>(geohash),
      'boundary': serializer.toJson<String?>(boundary),
    };
  }

  Commune copyWith({
    int? id,
    int? wilayaCode,
    String? nameFr,
    String? nameAr,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> geohash = const Value.absent(),
    Value<String?> boundary = const Value.absent(),
  }) => Commune(
    id: id ?? this.id,
    wilayaCode: wilayaCode ?? this.wilayaCode,
    nameFr: nameFr ?? this.nameFr,
    nameAr: nameAr ?? this.nameAr,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    geohash: geohash.present ? geohash.value : this.geohash,
    boundary: boundary.present ? boundary.value : this.boundary,
  );
  Commune copyWithCompanion(CommunesCompanion data) {
    return Commune(
      id: data.id.present ? data.id.value : this.id,
      wilayaCode: data.wilayaCode.present
          ? data.wilayaCode.value
          : this.wilayaCode,
      nameFr: data.nameFr.present ? data.nameFr.value : this.nameFr,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      geohash: data.geohash.present ? data.geohash.value : this.geohash,
      boundary: data.boundary.present ? data.boundary.value : this.boundary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Commune(')
          ..write('id: $id, ')
          ..write('wilayaCode: $wilayaCode, ')
          ..write('nameFr: $nameFr, ')
          ..write('nameAr: $nameAr, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geohash: $geohash, ')
          ..write('boundary: $boundary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wilayaCode,
    nameFr,
    nameAr,
    latitude,
    longitude,
    geohash,
    boundary,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Commune &&
          other.id == this.id &&
          other.wilayaCode == this.wilayaCode &&
          other.nameFr == this.nameFr &&
          other.nameAr == this.nameAr &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.geohash == this.geohash &&
          other.boundary == this.boundary);
}

class CommunesCompanion extends UpdateCompanion<Commune> {
  final Value<int> id;
  final Value<int> wilayaCode;
  final Value<String> nameFr;
  final Value<String> nameAr;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> geohash;
  final Value<String?> boundary;
  const CommunesCompanion({
    this.id = const Value.absent(),
    this.wilayaCode = const Value.absent(),
    this.nameFr = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geohash = const Value.absent(),
    this.boundary = const Value.absent(),
  });
  CommunesCompanion.insert({
    this.id = const Value.absent(),
    required int wilayaCode,
    required String nameFr,
    required String nameAr,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geohash = const Value.absent(),
    this.boundary = const Value.absent(),
  }) : wilayaCode = Value(wilayaCode),
       nameFr = Value(nameFr),
       nameAr = Value(nameAr);
  static Insertable<Commune> custom({
    Expression<int>? id,
    Expression<int>? wilayaCode,
    Expression<String>? nameFr,
    Expression<String>? nameAr,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? geohash,
    Expression<String>? boundary,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wilayaCode != null) 'wilaya_code': wilayaCode,
      if (nameFr != null) 'name_fr': nameFr,
      if (nameAr != null) 'name_ar': nameAr,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (geohash != null) 'geohash': geohash,
      if (boundary != null) 'boundary': boundary,
    });
  }

  CommunesCompanion copyWith({
    Value<int>? id,
    Value<int>? wilayaCode,
    Value<String>? nameFr,
    Value<String>? nameAr,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? geohash,
    Value<String?>? boundary,
  }) {
    return CommunesCompanion(
      id: id ?? this.id,
      wilayaCode: wilayaCode ?? this.wilayaCode,
      nameFr: nameFr ?? this.nameFr,
      nameAr: nameAr ?? this.nameAr,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      boundary: boundary ?? this.boundary,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wilayaCode.present) {
      map['wilaya_code'] = Variable<int>(wilayaCode.value);
    }
    if (nameFr.present) {
      map['name_fr'] = Variable<String>(nameFr.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (geohash.present) {
      map['geohash'] = Variable<String>(geohash.value);
    }
    if (boundary.present) {
      map['boundary'] = Variable<String>(boundary.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommunesCompanion(')
          ..write('id: $id, ')
          ..write('wilayaCode: $wilayaCode, ')
          ..write('nameFr: $nameFr, ')
          ..write('nameAr: $nameAr, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geohash: $geohash, ')
          ..write('boundary: $boundary')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CustomersTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CustomersTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CustomersTable.$converterdeletedAtn);
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
  @override
  late final GeneratedColumnWithTypeConverter<PhoneE164, String> phoneE164 =
      GeneratedColumn<String>(
        'phone_e164',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PhoneE164>($CustomersTable.$converterphoneE164);
  @override
  late final GeneratedColumnWithTypeConverter<PhoneE164?, String> phoneAlt =
      GeneratedColumn<String>(
        'phone_alt',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<PhoneE164?>($CustomersTable.$converterphoneAltn);
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
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
  late final GeneratedColumnWithTypeConverter<CustomerRiskFlag, String>
  riskFlag = GeneratedColumn<String>(
    'risk_flag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  ).withConverter<CustomerRiskFlag>($CustomersTable.$converterriskFlag);
  static const VerificationMeta _totalOrdersMeta = const VerificationMeta(
    'totalOrders',
  );
  @override
  late final GeneratedColumn<int> totalOrders = GeneratedColumn<int>(
    'total_orders',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalDeliveredMeta = const VerificationMeta(
    'totalDelivered',
  );
  @override
  late final GeneratedColumn<int> totalDelivered = GeneratedColumn<int>(
    'total_delivered',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalFailedMeta = const VerificationMeta(
    'totalFailed',
  );
  @override
  late final GeneratedColumn<int> totalFailed = GeneratedColumn<int>(
    'total_failed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> lastDeliveredAt =
      GeneratedColumn<int>(
        'last_delivered_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CustomersTable.$converterlastDeliveredAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    phoneE164,
    phoneAlt,
    displayName,
    notes,
    riskFlag,
    totalOrders,
    totalDelivered,
    totalFailed,
    lastDeliveredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
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
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('total_orders')) {
      context.handle(
        _totalOrdersMeta,
        totalOrders.isAcceptableOrUnknown(
          data['total_orders']!,
          _totalOrdersMeta,
        ),
      );
    }
    if (data.containsKey('total_delivered')) {
      context.handle(
        _totalDeliveredMeta,
        totalDelivered.isAcceptableOrUnknown(
          data['total_delivered']!,
          _totalDeliveredMeta,
        ),
      );
    }
    if (data.containsKey('total_failed')) {
      context.handle(
        _totalFailedMeta,
        totalFailed.isAcceptableOrUnknown(
          data['total_failed']!,
          _totalFailedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ownerId, phoneE164},
  ];
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $CustomersTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $CustomersTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $CustomersTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      phoneE164: $CustomersTable.$converterphoneE164.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}phone_e164'],
        )!,
      ),
      phoneAlt: $CustomersTable.$converterphoneAltn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}phone_alt'],
        ),
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      riskFlag: $CustomersTable.$converterriskFlag.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}risk_flag'],
        )!,
      ),
      totalOrders: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_orders'],
      )!,
      totalDelivered: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_delivered'],
      )!,
      totalFailed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_failed'],
      )!,
      lastDeliveredAt: $CustomersTable.$converterlastDeliveredAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}last_delivered_at'],
        ),
      ),
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<PhoneE164, String> $converterphoneE164 =
      const PhoneE164Converter();
  static TypeConverter<PhoneE164, String> $converterphoneAlt =
      const PhoneE164Converter();
  static TypeConverter<PhoneE164?, String?> $converterphoneAltn =
      NullAwareTypeConverter.wrap($converterphoneAlt);
  static TypeConverter<CustomerRiskFlag, String> $converterriskFlag =
      const EnumTextConverter<CustomerRiskFlag>(
        CustomerRiskFlag.values,
        'CustomerRiskFlag',
      );
  static TypeConverter<DateTime, int> $converterlastDeliveredAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterlastDeliveredAtn =
      NullAwareTypeConverter.wrap($converterlastDeliveredAt);
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Soft delete. Null means live.
  final DateTime? deletedAt;

  /// Incremented on every write. Starts at 1.
  final int version;

  /// The identity key. Normalized to `+213XXXXXXXXX` on the way in, so every
  /// spelling of one number collapses to one row.
  final PhoneE164 phoneE164;

  /// A second number for the same person. Normalized too, but not part of the
  /// identity: nothing joins or de-duplicates on it.
  final PhoneE164? phoneAlt;
  final String displayName;
  final String? notes;

  /// Only ever set by a human. Nothing in the app infers this from delivery
  /// history — a customer who was out twice is not a problem customer, and a
  /// rule that decided otherwise would quietly build a blacklist nobody agreed
  /// to.
  final CustomerRiskFlag riskFlag;
  final int totalOrders;
  final int totalDelivered;
  final int totalFailed;
  final DateTime? lastDeliveredAt;
  const Customer({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.phoneE164,
    this.phoneAlt,
    required this.displayName,
    this.notes,
    required this.riskFlag,
    required this.totalOrders,
    required this.totalDelivered,
    required this.totalFailed,
    this.lastDeliveredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $CustomersTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $CustomersTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $CustomersTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['version'] = Variable<int>(version);
    {
      map['phone_e164'] = Variable<String>(
        $CustomersTable.$converterphoneE164.toSql(phoneE164),
      );
    }
    if (!nullToAbsent || phoneAlt != null) {
      map['phone_alt'] = Variable<String>(
        $CustomersTable.$converterphoneAltn.toSql(phoneAlt),
      );
    }
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    {
      map['risk_flag'] = Variable<String>(
        $CustomersTable.$converterriskFlag.toSql(riskFlag),
      );
    }
    map['total_orders'] = Variable<int>(totalOrders);
    map['total_delivered'] = Variable<int>(totalDelivered);
    map['total_failed'] = Variable<int>(totalFailed);
    if (!nullToAbsent || lastDeliveredAt != null) {
      map['last_delivered_at'] = Variable<int>(
        $CustomersTable.$converterlastDeliveredAtn.toSql(lastDeliveredAt),
      );
    }
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      phoneE164: Value(phoneE164),
      phoneAlt: phoneAlt == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneAlt),
      displayName: Value(displayName),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      riskFlag: Value(riskFlag),
      totalOrders: Value(totalOrders),
      totalDelivered: Value(totalDelivered),
      totalFailed: Value(totalFailed),
      lastDeliveredAt: lastDeliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDeliveredAt),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      phoneE164: serializer.fromJson<PhoneE164>(json['phoneE164']),
      phoneAlt: serializer.fromJson<PhoneE164?>(json['phoneAlt']),
      displayName: serializer.fromJson<String>(json['displayName']),
      notes: serializer.fromJson<String?>(json['notes']),
      riskFlag: serializer.fromJson<CustomerRiskFlag>(json['riskFlag']),
      totalOrders: serializer.fromJson<int>(json['totalOrders']),
      totalDelivered: serializer.fromJson<int>(json['totalDelivered']),
      totalFailed: serializer.fromJson<int>(json['totalFailed']),
      lastDeliveredAt: serializer.fromJson<DateTime?>(json['lastDeliveredAt']),
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
      'phoneE164': serializer.toJson<PhoneE164>(phoneE164),
      'phoneAlt': serializer.toJson<PhoneE164?>(phoneAlt),
      'displayName': serializer.toJson<String>(displayName),
      'notes': serializer.toJson<String?>(notes),
      'riskFlag': serializer.toJson<CustomerRiskFlag>(riskFlag),
      'totalOrders': serializer.toJson<int>(totalOrders),
      'totalDelivered': serializer.toJson<int>(totalDelivered),
      'totalFailed': serializer.toJson<int>(totalFailed),
      'lastDeliveredAt': serializer.toJson<DateTime?>(lastDeliveredAt),
    };
  }

  Customer copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    PhoneE164? phoneE164,
    Value<PhoneE164?> phoneAlt = const Value.absent(),
    String? displayName,
    Value<String?> notes = const Value.absent(),
    CustomerRiskFlag? riskFlag,
    int? totalOrders,
    int? totalDelivered,
    int? totalFailed,
    Value<DateTime?> lastDeliveredAt = const Value.absent(),
  }) => Customer(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    phoneE164: phoneE164 ?? this.phoneE164,
    phoneAlt: phoneAlt.present ? phoneAlt.value : this.phoneAlt,
    displayName: displayName ?? this.displayName,
    notes: notes.present ? notes.value : this.notes,
    riskFlag: riskFlag ?? this.riskFlag,
    totalOrders: totalOrders ?? this.totalOrders,
    totalDelivered: totalDelivered ?? this.totalDelivered,
    totalFailed: totalFailed ?? this.totalFailed,
    lastDeliveredAt: lastDeliveredAt.present
        ? lastDeliveredAt.value
        : this.lastDeliveredAt,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      phoneE164: data.phoneE164.present ? data.phoneE164.value : this.phoneE164,
      phoneAlt: data.phoneAlt.present ? data.phoneAlt.value : this.phoneAlt,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      notes: data.notes.present ? data.notes.value : this.notes,
      riskFlag: data.riskFlag.present ? data.riskFlag.value : this.riskFlag,
      totalOrders: data.totalOrders.present
          ? data.totalOrders.value
          : this.totalOrders,
      totalDelivered: data.totalDelivered.present
          ? data.totalDelivered.value
          : this.totalDelivered,
      totalFailed: data.totalFailed.present
          ? data.totalFailed.value
          : this.totalFailed,
      lastDeliveredAt: data.lastDeliveredAt.present
          ? data.lastDeliveredAt.value
          : this.lastDeliveredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('phoneAlt: $phoneAlt, ')
          ..write('displayName: $displayName, ')
          ..write('notes: $notes, ')
          ..write('riskFlag: $riskFlag, ')
          ..write('totalOrders: $totalOrders, ')
          ..write('totalDelivered: $totalDelivered, ')
          ..write('totalFailed: $totalFailed, ')
          ..write('lastDeliveredAt: $lastDeliveredAt')
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
    phoneE164,
    phoneAlt,
    displayName,
    notes,
    riskFlag,
    totalOrders,
    totalDelivered,
    totalFailed,
    lastDeliveredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.phoneE164 == this.phoneE164 &&
          other.phoneAlt == this.phoneAlt &&
          other.displayName == this.displayName &&
          other.notes == this.notes &&
          other.riskFlag == this.riskFlag &&
          other.totalOrders == this.totalOrders &&
          other.totalDelivered == this.totalDelivered &&
          other.totalFailed == this.totalFailed &&
          other.lastDeliveredAt == this.lastDeliveredAt);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<PhoneE164> phoneE164;
  final Value<PhoneE164?> phoneAlt;
  final Value<String> displayName;
  final Value<String?> notes;
  final Value<CustomerRiskFlag> riskFlag;
  final Value<int> totalOrders;
  final Value<int> totalDelivered;
  final Value<int> totalFailed;
  final Value<DateTime?> lastDeliveredAt;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.phoneE164 = const Value.absent(),
    this.phoneAlt = const Value.absent(),
    this.displayName = const Value.absent(),
    this.notes = const Value.absent(),
    this.riskFlag = const Value.absent(),
    this.totalOrders = const Value.absent(),
    this.totalDelivered = const Value.absent(),
    this.totalFailed = const Value.absent(),
    this.lastDeliveredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required int version,
    required PhoneE164 phoneE164,
    this.phoneAlt = const Value.absent(),
    required String displayName,
    this.notes = const Value.absent(),
    this.riskFlag = const Value.absent(),
    this.totalOrders = const Value.absent(),
    this.totalDelivered = const Value.absent(),
    this.totalFailed = const Value.absent(),
    this.lastDeliveredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       version = Value(version),
       phoneE164 = Value(phoneE164),
       displayName = Value(displayName);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? version,
    Expression<String>? phoneE164,
    Expression<String>? phoneAlt,
    Expression<String>? displayName,
    Expression<String>? notes,
    Expression<String>? riskFlag,
    Expression<int>? totalOrders,
    Expression<int>? totalDelivered,
    Expression<int>? totalFailed,
    Expression<int>? lastDeliveredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (phoneE164 != null) 'phone_e164': phoneE164,
      if (phoneAlt != null) 'phone_alt': phoneAlt,
      if (displayName != null) 'display_name': displayName,
      if (notes != null) 'notes': notes,
      if (riskFlag != null) 'risk_flag': riskFlag,
      if (totalOrders != null) 'total_orders': totalOrders,
      if (totalDelivered != null) 'total_delivered': totalDelivered,
      if (totalFailed != null) 'total_failed': totalFailed,
      if (lastDeliveredAt != null) 'last_delivered_at': lastDeliveredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<PhoneE164>? phoneE164,
    Value<PhoneE164?>? phoneAlt,
    Value<String>? displayName,
    Value<String?>? notes,
    Value<CustomerRiskFlag>? riskFlag,
    Value<int>? totalOrders,
    Value<int>? totalDelivered,
    Value<int>? totalFailed,
    Value<DateTime?>? lastDeliveredAt,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      phoneE164: phoneE164 ?? this.phoneE164,
      phoneAlt: phoneAlt ?? this.phoneAlt,
      displayName: displayName ?? this.displayName,
      notes: notes ?? this.notes,
      riskFlag: riskFlag ?? this.riskFlag,
      totalOrders: totalOrders ?? this.totalOrders,
      totalDelivered: totalDelivered ?? this.totalDelivered,
      totalFailed: totalFailed ?? this.totalFailed,
      lastDeliveredAt: lastDeliveredAt ?? this.lastDeliveredAt,
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
        $CustomersTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $CustomersTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $CustomersTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (phoneE164.present) {
      map['phone_e164'] = Variable<String>(
        $CustomersTable.$converterphoneE164.toSql(phoneE164.value),
      );
    }
    if (phoneAlt.present) {
      map['phone_alt'] = Variable<String>(
        $CustomersTable.$converterphoneAltn.toSql(phoneAlt.value),
      );
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (riskFlag.present) {
      map['risk_flag'] = Variable<String>(
        $CustomersTable.$converterriskFlag.toSql(riskFlag.value),
      );
    }
    if (totalOrders.present) {
      map['total_orders'] = Variable<int>(totalOrders.value);
    }
    if (totalDelivered.present) {
      map['total_delivered'] = Variable<int>(totalDelivered.value);
    }
    if (totalFailed.present) {
      map['total_failed'] = Variable<int>(totalFailed.value);
    }
    if (lastDeliveredAt.present) {
      map['last_delivered_at'] = Variable<int>(
        $CustomersTable.$converterlastDeliveredAtn.toSql(lastDeliveredAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('phoneAlt: $phoneAlt, ')
          ..write('displayName: $displayName, ')
          ..write('notes: $notes, ')
          ..write('riskFlag: $riskFlag, ')
          ..write('totalOrders: $totalOrders, ')
          ..write('totalDelivered: $totalDelivered, ')
          ..write('totalFailed: $totalFailed, ')
          ..write('lastDeliveredAt: $lastDeliveredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomerAddressesTable extends CustomerAddresses
    with TableInfo<$CustomerAddressesTable, CustomerAddress> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerAddressesTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CustomerAddressesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CustomerAddressesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CustomerAddressesTable.$converterdeletedAtn);
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
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geohashMeta = const VerificationMeta(
    'geohash',
  );
  @override
  late final GeneratedColumn<String> geohash = GeneratedColumn<String>(
    'geohash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<int> accuracyM = GeneratedColumn<int>(
    'accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wilayaCodeMeta = const VerificationMeta(
    'wilayaCode',
  );
  @override
  late final GeneratedColumn<int> wilayaCode = GeneratedColumn<int>(
    'wilaya_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wilayas (code)',
    ),
  );
  static const VerificationMeta _communeIdMeta = const VerificationMeta(
    'communeId',
  );
  @override
  late final GeneratedColumn<int> communeId = GeneratedColumn<int>(
    'commune_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES communes (id)',
    ),
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GeoConfidence, int>
  geoConfidence =
      GeneratedColumn<int>(
        'geo_confidence',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<GeoConfidence>(
        $CustomerAddressesTable.$convertergeoConfidence,
      );
  static const VerificationMeta _geoSourceMeta = const VerificationMeta(
    'geoSource',
  );
  @override
  late final GeneratedColumn<String> geoSource = GeneratedColumn<String>(
    'geo_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confirmedDeliveriesMeta =
      const VerificationMeta('confirmedDeliveries');
  @override
  late final GeneratedColumn<int> confirmedDeliveries = GeneratedColumn<int>(
    'confirmed_deliveries',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    latitude,
    longitude,
    geohash,
    accuracyM,
    customerId,
    wilayaCode,
    communeId,
    detail,
    geoConfidence,
    geoSource,
    confirmedDeliveries,
    label,
    isPrimary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_addresses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerAddress> instance, {
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
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('geohash')) {
      context.handle(
        _geohashMeta,
        geohash.isAcceptableOrUnknown(data['geohash']!, _geohashMeta),
      );
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('wilaya_code')) {
      context.handle(
        _wilayaCodeMeta,
        wilayaCode.isAcceptableOrUnknown(data['wilaya_code']!, _wilayaCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_wilayaCodeMeta);
    }
    if (data.containsKey('commune_id')) {
      context.handle(
        _communeIdMeta,
        communeId.isAcceptableOrUnknown(data['commune_id']!, _communeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_communeIdMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    if (data.containsKey('geo_source')) {
      context.handle(
        _geoSourceMeta,
        geoSource.isAcceptableOrUnknown(data['geo_source']!, _geoSourceMeta),
      );
    }
    if (data.containsKey('confirmed_deliveries')) {
      context.handle(
        _confirmedDeliveriesMeta,
        confirmedDeliveries.isAcceptableOrUnknown(
          data['confirmed_deliveries']!,
          _confirmedDeliveriesMeta,
        ),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerAddress map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerAddress(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $CustomerAddressesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $CustomerAddressesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $CustomerAddressesTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      geohash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geohash'],
      ),
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuracy_m'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      wilayaCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wilaya_code'],
      )!,
      communeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}commune_id'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
      geoConfidence: $CustomerAddressesTable.$convertergeoConfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}geo_confidence'],
        )!,
      ),
      geoSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geo_source'],
      ),
      confirmedDeliveries: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confirmed_deliveries'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
    );
  }

  @override
  $CustomerAddressesTable createAlias(String alias) {
    return $CustomerAddressesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<GeoConfidence, int> $convertergeoConfidence =
      const GeoConfidenceConverter();
}

class CustomerAddress extends DataClass implements Insertable<CustomerAddress> {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Soft delete. Null means live.
  final DateTime? deletedAt;

  /// Incremented on every write. Starts at 1.
  final int version;
  final double? latitude;
  final double? longitude;

  /// Precision 9, roughly a 5-metre cell. Shorter prefixes are queried for
  /// coarser proximity.
  final String? geohash;

  /// The accuracy radius in metres that the platform reported with the fix.
  ///
  /// Captured at the moment of capture or not at all. Gate 3 of the pin
  /// promotion ladder: a fix taken indoors or in a stairwell can come back at
  /// 300 metres, and routing future deliveries from it degrades every route
  /// through that neighbourhood with nothing anywhere to notice. The threshold
  /// is an M2 decision made against real fixes in Algiers.
  final int? accuracyM;
  final String customerId;
  final int wilayaCode;
  final int communeId;

  /// Free text: cité, bloc, étage. The part no geocoder will ever resolve.
  final String? detail;

  /// 0 none, 1 commune centroid, 2 geocoded, 3 driver-pinned, 4 GPS-confirmed.
  /// Invariant 9: a confidence-0 address is never routed.
  final GeoConfidence geoConfidence;

  /// How the coordinate was obtained, for auditing the geocoder's quality.
  final String? geoSource;

  /// How many deliveries have confirmed this pin. The evidence behind the
  /// confidence tier.
  final int confirmedDeliveries;

  /// "maison", "travail".
  final String? label;
  final bool isPrimary;
  const CustomerAddress({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.latitude,
    this.longitude,
    this.geohash,
    this.accuracyM,
    required this.customerId,
    required this.wilayaCode,
    required this.communeId,
    this.detail,
    required this.geoConfidence,
    this.geoSource,
    required this.confirmedDeliveries,
    this.label,
    required this.isPrimary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $CustomerAddressesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $CustomerAddressesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $CustomerAddressesTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || geohash != null) {
      map['geohash'] = Variable<String>(geohash);
    }
    if (!nullToAbsent || accuracyM != null) {
      map['accuracy_m'] = Variable<int>(accuracyM);
    }
    map['customer_id'] = Variable<String>(customerId);
    map['wilaya_code'] = Variable<int>(wilayaCode);
    map['commune_id'] = Variable<int>(communeId);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    {
      map['geo_confidence'] = Variable<int>(
        $CustomerAddressesTable.$convertergeoConfidence.toSql(geoConfidence),
      );
    }
    if (!nullToAbsent || geoSource != null) {
      map['geo_source'] = Variable<String>(geoSource);
    }
    map['confirmed_deliveries'] = Variable<int>(confirmedDeliveries);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['is_primary'] = Variable<bool>(isPrimary);
    return map;
  }

  CustomerAddressesCompanion toCompanion(bool nullToAbsent) {
    return CustomerAddressesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      geohash: geohash == null && nullToAbsent
          ? const Value.absent()
          : Value(geohash),
      accuracyM: accuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyM),
      customerId: Value(customerId),
      wilayaCode: Value(wilayaCode),
      communeId: Value(communeId),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
      geoConfidence: Value(geoConfidence),
      geoSource: geoSource == null && nullToAbsent
          ? const Value.absent()
          : Value(geoSource),
      confirmedDeliveries: Value(confirmedDeliveries),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      isPrimary: Value(isPrimary),
    );
  }

  factory CustomerAddress.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerAddress(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      geohash: serializer.fromJson<String?>(json['geohash']),
      accuracyM: serializer.fromJson<int?>(json['accuracyM']),
      customerId: serializer.fromJson<String>(json['customerId']),
      wilayaCode: serializer.fromJson<int>(json['wilayaCode']),
      communeId: serializer.fromJson<int>(json['communeId']),
      detail: serializer.fromJson<String?>(json['detail']),
      geoConfidence: serializer.fromJson<GeoConfidence>(json['geoConfidence']),
      geoSource: serializer.fromJson<String?>(json['geoSource']),
      confirmedDeliveries: serializer.fromJson<int>(
        json['confirmedDeliveries'],
      ),
      label: serializer.fromJson<String?>(json['label']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
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
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'geohash': serializer.toJson<String?>(geohash),
      'accuracyM': serializer.toJson<int?>(accuracyM),
      'customerId': serializer.toJson<String>(customerId),
      'wilayaCode': serializer.toJson<int>(wilayaCode),
      'communeId': serializer.toJson<int>(communeId),
      'detail': serializer.toJson<String?>(detail),
      'geoConfidence': serializer.toJson<GeoConfidence>(geoConfidence),
      'geoSource': serializer.toJson<String?>(geoSource),
      'confirmedDeliveries': serializer.toJson<int>(confirmedDeliveries),
      'label': serializer.toJson<String?>(label),
      'isPrimary': serializer.toJson<bool>(isPrimary),
    };
  }

  CustomerAddress copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> geohash = const Value.absent(),
    Value<int?> accuracyM = const Value.absent(),
    String? customerId,
    int? wilayaCode,
    int? communeId,
    Value<String?> detail = const Value.absent(),
    GeoConfidence? geoConfidence,
    Value<String?> geoSource = const Value.absent(),
    int? confirmedDeliveries,
    Value<String?> label = const Value.absent(),
    bool? isPrimary,
  }) => CustomerAddress(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    geohash: geohash.present ? geohash.value : this.geohash,
    accuracyM: accuracyM.present ? accuracyM.value : this.accuracyM,
    customerId: customerId ?? this.customerId,
    wilayaCode: wilayaCode ?? this.wilayaCode,
    communeId: communeId ?? this.communeId,
    detail: detail.present ? detail.value : this.detail,
    geoConfidence: geoConfidence ?? this.geoConfidence,
    geoSource: geoSource.present ? geoSource.value : this.geoSource,
    confirmedDeliveries: confirmedDeliveries ?? this.confirmedDeliveries,
    label: label.present ? label.value : this.label,
    isPrimary: isPrimary ?? this.isPrimary,
  );
  CustomerAddress copyWithCompanion(CustomerAddressesCompanion data) {
    return CustomerAddress(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      geohash: data.geohash.present ? data.geohash.value : this.geohash,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      wilayaCode: data.wilayaCode.present
          ? data.wilayaCode.value
          : this.wilayaCode,
      communeId: data.communeId.present ? data.communeId.value : this.communeId,
      detail: data.detail.present ? data.detail.value : this.detail,
      geoConfidence: data.geoConfidence.present
          ? data.geoConfidence.value
          : this.geoConfidence,
      geoSource: data.geoSource.present ? data.geoSource.value : this.geoSource,
      confirmedDeliveries: data.confirmedDeliveries.present
          ? data.confirmedDeliveries.value
          : this.confirmedDeliveries,
      label: data.label.present ? data.label.value : this.label,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerAddress(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geohash: $geohash, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('customerId: $customerId, ')
          ..write('wilayaCode: $wilayaCode, ')
          ..write('communeId: $communeId, ')
          ..write('detail: $detail, ')
          ..write('geoConfidence: $geoConfidence, ')
          ..write('geoSource: $geoSource, ')
          ..write('confirmedDeliveries: $confirmedDeliveries, ')
          ..write('label: $label, ')
          ..write('isPrimary: $isPrimary')
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
    latitude,
    longitude,
    geohash,
    accuracyM,
    customerId,
    wilayaCode,
    communeId,
    detail,
    geoConfidence,
    geoSource,
    confirmedDeliveries,
    label,
    isPrimary,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerAddress &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.geohash == this.geohash &&
          other.accuracyM == this.accuracyM &&
          other.customerId == this.customerId &&
          other.wilayaCode == this.wilayaCode &&
          other.communeId == this.communeId &&
          other.detail == this.detail &&
          other.geoConfidence == this.geoConfidence &&
          other.geoSource == this.geoSource &&
          other.confirmedDeliveries == this.confirmedDeliveries &&
          other.label == this.label &&
          other.isPrimary == this.isPrimary);
}

class CustomerAddressesCompanion extends UpdateCompanion<CustomerAddress> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> geohash;
  final Value<int?> accuracyM;
  final Value<String> customerId;
  final Value<int> wilayaCode;
  final Value<int> communeId;
  final Value<String?> detail;
  final Value<GeoConfidence> geoConfidence;
  final Value<String?> geoSource;
  final Value<int> confirmedDeliveries;
  final Value<String?> label;
  final Value<bool> isPrimary;
  final Value<int> rowid;
  const CustomerAddressesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geohash = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.customerId = const Value.absent(),
    this.wilayaCode = const Value.absent(),
    this.communeId = const Value.absent(),
    this.detail = const Value.absent(),
    this.geoConfidence = const Value.absent(),
    this.geoSource = const Value.absent(),
    this.confirmedDeliveries = const Value.absent(),
    this.label = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerAddressesCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required int version,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geohash = const Value.absent(),
    this.accuracyM = const Value.absent(),
    required String customerId,
    required int wilayaCode,
    required int communeId,
    this.detail = const Value.absent(),
    this.geoConfidence = const Value.absent(),
    this.geoSource = const Value.absent(),
    this.confirmedDeliveries = const Value.absent(),
    this.label = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       version = Value(version),
       customerId = Value(customerId),
       wilayaCode = Value(wilayaCode),
       communeId = Value(communeId);
  static Insertable<CustomerAddress> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? version,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? geohash,
    Expression<int>? accuracyM,
    Expression<String>? customerId,
    Expression<int>? wilayaCode,
    Expression<int>? communeId,
    Expression<String>? detail,
    Expression<int>? geoConfidence,
    Expression<String>? geoSource,
    Expression<int>? confirmedDeliveries,
    Expression<String>? label,
    Expression<bool>? isPrimary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (geohash != null) 'geohash': geohash,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (customerId != null) 'customer_id': customerId,
      if (wilayaCode != null) 'wilaya_code': wilayaCode,
      if (communeId != null) 'commune_id': communeId,
      if (detail != null) 'detail': detail,
      if (geoConfidence != null) 'geo_confidence': geoConfidence,
      if (geoSource != null) 'geo_source': geoSource,
      if (confirmedDeliveries != null)
        'confirmed_deliveries': confirmedDeliveries,
      if (label != null) 'label': label,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomerAddressesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? geohash,
    Value<int?>? accuracyM,
    Value<String>? customerId,
    Value<int>? wilayaCode,
    Value<int>? communeId,
    Value<String?>? detail,
    Value<GeoConfidence>? geoConfidence,
    Value<String?>? geoSource,
    Value<int>? confirmedDeliveries,
    Value<String?>? label,
    Value<bool>? isPrimary,
    Value<int>? rowid,
  }) {
    return CustomerAddressesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      accuracyM: accuracyM ?? this.accuracyM,
      customerId: customerId ?? this.customerId,
      wilayaCode: wilayaCode ?? this.wilayaCode,
      communeId: communeId ?? this.communeId,
      detail: detail ?? this.detail,
      geoConfidence: geoConfidence ?? this.geoConfidence,
      geoSource: geoSource ?? this.geoSource,
      confirmedDeliveries: confirmedDeliveries ?? this.confirmedDeliveries,
      label: label ?? this.label,
      isPrimary: isPrimary ?? this.isPrimary,
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
        $CustomerAddressesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $CustomerAddressesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $CustomerAddressesTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (geohash.present) {
      map['geohash'] = Variable<String>(geohash.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<int>(accuracyM.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (wilayaCode.present) {
      map['wilaya_code'] = Variable<int>(wilayaCode.value);
    }
    if (communeId.present) {
      map['commune_id'] = Variable<int>(communeId.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (geoConfidence.present) {
      map['geo_confidence'] = Variable<int>(
        $CustomerAddressesTable.$convertergeoConfidence.toSql(
          geoConfidence.value,
        ),
      );
    }
    if (geoSource.present) {
      map['geo_source'] = Variable<String>(geoSource.value);
    }
    if (confirmedDeliveries.present) {
      map['confirmed_deliveries'] = Variable<int>(confirmedDeliveries.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerAddressesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geohash: $geohash, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('customerId: $customerId, ')
          ..write('wilayaCode: $wilayaCode, ')
          ..write('communeId: $communeId, ')
          ..write('detail: $detail, ')
          ..write('geoConfidence: $geoConfidence, ')
          ..write('geoSource: $geoSource, ')
          ..write('confirmedDeliveries: $confirmedDeliveries, ')
          ..write('label: $label, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BatchesTable extends Batches with TableInfo<$BatchesTable, Batch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchesTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($BatchesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($BatchesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($BatchesTable.$converterdeletedAtn);
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
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _serviceDateMeta = const VerificationMeta(
    'serviceDate',
  );
  @override
  late final GeneratedColumn<String> serviceDate = GeneratedColumn<String>(
    'service_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BatchStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('open'),
      ).withConverter<BatchStatus>($BatchesTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> closedAt =
      GeneratedColumn<int>(
        'closed_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($BatchesTable.$converterclosedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    companyId,
    serviceDate,
    status,
    closedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<Batch> instance, {
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
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('service_date')) {
      context.handle(
        _serviceDateMeta,
        serviceDate.isAcceptableOrUnknown(
          data['service_date']!,
          _serviceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ownerId, companyId, serviceDate},
  ];
  @override
  Batch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Batch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $BatchesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $BatchesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $BatchesTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      serviceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_date'],
      )!,
      status: $BatchesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      closedAt: $BatchesTable.$converterclosedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}closed_at'],
        ),
      ),
    );
  }

  @override
  $BatchesTable createAlias(String alias) {
    return $BatchesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<BatchStatus, String> $converterstatus =
      const EnumTextConverter<BatchStatus>(BatchStatus.values, 'BatchStatus');
  static TypeConverter<DateTime, int> $converterclosedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterclosedAtn =
      NullAwareTypeConverter.wrap($converterclosedAt);
}

class Batch extends DataClass implements Insertable<Batch> {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Soft delete. Null means live.
  final DateTime? deletedAt;

  /// Incremented on every write. Starts at 1.
  final int version;
  final String companyId;

  /// The business day, `YYYY-MM-DD`. Not a timestamp: a delivery at 00:30
  /// belongs to the previous working day, so the calendar date is its own fact
  /// rather than something derived from an instant (§6.1).
  final String serviceDate;

  /// open, closed, settled. A batch cannot reach `closed` while any of its
  /// orders is in an open state, and `settled` freezes it: corrections after
  /// that become `settlement_adjustments` rows, never edits (invariant 7).
  final BatchStatus status;
  final DateTime? closedAt;
  const Batch({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.companyId,
    required this.serviceDate,
    required this.status,
    this.closedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $BatchesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $BatchesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $BatchesTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['version'] = Variable<int>(version);
    map['company_id'] = Variable<String>(companyId);
    map['service_date'] = Variable<String>(serviceDate);
    {
      map['status'] = Variable<String>(
        $BatchesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<int>(
        $BatchesTable.$converterclosedAtn.toSql(closedAt),
      );
    }
    return map;
  }

  BatchesCompanion toCompanion(bool nullToAbsent) {
    return BatchesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      companyId: Value(companyId),
      serviceDate: Value(serviceDate),
      status: Value(status),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
    );
  }

  factory Batch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Batch(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      companyId: serializer.fromJson<String>(json['companyId']),
      serviceDate: serializer.fromJson<String>(json['serviceDate']),
      status: serializer.fromJson<BatchStatus>(json['status']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
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
      'companyId': serializer.toJson<String>(companyId),
      'serviceDate': serializer.toJson<String>(serviceDate),
      'status': serializer.toJson<BatchStatus>(status),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
    };
  }

  Batch copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? companyId,
    String? serviceDate,
    BatchStatus? status,
    Value<DateTime?> closedAt = const Value.absent(),
  }) => Batch(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    companyId: companyId ?? this.companyId,
    serviceDate: serviceDate ?? this.serviceDate,
    status: status ?? this.status,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
  );
  Batch copyWithCompanion(BatchesCompanion data) {
    return Batch(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      serviceDate: data.serviceDate.present
          ? data.serviceDate.value
          : this.serviceDate,
      status: data.status.present ? data.status.value : this.status,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Batch(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('companyId: $companyId, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('status: $status, ')
          ..write('closedAt: $closedAt')
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
    companyId,
    serviceDate,
    status,
    closedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Batch &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.companyId == this.companyId &&
          other.serviceDate == this.serviceDate &&
          other.status == this.status &&
          other.closedAt == this.closedAt);
}

class BatchesCompanion extends UpdateCompanion<Batch> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> companyId;
  final Value<String> serviceDate;
  final Value<BatchStatus> status;
  final Value<DateTime?> closedAt;
  final Value<int> rowid;
  const BatchesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.companyId = const Value.absent(),
    this.serviceDate = const Value.absent(),
    this.status = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BatchesCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required int version,
    required String companyId,
    required String serviceDate,
    this.status = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       version = Value(version),
       companyId = Value(companyId),
       serviceDate = Value(serviceDate);
  static Insertable<Batch> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? version,
    Expression<String>? companyId,
    Expression<String>? serviceDate,
    Expression<String>? status,
    Expression<int>? closedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (companyId != null) 'company_id': companyId,
      if (serviceDate != null) 'service_date': serviceDate,
      if (status != null) 'status': status,
      if (closedAt != null) 'closed_at': closedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? companyId,
    Value<String>? serviceDate,
    Value<BatchStatus>? status,
    Value<DateTime?>? closedAt,
    Value<int>? rowid,
  }) {
    return BatchesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      companyId: companyId ?? this.companyId,
      serviceDate: serviceDate ?? this.serviceDate,
      status: status ?? this.status,
      closedAt: closedAt ?? this.closedAt,
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
        $BatchesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $BatchesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $BatchesTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (serviceDate.present) {
      map['service_date'] = Variable<String>(serviceDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $BatchesTable.$converterstatus.toSql(status.value),
      );
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<int>(
        $BatchesTable.$converterclosedAtn.toSql(closedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('companyId: $companyId, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('status: $status, ')
          ..write('closedAt: $closedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, Order> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($OrdersTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($OrdersTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($OrdersTable.$converterdeletedAtn);
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
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES batches (id)',
    ),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _addressIdMeta = const VerificationMeta(
    'addressId',
  );
  @override
  late final GeneratedColumn<String> addressId = GeneratedColumn<String>(
    'address_id',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customer_addresses (id)',
    ),
  );
  static const VerificationMeta _trackingNumberMeta = const VerificationMeta(
    'trackingNumber',
  );
  @override
  late final GeneratedColumn<String> trackingNumber = GeneratedColumn<String>(
    'tracking_number',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DeliveryType, String>
  deliveryType = GeneratedColumn<String>(
    'delivery_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('home'),
  ).withConverter<DeliveryType>($OrdersTable.$converterdeliveryType);
  @override
  late final GeneratedColumnWithTypeConverter<OrderStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<OrderStatus>($OrdersTable.$converterstatus);
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _windowStartMeta = const VerificationMeta(
    'windowStart',
  );
  @override
  late final GeneratedColumn<String> windowStart = GeneratedColumn<String>(
    'window_start',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 5,
      maxTextLength: 5,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _windowEndMeta = const VerificationMeta(
    'windowEnd',
  );
  @override
  late final GeneratedColumn<String> windowEnd = GeneratedColumn<String>(
    'window_end',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 5,
      maxTextLength: 5,
    ),
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
  late final GeneratedColumnWithTypeConverter<Centimes, int> productValue =
      GeneratedColumn<int>(
        'product_value',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<Centimes>($OrdersTable.$converterproductValue);
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int> codAmount =
      GeneratedColumn<int>(
        'cod_amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<Centimes>($OrdersTable.$convertercodAmount);
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int> deliveryFee =
      GeneratedColumn<int>(
        'delivery_fee',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<Centimes>($OrdersTable.$converterdeliveryFee);
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int> companyAmount =
      GeneratedColumn<int>(
        'company_amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<Centimes>($OrdersTable.$convertercompanyAmount);
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int> driverCommission =
      GeneratedColumn<int>(
        'driver_commission',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<Centimes>($OrdersTable.$converterdriverCommission);
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int> otherFees =
      GeneratedColumn<int>(
        'other_fees',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<Centimes>($OrdersTable.$converterotherFees);
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int> collectedAmount =
      GeneratedColumn<int>(
        'collected_amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<Centimes>($OrdersTable.$convertercollectedAmount);
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod?, String>
  paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<PaymentMethod?>($OrdersTable.$converterpaymentMethodn);
  static const VerificationMeta _paymentRuleVersionMeta =
      const VerificationMeta('paymentRuleVersion');
  @override
  late final GeneratedColumn<int> paymentRuleVersion = GeneratedColumn<int>(
    'payment_rule_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deliveredAt =
      GeneratedColumn<int>(
        'delivered_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($OrdersTable.$converterdeliveredAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DeliveryAttemptOutcome?, String>
  failureReason =
      GeneratedColumn<String>(
        'failure_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DeliveryAttemptOutcome?>(
        $OrdersTable.$converterfailureReasonn,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    batchId,
    companyId,
    customerId,
    addressId,
    trackingNumber,
    deliveryType,
    status,
    priority,
    windowStart,
    windowEnd,
    notes,
    productValue,
    codAmount,
    deliveryFee,
    companyAmount,
    driverCommission,
    otherFees,
    collectedAmount,
    paymentMethod,
    paymentRuleVersion,
    attemptCount,
    deliveredAt,
    failureReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Order> instance, {
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
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('address_id')) {
      context.handle(
        _addressIdMeta,
        addressId.isAcceptableOrUnknown(data['address_id']!, _addressIdMeta),
      );
    }
    if (data.containsKey('tracking_number')) {
      context.handle(
        _trackingNumberMeta,
        trackingNumber.isAcceptableOrUnknown(
          data['tracking_number']!,
          _trackingNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trackingNumberMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('window_start')) {
      context.handle(
        _windowStartMeta,
        windowStart.isAcceptableOrUnknown(
          data['window_start']!,
          _windowStartMeta,
        ),
      );
    }
    if (data.containsKey('window_end')) {
      context.handle(
        _windowEndMeta,
        windowEnd.isAcceptableOrUnknown(data['window_end']!, _windowEndMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('payment_rule_version')) {
      context.handle(
        _paymentRuleVersionMeta,
        paymentRuleVersion.isAcceptableOrUnknown(
          data['payment_rule_version']!,
          _paymentRuleVersionMeta,
        ),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ownerId, companyId, trackingNumber},
  ];
  @override
  Order map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Order(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $OrdersTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $OrdersTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $OrdersTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      addressId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_id'],
      ),
      trackingNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tracking_number'],
      )!,
      deliveryType: $OrdersTable.$converterdeliveryType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}delivery_type'],
        )!,
      ),
      status: $OrdersTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      windowStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}window_start'],
      ),
      windowEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}window_end'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      productValue: $OrdersTable.$converterproductValue.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}product_value'],
        )!,
      ),
      codAmount: $OrdersTable.$convertercodAmount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}cod_amount'],
        )!,
      ),
      deliveryFee: $OrdersTable.$converterdeliveryFee.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}delivery_fee'],
        )!,
      ),
      companyAmount: $OrdersTable.$convertercompanyAmount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}company_amount'],
        )!,
      ),
      driverCommission: $OrdersTable.$converterdriverCommission.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}driver_commission'],
        )!,
      ),
      otherFees: $OrdersTable.$converterotherFees.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}other_fees'],
        )!,
      ),
      collectedAmount: $OrdersTable.$convertercollectedAmount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}collected_amount'],
        )!,
      ),
      paymentMethod: $OrdersTable.$converterpaymentMethodn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_method'],
        ),
      ),
      paymentRuleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_rule_version'],
      ),
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      deliveredAt: $OrdersTable.$converterdeliveredAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}delivered_at'],
        ),
      ),
      failureReason: $OrdersTable.$converterfailureReasonn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}failure_reason'],
        ),
      ),
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<DeliveryType, String> $converterdeliveryType =
      const EnumTextConverter<DeliveryType>(
        DeliveryType.values,
        'DeliveryType',
      );
  static TypeConverter<OrderStatus, String> $converterstatus =
      const EnumTextConverter<OrderStatus>(OrderStatus.values, 'OrderStatus');
  static TypeConverter<Centimes, int> $converterproductValue =
      const CentimesConverter();
  static TypeConverter<Centimes, int> $convertercodAmount =
      const CentimesConverter();
  static TypeConverter<Centimes, int> $converterdeliveryFee =
      const CentimesConverter();
  static TypeConverter<Centimes, int> $convertercompanyAmount =
      const CentimesConverter();
  static TypeConverter<Centimes, int> $converterdriverCommission =
      const CentimesConverter();
  static TypeConverter<Centimes, int> $converterotherFees =
      const CentimesConverter();
  static TypeConverter<Centimes, int> $convertercollectedAmount =
      const CentimesConverter();
  static TypeConverter<PaymentMethod, String> $converterpaymentMethod =
      const EnumTextConverter<PaymentMethod>(
        PaymentMethod.values,
        'PaymentMethod',
      );
  static TypeConverter<PaymentMethod?, String?> $converterpaymentMethodn =
      NullAwareTypeConverter.wrap($converterpaymentMethod);
  static TypeConverter<DateTime, int> $converterdeliveredAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterdeliveredAtn =
      NullAwareTypeConverter.wrap($converterdeliveredAt);
  static TypeConverter<DeliveryAttemptOutcome, String> $converterfailureReason =
      const EnumTextConverter<DeliveryAttemptOutcome>(
        DeliveryAttemptOutcome.values,
        'DeliveryAttemptOutcome',
      );
  static TypeConverter<DeliveryAttemptOutcome?, String?>
  $converterfailureReasonn = NullAwareTypeConverter.wrap(
    $converterfailureReason,
  );
}

class Order extends DataClass implements Insertable<Order> {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Soft delete. Null means live.
  final DateTime? deletedAt;

  /// Incremented on every write. Starts at 1.
  final int version;
  final String batchId;

  /// Denormalized from the batch so a company-scoped query needs no join, and
  /// so an order can never be silently reattributed by moving its batch. §14:
  /// a company must never read another company's orders even though they share
  /// a driver.
  final String companyId;

  /// Nullable: an order can be imported from a manifest before its customer
  /// record exists, and M1's entry flow must not block on that.
  final String? customerId;
  final String? addressId;

  /// Unique per company, never globally (§14). Two companies can and do use
  /// the same number.
  final String trackingNumber;

  /// Home or stop-desk. A stop-desk parcel never enters the optimizer but
  /// stays in the batch and in the money (§1.4).
  final DeliveryType deliveryType;

  /// Never assigned directly — invariant 6 routes every change through
  /// `OrderStateMachine.transitionTo`.
  final OrderStatus status;

  /// A cost penalty in the optimizer, not a hard constraint (§10.1).
  final int priority;

  /// `HH:MM`, local. Time windows are a V2 feature; the columns exist because
  /// adding them later means migrating a driver's live data.
  final String? windowStart;
  final String? windowEnd;
  final String? notes;

  /// What the goods are worth. Not what is collected.
  final Centimes productValue;

  /// What the customer owes at the door. Mutable with an audit trail: a
  /// merchant can negotiate a discount mid-delivery (§1.2).
  final Centimes codAmount;
  final Centimes deliveryFee;

  /// The residual: `cod_amount − driver_commission − other_fees`. Derived by
  /// subtraction, never rounded independently.
  final Centimes companyAmount;

  /// The one value a rule evaluation rounds, once (§12.2).
  final Centimes driverCommission;
  final Centimes otherFees;

  /// What was actually taken. Differs from [codAmount] when a discount was
  /// negotiated, and the difference is what a settlement has to explain.
  final Centimes collectedAmount;

  /// Only cash moves the driver's cash-on-hand figure (§12.4).
  final PaymentMethod? paymentMethod;

  /// Pinned at creation and never changed — invariant 8. Editing a company's
  /// rule creates version N+1 and leaves this alone, which is what keeps a
  /// months-old settlement reproducible.
  final int? paymentRuleVersion;
  final int attemptCount;
  final DateTime? deliveredAt;

  /// The outcome of the most recent failed attempt, denormalized from
  /// `delivery_attempts` so an order list renders without a join. The attempts
  /// table remains the record; this is a cache of its last row.
  final DeliveryAttemptOutcome? failureReason;
  const Order({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.batchId,
    required this.companyId,
    this.customerId,
    this.addressId,
    required this.trackingNumber,
    required this.deliveryType,
    required this.status,
    required this.priority,
    this.windowStart,
    this.windowEnd,
    this.notes,
    required this.productValue,
    required this.codAmount,
    required this.deliveryFee,
    required this.companyAmount,
    required this.driverCommission,
    required this.otherFees,
    required this.collectedAmount,
    this.paymentMethod,
    this.paymentRuleVersion,
    required this.attemptCount,
    this.deliveredAt,
    this.failureReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $OrdersTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $OrdersTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $OrdersTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['version'] = Variable<int>(version);
    map['batch_id'] = Variable<String>(batchId);
    map['company_id'] = Variable<String>(companyId);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || addressId != null) {
      map['address_id'] = Variable<String>(addressId);
    }
    map['tracking_number'] = Variable<String>(trackingNumber);
    {
      map['delivery_type'] = Variable<String>(
        $OrdersTable.$converterdeliveryType.toSql(deliveryType),
      );
    }
    {
      map['status'] = Variable<String>(
        $OrdersTable.$converterstatus.toSql(status),
      );
    }
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || windowStart != null) {
      map['window_start'] = Variable<String>(windowStart);
    }
    if (!nullToAbsent || windowEnd != null) {
      map['window_end'] = Variable<String>(windowEnd);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    {
      map['product_value'] = Variable<int>(
        $OrdersTable.$converterproductValue.toSql(productValue),
      );
    }
    {
      map['cod_amount'] = Variable<int>(
        $OrdersTable.$convertercodAmount.toSql(codAmount),
      );
    }
    {
      map['delivery_fee'] = Variable<int>(
        $OrdersTable.$converterdeliveryFee.toSql(deliveryFee),
      );
    }
    {
      map['company_amount'] = Variable<int>(
        $OrdersTable.$convertercompanyAmount.toSql(companyAmount),
      );
    }
    {
      map['driver_commission'] = Variable<int>(
        $OrdersTable.$converterdriverCommission.toSql(driverCommission),
      );
    }
    {
      map['other_fees'] = Variable<int>(
        $OrdersTable.$converterotherFees.toSql(otherFees),
      );
    }
    {
      map['collected_amount'] = Variable<int>(
        $OrdersTable.$convertercollectedAmount.toSql(collectedAmount),
      );
    }
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(
        $OrdersTable.$converterpaymentMethodn.toSql(paymentMethod),
      );
    }
    if (!nullToAbsent || paymentRuleVersion != null) {
      map['payment_rule_version'] = Variable<int>(paymentRuleVersion);
    }
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<int>(
        $OrdersTable.$converterdeliveredAtn.toSql(deliveredAt),
      );
    }
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(
        $OrdersTable.$converterfailureReasonn.toSql(failureReason),
      );
    }
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      batchId: Value(batchId),
      companyId: Value(companyId),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      addressId: addressId == null && nullToAbsent
          ? const Value.absent()
          : Value(addressId),
      trackingNumber: Value(trackingNumber),
      deliveryType: Value(deliveryType),
      status: Value(status),
      priority: Value(priority),
      windowStart: windowStart == null && nullToAbsent
          ? const Value.absent()
          : Value(windowStart),
      windowEnd: windowEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(windowEnd),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      productValue: Value(productValue),
      codAmount: Value(codAmount),
      deliveryFee: Value(deliveryFee),
      companyAmount: Value(companyAmount),
      driverCommission: Value(driverCommission),
      otherFees: Value(otherFees),
      collectedAmount: Value(collectedAmount),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      paymentRuleVersion: paymentRuleVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentRuleVersion),
      attemptCount: Value(attemptCount),
      deliveredAt: deliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAt),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
    );
  }

  factory Order.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      batchId: serializer.fromJson<String>(json['batchId']),
      companyId: serializer.fromJson<String>(json['companyId']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      addressId: serializer.fromJson<String?>(json['addressId']),
      trackingNumber: serializer.fromJson<String>(json['trackingNumber']),
      deliveryType: serializer.fromJson<DeliveryType>(json['deliveryType']),
      status: serializer.fromJson<OrderStatus>(json['status']),
      priority: serializer.fromJson<int>(json['priority']),
      windowStart: serializer.fromJson<String?>(json['windowStart']),
      windowEnd: serializer.fromJson<String?>(json['windowEnd']),
      notes: serializer.fromJson<String?>(json['notes']),
      productValue: serializer.fromJson<Centimes>(json['productValue']),
      codAmount: serializer.fromJson<Centimes>(json['codAmount']),
      deliveryFee: serializer.fromJson<Centimes>(json['deliveryFee']),
      companyAmount: serializer.fromJson<Centimes>(json['companyAmount']),
      driverCommission: serializer.fromJson<Centimes>(json['driverCommission']),
      otherFees: serializer.fromJson<Centimes>(json['otherFees']),
      collectedAmount: serializer.fromJson<Centimes>(json['collectedAmount']),
      paymentMethod: serializer.fromJson<PaymentMethod?>(json['paymentMethod']),
      paymentRuleVersion: serializer.fromJson<int?>(json['paymentRuleVersion']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      deliveredAt: serializer.fromJson<DateTime?>(json['deliveredAt']),
      failureReason: serializer.fromJson<DeliveryAttemptOutcome?>(
        json['failureReason'],
      ),
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
      'batchId': serializer.toJson<String>(batchId),
      'companyId': serializer.toJson<String>(companyId),
      'customerId': serializer.toJson<String?>(customerId),
      'addressId': serializer.toJson<String?>(addressId),
      'trackingNumber': serializer.toJson<String>(trackingNumber),
      'deliveryType': serializer.toJson<DeliveryType>(deliveryType),
      'status': serializer.toJson<OrderStatus>(status),
      'priority': serializer.toJson<int>(priority),
      'windowStart': serializer.toJson<String?>(windowStart),
      'windowEnd': serializer.toJson<String?>(windowEnd),
      'notes': serializer.toJson<String?>(notes),
      'productValue': serializer.toJson<Centimes>(productValue),
      'codAmount': serializer.toJson<Centimes>(codAmount),
      'deliveryFee': serializer.toJson<Centimes>(deliveryFee),
      'companyAmount': serializer.toJson<Centimes>(companyAmount),
      'driverCommission': serializer.toJson<Centimes>(driverCommission),
      'otherFees': serializer.toJson<Centimes>(otherFees),
      'collectedAmount': serializer.toJson<Centimes>(collectedAmount),
      'paymentMethod': serializer.toJson<PaymentMethod?>(paymentMethod),
      'paymentRuleVersion': serializer.toJson<int?>(paymentRuleVersion),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'deliveredAt': serializer.toJson<DateTime?>(deliveredAt),
      'failureReason': serializer.toJson<DeliveryAttemptOutcome?>(
        failureReason,
      ),
    };
  }

  Order copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? batchId,
    String? companyId,
    Value<String?> customerId = const Value.absent(),
    Value<String?> addressId = const Value.absent(),
    String? trackingNumber,
    DeliveryType? deliveryType,
    OrderStatus? status,
    int? priority,
    Value<String?> windowStart = const Value.absent(),
    Value<String?> windowEnd = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Centimes? productValue,
    Centimes? codAmount,
    Centimes? deliveryFee,
    Centimes? companyAmount,
    Centimes? driverCommission,
    Centimes? otherFees,
    Centimes? collectedAmount,
    Value<PaymentMethod?> paymentMethod = const Value.absent(),
    Value<int?> paymentRuleVersion = const Value.absent(),
    int? attemptCount,
    Value<DateTime?> deliveredAt = const Value.absent(),
    Value<DeliveryAttemptOutcome?> failureReason = const Value.absent(),
  }) => Order(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    batchId: batchId ?? this.batchId,
    companyId: companyId ?? this.companyId,
    customerId: customerId.present ? customerId.value : this.customerId,
    addressId: addressId.present ? addressId.value : this.addressId,
    trackingNumber: trackingNumber ?? this.trackingNumber,
    deliveryType: deliveryType ?? this.deliveryType,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    windowStart: windowStart.present ? windowStart.value : this.windowStart,
    windowEnd: windowEnd.present ? windowEnd.value : this.windowEnd,
    notes: notes.present ? notes.value : this.notes,
    productValue: productValue ?? this.productValue,
    codAmount: codAmount ?? this.codAmount,
    deliveryFee: deliveryFee ?? this.deliveryFee,
    companyAmount: companyAmount ?? this.companyAmount,
    driverCommission: driverCommission ?? this.driverCommission,
    otherFees: otherFees ?? this.otherFees,
    collectedAmount: collectedAmount ?? this.collectedAmount,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    paymentRuleVersion: paymentRuleVersion.present
        ? paymentRuleVersion.value
        : this.paymentRuleVersion,
    attemptCount: attemptCount ?? this.attemptCount,
    deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
  );
  Order copyWithCompanion(OrdersCompanion data) {
    return Order(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      addressId: data.addressId.present ? data.addressId.value : this.addressId,
      trackingNumber: data.trackingNumber.present
          ? data.trackingNumber.value
          : this.trackingNumber,
      deliveryType: data.deliveryType.present
          ? data.deliveryType.value
          : this.deliveryType,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      windowStart: data.windowStart.present
          ? data.windowStart.value
          : this.windowStart,
      windowEnd: data.windowEnd.present ? data.windowEnd.value : this.windowEnd,
      notes: data.notes.present ? data.notes.value : this.notes,
      productValue: data.productValue.present
          ? data.productValue.value
          : this.productValue,
      codAmount: data.codAmount.present ? data.codAmount.value : this.codAmount,
      deliveryFee: data.deliveryFee.present
          ? data.deliveryFee.value
          : this.deliveryFee,
      companyAmount: data.companyAmount.present
          ? data.companyAmount.value
          : this.companyAmount,
      driverCommission: data.driverCommission.present
          ? data.driverCommission.value
          : this.driverCommission,
      otherFees: data.otherFees.present ? data.otherFees.value : this.otherFees,
      collectedAmount: data.collectedAmount.present
          ? data.collectedAmount.value
          : this.collectedAmount,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      paymentRuleVersion: data.paymentRuleVersion.present
          ? data.paymentRuleVersion.value
          : this.paymentRuleVersion,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      deliveredAt: data.deliveredAt.present
          ? data.deliveredAt.value
          : this.deliveredAt,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Order(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('batchId: $batchId, ')
          ..write('companyId: $companyId, ')
          ..write('customerId: $customerId, ')
          ..write('addressId: $addressId, ')
          ..write('trackingNumber: $trackingNumber, ')
          ..write('deliveryType: $deliveryType, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('windowStart: $windowStart, ')
          ..write('windowEnd: $windowEnd, ')
          ..write('notes: $notes, ')
          ..write('productValue: $productValue, ')
          ..write('codAmount: $codAmount, ')
          ..write('deliveryFee: $deliveryFee, ')
          ..write('companyAmount: $companyAmount, ')
          ..write('driverCommission: $driverCommission, ')
          ..write('otherFees: $otherFees, ')
          ..write('collectedAmount: $collectedAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentRuleVersion: $paymentRuleVersion, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('failureReason: $failureReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    batchId,
    companyId,
    customerId,
    addressId,
    trackingNumber,
    deliveryType,
    status,
    priority,
    windowStart,
    windowEnd,
    notes,
    productValue,
    codAmount,
    deliveryFee,
    companyAmount,
    driverCommission,
    otherFees,
    collectedAmount,
    paymentMethod,
    paymentRuleVersion,
    attemptCount,
    deliveredAt,
    failureReason,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.batchId == this.batchId &&
          other.companyId == this.companyId &&
          other.customerId == this.customerId &&
          other.addressId == this.addressId &&
          other.trackingNumber == this.trackingNumber &&
          other.deliveryType == this.deliveryType &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.windowStart == this.windowStart &&
          other.windowEnd == this.windowEnd &&
          other.notes == this.notes &&
          other.productValue == this.productValue &&
          other.codAmount == this.codAmount &&
          other.deliveryFee == this.deliveryFee &&
          other.companyAmount == this.companyAmount &&
          other.driverCommission == this.driverCommission &&
          other.otherFees == this.otherFees &&
          other.collectedAmount == this.collectedAmount &&
          other.paymentMethod == this.paymentMethod &&
          other.paymentRuleVersion == this.paymentRuleVersion &&
          other.attemptCount == this.attemptCount &&
          other.deliveredAt == this.deliveredAt &&
          other.failureReason == this.failureReason);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> batchId;
  final Value<String> companyId;
  final Value<String?> customerId;
  final Value<String?> addressId;
  final Value<String> trackingNumber;
  final Value<DeliveryType> deliveryType;
  final Value<OrderStatus> status;
  final Value<int> priority;
  final Value<String?> windowStart;
  final Value<String?> windowEnd;
  final Value<String?> notes;
  final Value<Centimes> productValue;
  final Value<Centimes> codAmount;
  final Value<Centimes> deliveryFee;
  final Value<Centimes> companyAmount;
  final Value<Centimes> driverCommission;
  final Value<Centimes> otherFees;
  final Value<Centimes> collectedAmount;
  final Value<PaymentMethod?> paymentMethod;
  final Value<int?> paymentRuleVersion;
  final Value<int> attemptCount;
  final Value<DateTime?> deliveredAt;
  final Value<DeliveryAttemptOutcome?> failureReason;
  final Value<int> rowid;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.batchId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.addressId = const Value.absent(),
    this.trackingNumber = const Value.absent(),
    this.deliveryType = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.windowStart = const Value.absent(),
    this.windowEnd = const Value.absent(),
    this.notes = const Value.absent(),
    this.productValue = const Value.absent(),
    this.codAmount = const Value.absent(),
    this.deliveryFee = const Value.absent(),
    this.companyAmount = const Value.absent(),
    this.driverCommission = const Value.absent(),
    this.otherFees = const Value.absent(),
    this.collectedAmount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentRuleVersion = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdersCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required int version,
    required String batchId,
    required String companyId,
    this.customerId = const Value.absent(),
    this.addressId = const Value.absent(),
    required String trackingNumber,
    this.deliveryType = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.windowStart = const Value.absent(),
    this.windowEnd = const Value.absent(),
    this.notes = const Value.absent(),
    this.productValue = const Value.absent(),
    this.codAmount = const Value.absent(),
    this.deliveryFee = const Value.absent(),
    this.companyAmount = const Value.absent(),
    this.driverCommission = const Value.absent(),
    this.otherFees = const Value.absent(),
    this.collectedAmount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentRuleVersion = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       version = Value(version),
       batchId = Value(batchId),
       companyId = Value(companyId),
       trackingNumber = Value(trackingNumber);
  static Insertable<Order> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? version,
    Expression<String>? batchId,
    Expression<String>? companyId,
    Expression<String>? customerId,
    Expression<String>? addressId,
    Expression<String>? trackingNumber,
    Expression<String>? deliveryType,
    Expression<String>? status,
    Expression<int>? priority,
    Expression<String>? windowStart,
    Expression<String>? windowEnd,
    Expression<String>? notes,
    Expression<int>? productValue,
    Expression<int>? codAmount,
    Expression<int>? deliveryFee,
    Expression<int>? companyAmount,
    Expression<int>? driverCommission,
    Expression<int>? otherFees,
    Expression<int>? collectedAmount,
    Expression<String>? paymentMethod,
    Expression<int>? paymentRuleVersion,
    Expression<int>? attemptCount,
    Expression<int>? deliveredAt,
    Expression<String>? failureReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (batchId != null) 'batch_id': batchId,
      if (companyId != null) 'company_id': companyId,
      if (customerId != null) 'customer_id': customerId,
      if (addressId != null) 'address_id': addressId,
      if (trackingNumber != null) 'tracking_number': trackingNumber,
      if (deliveryType != null) 'delivery_type': deliveryType,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (windowStart != null) 'window_start': windowStart,
      if (windowEnd != null) 'window_end': windowEnd,
      if (notes != null) 'notes': notes,
      if (productValue != null) 'product_value': productValue,
      if (codAmount != null) 'cod_amount': codAmount,
      if (deliveryFee != null) 'delivery_fee': deliveryFee,
      if (companyAmount != null) 'company_amount': companyAmount,
      if (driverCommission != null) 'driver_commission': driverCommission,
      if (otherFees != null) 'other_fees': otherFees,
      if (collectedAmount != null) 'collected_amount': collectedAmount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentRuleVersion != null)
        'payment_rule_version': paymentRuleVersion,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
      if (failureReason != null) 'failure_reason': failureReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? batchId,
    Value<String>? companyId,
    Value<String?>? customerId,
    Value<String?>? addressId,
    Value<String>? trackingNumber,
    Value<DeliveryType>? deliveryType,
    Value<OrderStatus>? status,
    Value<int>? priority,
    Value<String?>? windowStart,
    Value<String?>? windowEnd,
    Value<String?>? notes,
    Value<Centimes>? productValue,
    Value<Centimes>? codAmount,
    Value<Centimes>? deliveryFee,
    Value<Centimes>? companyAmount,
    Value<Centimes>? driverCommission,
    Value<Centimes>? otherFees,
    Value<Centimes>? collectedAmount,
    Value<PaymentMethod?>? paymentMethod,
    Value<int?>? paymentRuleVersion,
    Value<int>? attemptCount,
    Value<DateTime?>? deliveredAt,
    Value<DeliveryAttemptOutcome?>? failureReason,
    Value<int>? rowid,
  }) {
    return OrdersCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      batchId: batchId ?? this.batchId,
      companyId: companyId ?? this.companyId,
      customerId: customerId ?? this.customerId,
      addressId: addressId ?? this.addressId,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      deliveryType: deliveryType ?? this.deliveryType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      windowStart: windowStart ?? this.windowStart,
      windowEnd: windowEnd ?? this.windowEnd,
      notes: notes ?? this.notes,
      productValue: productValue ?? this.productValue,
      codAmount: codAmount ?? this.codAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      companyAmount: companyAmount ?? this.companyAmount,
      driverCommission: driverCommission ?? this.driverCommission,
      otherFees: otherFees ?? this.otherFees,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentRuleVersion: paymentRuleVersion ?? this.paymentRuleVersion,
      attemptCount: attemptCount ?? this.attemptCount,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      failureReason: failureReason ?? this.failureReason,
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
        $OrdersTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $OrdersTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $OrdersTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (addressId.present) {
      map['address_id'] = Variable<String>(addressId.value);
    }
    if (trackingNumber.present) {
      map['tracking_number'] = Variable<String>(trackingNumber.value);
    }
    if (deliveryType.present) {
      map['delivery_type'] = Variable<String>(
        $OrdersTable.$converterdeliveryType.toSql(deliveryType.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $OrdersTable.$converterstatus.toSql(status.value),
      );
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (windowStart.present) {
      map['window_start'] = Variable<String>(windowStart.value);
    }
    if (windowEnd.present) {
      map['window_end'] = Variable<String>(windowEnd.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (productValue.present) {
      map['product_value'] = Variable<int>(
        $OrdersTable.$converterproductValue.toSql(productValue.value),
      );
    }
    if (codAmount.present) {
      map['cod_amount'] = Variable<int>(
        $OrdersTable.$convertercodAmount.toSql(codAmount.value),
      );
    }
    if (deliveryFee.present) {
      map['delivery_fee'] = Variable<int>(
        $OrdersTable.$converterdeliveryFee.toSql(deliveryFee.value),
      );
    }
    if (companyAmount.present) {
      map['company_amount'] = Variable<int>(
        $OrdersTable.$convertercompanyAmount.toSql(companyAmount.value),
      );
    }
    if (driverCommission.present) {
      map['driver_commission'] = Variable<int>(
        $OrdersTable.$converterdriverCommission.toSql(driverCommission.value),
      );
    }
    if (otherFees.present) {
      map['other_fees'] = Variable<int>(
        $OrdersTable.$converterotherFees.toSql(otherFees.value),
      );
    }
    if (collectedAmount.present) {
      map['collected_amount'] = Variable<int>(
        $OrdersTable.$convertercollectedAmount.toSql(collectedAmount.value),
      );
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(
        $OrdersTable.$converterpaymentMethodn.toSql(paymentMethod.value),
      );
    }
    if (paymentRuleVersion.present) {
      map['payment_rule_version'] = Variable<int>(paymentRuleVersion.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<int>(
        $OrdersTable.$converterdeliveredAtn.toSql(deliveredAt.value),
      );
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(
        $OrdersTable.$converterfailureReasonn.toSql(failureReason.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('batchId: $batchId, ')
          ..write('companyId: $companyId, ')
          ..write('customerId: $customerId, ')
          ..write('addressId: $addressId, ')
          ..write('trackingNumber: $trackingNumber, ')
          ..write('deliveryType: $deliveryType, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('windowStart: $windowStart, ')
          ..write('windowEnd: $windowEnd, ')
          ..write('notes: $notes, ')
          ..write('productValue: $productValue, ')
          ..write('codAmount: $codAmount, ')
          ..write('deliveryFee: $deliveryFee, ')
          ..write('companyAmount: $companyAmount, ')
          ..write('driverCommission: $driverCommission, ')
          ..write('otherFees: $otherFees, ')
          ..write('collectedAmount: $collectedAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentRuleVersion: $paymentRuleVersion, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('failureReason: $failureReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeliveryAttemptsTable extends DeliveryAttempts
    with TableInfo<$DeliveryAttemptsTable, DeliveryAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveryAttemptsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($DeliveryAttemptsTable.$convertercreatedAt);
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geohashMeta = const VerificationMeta(
    'geohash',
  );
  @override
  late final GeneratedColumn<String> geohash = GeneratedColumn<String>(
    'geohash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta(
    'accuracyM',
  );
  @override
  late final GeneratedColumn<int> accuracyM = GeneratedColumn<int>(
    'accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _attemptNoMeta = const VerificationMeta(
    'attemptNo',
  );
  @override
  late final GeneratedColumn<int> attemptNo = GeneratedColumn<int>(
    'attempt_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DeliveryAttemptOutcome, String>
  outcome =
      GeneratedColumn<String>(
        'outcome',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DeliveryAttemptOutcome>(
        $DeliveryAttemptsTable.$converteroutcome,
      );
  static const VerificationMeta _outcomeNoteMeta = const VerificationMeta(
    'outcomeNote',
  );
  @override
  late final GeneratedColumn<String> outcomeNote = GeneratedColumn<String>(
    'outcome_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> occurredAt =
      GeneratedColumn<int>(
        'occurred_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($DeliveryAttemptsTable.$converteroccurredAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    latitude,
    longitude,
    geohash,
    accuracyM,
    orderId,
    attemptNo,
    outcome,
    outcomeNote,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'delivery_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeliveryAttempt> instance, {
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
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('geohash')) {
      context.handle(
        _geohashMeta,
        geohash.isAcceptableOrUnknown(data['geohash']!, _geohashMeta),
      );
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(
        _accuracyMMeta,
        accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta),
      );
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('attempt_no')) {
      context.handle(
        _attemptNoMeta,
        attemptNo.isAcceptableOrUnknown(data['attempt_no']!, _attemptNoMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptNoMeta);
    }
    if (data.containsKey('outcome_note')) {
      context.handle(
        _outcomeNoteMeta,
        outcomeNote.isAcceptableOrUnknown(
          data['outcome_note']!,
          _outcomeNoteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {orderId, attemptNo},
  ];
  @override
  DeliveryAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveryAttempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $DeliveryAttemptsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      geohash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geohash'],
      ),
      accuracyM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuracy_m'],
      ),
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      attemptNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_no'],
      )!,
      outcome: $DeliveryAttemptsTable.$converteroutcome.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}outcome'],
        )!,
      ),
      outcomeNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome_note'],
      ),
      occurredAt: $DeliveryAttemptsTable.$converteroccurredAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}occurred_at'],
        )!,
      ),
    );
  }

  @override
  $DeliveryAttemptsTable createAlias(String alias) {
    return $DeliveryAttemptsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DeliveryAttemptOutcome, String> $converteroutcome =
      const EnumTextConverter<DeliveryAttemptOutcome>(
        DeliveryAttemptOutcome.values,
        'DeliveryAttemptOutcome',
      );
  static TypeConverter<DateTime, int> $converteroccurredAt =
      const UtcMillisecondsConverter();
}

class DeliveryAttempt extends DataClass implements Insertable<DeliveryAttempt> {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;

  /// Precision 9, roughly a 5-metre cell. Shorter prefixes are queried for
  /// coarser proximity.
  final String? geohash;

  /// The accuracy radius in metres that the platform reported with the fix.
  ///
  /// Captured at the moment of capture or not at all. Gate 3 of the pin
  /// promotion ladder: a fix taken indoors or in a stairwell can come back at
  /// 300 metres, and routing future deliveries from it degrades every route
  /// through that neighbourhood with nothing anywhere to notice. The threshold
  /// is an M2 decision made against real fixes in Algiers.
  final int? accuracyM;
  final String orderId;

  /// 1-based, and unique per order.
  final int attemptNo;

  /// What happened at the door. A different axis from the order status: this
  /// records the moment, the status records where the parcel now stands.
  final DeliveryAttemptOutcome outcome;
  final String? outcomeNote;

  /// When the attempt happened, which is not when the row was written — a
  /// driver in a dead zone records it later. `created_at` is the write time;
  /// this is the truth, and it is what queries order by.
  final DateTime occurredAt;
  const DeliveryAttempt({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.geohash,
    this.accuracyM,
    required this.orderId,
    required this.attemptNo,
    required this.outcome,
    this.outcomeNote,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $DeliveryAttemptsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || geohash != null) {
      map['geohash'] = Variable<String>(geohash);
    }
    if (!nullToAbsent || accuracyM != null) {
      map['accuracy_m'] = Variable<int>(accuracyM);
    }
    map['order_id'] = Variable<String>(orderId);
    map['attempt_no'] = Variable<int>(attemptNo);
    {
      map['outcome'] = Variable<String>(
        $DeliveryAttemptsTable.$converteroutcome.toSql(outcome),
      );
    }
    if (!nullToAbsent || outcomeNote != null) {
      map['outcome_note'] = Variable<String>(outcomeNote);
    }
    {
      map['occurred_at'] = Variable<int>(
        $DeliveryAttemptsTable.$converteroccurredAt.toSql(occurredAt),
      );
    }
    return map;
  }

  DeliveryAttemptsCompanion toCompanion(bool nullToAbsent) {
    return DeliveryAttemptsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      geohash: geohash == null && nullToAbsent
          ? const Value.absent()
          : Value(geohash),
      accuracyM: accuracyM == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyM),
      orderId: Value(orderId),
      attemptNo: Value(attemptNo),
      outcome: Value(outcome),
      outcomeNote: outcomeNote == null && nullToAbsent
          ? const Value.absent()
          : Value(outcomeNote),
      occurredAt: Value(occurredAt),
    );
  }

  factory DeliveryAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveryAttempt(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      geohash: serializer.fromJson<String?>(json['geohash']),
      accuracyM: serializer.fromJson<int?>(json['accuracyM']),
      orderId: serializer.fromJson<String>(json['orderId']),
      attemptNo: serializer.fromJson<int>(json['attemptNo']),
      outcome: serializer.fromJson<DeliveryAttemptOutcome>(json['outcome']),
      outcomeNote: serializer.fromJson<String?>(json['outcomeNote']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'geohash': serializer.toJson<String?>(geohash),
      'accuracyM': serializer.toJson<int?>(accuracyM),
      'orderId': serializer.toJson<String>(orderId),
      'attemptNo': serializer.toJson<int>(attemptNo),
      'outcome': serializer.toJson<DeliveryAttemptOutcome>(outcome),
      'outcomeNote': serializer.toJson<String?>(outcomeNote),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  DeliveryAttempt copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> geohash = const Value.absent(),
    Value<int?> accuracyM = const Value.absent(),
    String? orderId,
    int? attemptNo,
    DeliveryAttemptOutcome? outcome,
    Value<String?> outcomeNote = const Value.absent(),
    DateTime? occurredAt,
  }) => DeliveryAttempt(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    geohash: geohash.present ? geohash.value : this.geohash,
    accuracyM: accuracyM.present ? accuracyM.value : this.accuracyM,
    orderId: orderId ?? this.orderId,
    attemptNo: attemptNo ?? this.attemptNo,
    outcome: outcome ?? this.outcome,
    outcomeNote: outcomeNote.present ? outcomeNote.value : this.outcomeNote,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  DeliveryAttempt copyWithCompanion(DeliveryAttemptsCompanion data) {
    return DeliveryAttempt(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      geohash: data.geohash.present ? data.geohash.value : this.geohash,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      attemptNo: data.attemptNo.present ? data.attemptNo.value : this.attemptNo,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      outcomeNote: data.outcomeNote.present
          ? data.outcomeNote.value
          : this.outcomeNote,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryAttempt(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geohash: $geohash, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('orderId: $orderId, ')
          ..write('attemptNo: $attemptNo, ')
          ..write('outcome: $outcome, ')
          ..write('outcomeNote: $outcomeNote, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    createdAt,
    latitude,
    longitude,
    geohash,
    accuracyM,
    orderId,
    attemptNo,
    outcome,
    outcomeNote,
    occurredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryAttempt &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.geohash == this.geohash &&
          other.accuracyM == this.accuracyM &&
          other.orderId == this.orderId &&
          other.attemptNo == this.attemptNo &&
          other.outcome == this.outcome &&
          other.outcomeNote == this.outcomeNote &&
          other.occurredAt == this.occurredAt);
}

class DeliveryAttemptsCompanion extends UpdateCompanion<DeliveryAttempt> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> geohash;
  final Value<int?> accuracyM;
  final Value<String> orderId;
  final Value<int> attemptNo;
  final Value<DeliveryAttemptOutcome> outcome;
  final Value<String?> outcomeNote;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const DeliveryAttemptsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geohash = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.orderId = const Value.absent(),
    this.attemptNo = const Value.absent(),
    this.outcome = const Value.absent(),
    this.outcomeNote = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeliveryAttemptsCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geohash = const Value.absent(),
    this.accuracyM = const Value.absent(),
    required String orderId,
    required int attemptNo,
    required DeliveryAttemptOutcome outcome,
    this.outcomeNote = const Value.absent(),
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       orderId = Value(orderId),
       attemptNo = Value(attemptNo),
       outcome = Value(outcome),
       occurredAt = Value(occurredAt);
  static Insertable<DeliveryAttempt> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? geohash,
    Expression<int>? accuracyM,
    Expression<String>? orderId,
    Expression<int>? attemptNo,
    Expression<String>? outcome,
    Expression<String>? outcomeNote,
    Expression<int>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (geohash != null) 'geohash': geohash,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (orderId != null) 'order_id': orderId,
      if (attemptNo != null) 'attempt_no': attemptNo,
      if (outcome != null) 'outcome': outcome,
      if (outcomeNote != null) 'outcome_note': outcomeNote,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeliveryAttemptsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? geohash,
    Value<int?>? accuracyM,
    Value<String>? orderId,
    Value<int>? attemptNo,
    Value<DeliveryAttemptOutcome>? outcome,
    Value<String?>? outcomeNote,
    Value<DateTime>? occurredAt,
    Value<int>? rowid,
  }) {
    return DeliveryAttemptsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      accuracyM: accuracyM ?? this.accuracyM,
      orderId: orderId ?? this.orderId,
      attemptNo: attemptNo ?? this.attemptNo,
      outcome: outcome ?? this.outcome,
      outcomeNote: outcomeNote ?? this.outcomeNote,
      occurredAt: occurredAt ?? this.occurredAt,
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
        $DeliveryAttemptsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (geohash.present) {
      map['geohash'] = Variable<String>(geohash.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<int>(accuracyM.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (attemptNo.present) {
      map['attempt_no'] = Variable<int>(attemptNo.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(
        $DeliveryAttemptsTable.$converteroutcome.toSql(outcome.value),
      );
    }
    if (outcomeNote.present) {
      map['outcome_note'] = Variable<String>(outcomeNote.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(
        $DeliveryAttemptsTable.$converteroccurredAt.toSql(occurredAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geohash: $geohash, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('orderId: $orderId, ')
          ..write('attemptNo: $attemptNo, ')
          ..write('outcome: $outcome, ')
          ..write('outcomeNote: $outcomeNote, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProofOfDeliveryTable extends ProofOfDelivery
    with TableInfo<$ProofOfDeliveryTable, DeliveryProof> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProofOfDeliveryTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ProofOfDeliveryTable.$convertercreatedAt);
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signaturePathMeta = const VerificationMeta(
    'signaturePath',
  );
  @override
  late final GeneratedColumn<String> signaturePath = GeneratedColumn<String>(
    'signature_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> capturedAt =
      GeneratedColumn<int>(
        'captured_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ProofOfDeliveryTable.$convertercapturedAt);
  static const VerificationMeta _driverNoteMeta = const VerificationMeta(
    'driverNote',
  );
  @override
  late final GeneratedColumn<String> driverNote = GeneratedColumn<String>(
    'driver_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadedMeta = const VerificationMeta(
    'uploaded',
  );
  @override
  late final GeneratedColumn<bool> uploaded = GeneratedColumn<bool>(
    'uploaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uploaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    orderId,
    photoPath,
    signaturePath,
    latitude,
    longitude,
    capturedAt,
    driverNote,
    uploaded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'proof_of_delivery';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeliveryProof> instance, {
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
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('signature_path')) {
      context.handle(
        _signaturePathMeta,
        signaturePath.isAcceptableOrUnknown(
          data['signature_path']!,
          _signaturePathMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('driver_note')) {
      context.handle(
        _driverNoteMeta,
        driverNote.isAcceptableOrUnknown(data['driver_note']!, _driverNoteMeta),
      );
    }
    if (data.containsKey('uploaded')) {
      context.handle(
        _uploadedMeta,
        uploaded.isAcceptableOrUnknown(data['uploaded']!, _uploadedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeliveryProof map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveryProof(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $ProofOfDeliveryTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      signaturePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signature_path'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      capturedAt: $ProofOfDeliveryTable.$convertercapturedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}captured_at'],
        )!,
      ),
      driverNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}driver_note'],
      ),
      uploaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uploaded'],
      )!,
    );
  }

  @override
  $ProofOfDeliveryTable createAlias(String alias) {
    return $ProofOfDeliveryTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $convertercapturedAt =
      const UtcMillisecondsConverter();
}

class DeliveryProof extends DataClass implements Insertable<DeliveryProof> {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final String orderId;

  /// App-private storage, never the gallery and never MediaStore (§13). A
  /// photo of a customer doorway is not something to hand to every app on the
  /// phone.
  final String? photoPath;

  /// V2. The column exists because adding it later means migrating live data;
  /// nothing in the MVP writes it.
  final String? signaturePath;

  /// No geohash here, unlike the attempts: nothing runs proximity queries on a
  /// proof photo. Latitude and longitude are the evidence that the driver was
  /// where they said they were.
  final double? latitude;
  final double? longitude;
  final DateTime capturedAt;
  final String? driverNote;

  /// Dormant sync flag. POD photos upload lazily and on Wi-Fi (§11.4) — they
  /// are large, not needed for correctness, and uploading them over a metered
  /// Algerian connection mid-shift is hostile to the driver.
  final bool uploaded;
  const DeliveryProof({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.orderId,
    this.photoPath,
    this.signaturePath,
    this.latitude,
    this.longitude,
    required this.capturedAt,
    this.driverNote,
    required this.uploaded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $ProofOfDeliveryTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    map['order_id'] = Variable<String>(orderId);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || signaturePath != null) {
      map['signature_path'] = Variable<String>(signaturePath);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    {
      map['captured_at'] = Variable<int>(
        $ProofOfDeliveryTable.$convertercapturedAt.toSql(capturedAt),
      );
    }
    if (!nullToAbsent || driverNote != null) {
      map['driver_note'] = Variable<String>(driverNote);
    }
    map['uploaded'] = Variable<bool>(uploaded);
    return map;
  }

  ProofOfDeliveryCompanion toCompanion(bool nullToAbsent) {
    return ProofOfDeliveryCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      orderId: Value(orderId),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      signaturePath: signaturePath == null && nullToAbsent
          ? const Value.absent()
          : Value(signaturePath),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      capturedAt: Value(capturedAt),
      driverNote: driverNote == null && nullToAbsent
          ? const Value.absent()
          : Value(driverNote),
      uploaded: Value(uploaded),
    );
  }

  factory DeliveryProof.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveryProof(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      orderId: serializer.fromJson<String>(json['orderId']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      signaturePath: serializer.fromJson<String?>(json['signaturePath']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      driverNote: serializer.fromJson<String?>(json['driverNote']),
      uploaded: serializer.fromJson<bool>(json['uploaded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'orderId': serializer.toJson<String>(orderId),
      'photoPath': serializer.toJson<String?>(photoPath),
      'signaturePath': serializer.toJson<String?>(signaturePath),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'driverNote': serializer.toJson<String?>(driverNote),
      'uploaded': serializer.toJson<bool>(uploaded),
    };
  }

  DeliveryProof copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    String? orderId,
    Value<String?> photoPath = const Value.absent(),
    Value<String?> signaturePath = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    DateTime? capturedAt,
    Value<String?> driverNote = const Value.absent(),
    bool? uploaded,
  }) => DeliveryProof(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    orderId: orderId ?? this.orderId,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    signaturePath: signaturePath.present
        ? signaturePath.value
        : this.signaturePath,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    capturedAt: capturedAt ?? this.capturedAt,
    driverNote: driverNote.present ? driverNote.value : this.driverNote,
    uploaded: uploaded ?? this.uploaded,
  );
  DeliveryProof copyWithCompanion(ProofOfDeliveryCompanion data) {
    return DeliveryProof(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      signaturePath: data.signaturePath.present
          ? data.signaturePath.value
          : this.signaturePath,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      driverNote: data.driverNote.present
          ? data.driverNote.value
          : this.driverNote,
      uploaded: data.uploaded.present ? data.uploaded.value : this.uploaded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryProof(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('orderId: $orderId, ')
          ..write('photoPath: $photoPath, ')
          ..write('signaturePath: $signaturePath, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('driverNote: $driverNote, ')
          ..write('uploaded: $uploaded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    createdAt,
    orderId,
    photoPath,
    signaturePath,
    latitude,
    longitude,
    capturedAt,
    driverNote,
    uploaded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryProof &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.orderId == this.orderId &&
          other.photoPath == this.photoPath &&
          other.signaturePath == this.signaturePath &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.capturedAt == this.capturedAt &&
          other.driverNote == this.driverNote &&
          other.uploaded == this.uploaded);
}

class ProofOfDeliveryCompanion extends UpdateCompanion<DeliveryProof> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<String> orderId;
  final Value<String?> photoPath;
  final Value<String?> signaturePath;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<DateTime> capturedAt;
  final Value<String?> driverNote;
  final Value<bool> uploaded;
  final Value<int> rowid;
  const ProofOfDeliveryCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.orderId = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.signaturePath = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.driverNote = const Value.absent(),
    this.uploaded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProofOfDeliveryCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required String orderId,
    this.photoPath = const Value.absent(),
    this.signaturePath = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required DateTime capturedAt,
    this.driverNote = const Value.absent(),
    this.uploaded = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       orderId = Value(orderId),
       capturedAt = Value(capturedAt);
  static Insertable<DeliveryProof> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<String>? orderId,
    Expression<String>? photoPath,
    Expression<String>? signaturePath,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? capturedAt,
    Expression<String>? driverNote,
    Expression<bool>? uploaded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (orderId != null) 'order_id': orderId,
      if (photoPath != null) 'photo_path': photoPath,
      if (signaturePath != null) 'signature_path': signaturePath,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (driverNote != null) 'driver_note': driverNote,
      if (uploaded != null) 'uploaded': uploaded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProofOfDeliveryCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<String>? orderId,
    Value<String?>? photoPath,
    Value<String?>? signaturePath,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<DateTime>? capturedAt,
    Value<String?>? driverNote,
    Value<bool>? uploaded,
    Value<int>? rowid,
  }) {
    return ProofOfDeliveryCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      orderId: orderId ?? this.orderId,
      photoPath: photoPath ?? this.photoPath,
      signaturePath: signaturePath ?? this.signaturePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capturedAt: capturedAt ?? this.capturedAt,
      driverNote: driverNote ?? this.driverNote,
      uploaded: uploaded ?? this.uploaded,
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
        $ProofOfDeliveryTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (signaturePath.present) {
      map['signature_path'] = Variable<String>(signaturePath.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<int>(
        $ProofOfDeliveryTable.$convertercapturedAt.toSql(capturedAt.value),
      );
    }
    if (driverNote.present) {
      map['driver_note'] = Variable<String>(driverNote.value);
    }
    if (uploaded.present) {
      map['uploaded'] = Variable<bool>(uploaded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProofOfDeliveryCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('orderId: $orderId, ')
          ..write('photoPath: $photoPath, ')
          ..write('signaturePath: $signaturePath, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('driverNote: $driverNote, ')
          ..write('uploaded: $uploaded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $CompaniesTable companies = $CompaniesTable(this);
  late final $PaymentRulesTable paymentRules = $PaymentRulesTable(this);
  late final $WilayasTable wilayas = $WilayasTable(this);
  late final $CommunesTable communes = $CommunesTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $CustomerAddressesTable customerAddresses =
      $CustomerAddressesTable(this);
  late final $BatchesTable batches = $BatchesTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $DeliveryAttemptsTable deliveryAttempts = $DeliveryAttemptsTable(
    this,
  );
  late final $ProofOfDeliveryTable proofOfDelivery = $ProofOfDeliveryTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    companies,
    paymentRules,
    wilayas,
    communes,
    customers,
    customerAddresses,
    batches,
    orders,
    deliveryAttempts,
    proofOfDelivery,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('customer_addresses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'orders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('delivery_attempts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'orders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('proof_of_delivery', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<PhoneE164?> phone,
      required String displayName,
      Value<String> locale,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<PhoneE164?> phone,
      Value<String> displayName,
      Value<String> locale,
      Value<int> rowid,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CompaniesTable, List<Company>>
  _companiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.companies,
    aliasName: 'users__id__companies__owner_id',
  );

  $$CompaniesTableProcessedTableManager get companiesRefs {
    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_companiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentRulesTable, List<PaymentRule>>
  _paymentRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.paymentRules,
    aliasName: 'users__id__payment_rules__owner_id',
  );

  $$PaymentRulesTableProcessedTableManager get paymentRulesRefs {
    final manager = $$PaymentRulesTableTableManager(
      $_db,
      $_db.paymentRules,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CustomersTable, List<Customer>>
  _customersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.customers,
    aliasName: 'users__id__customers__owner_id',
  );

  $$CustomersTableProcessedTableManager get customersRefs {
    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_customersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CustomerAddressesTable, List<CustomerAddress>>
  _customerAddressesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customerAddresses,
        aliasName: 'users__id__customer_addresses__owner_id',
      );

  $$CustomerAddressesTableProcessedTableManager get customerAddressesRefs {
    final manager = $$CustomerAddressesTableTableManager(
      $_db,
      $_db.customerAddresses,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customerAddressesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BatchesTable, List<Batch>> _batchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.batches,
    aliasName: 'users__id__batches__owner_id',
  );

  $$BatchesTableProcessedTableManager get batchesRefs {
    final manager = $$BatchesTableTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_batchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrdersTable, List<Order>> _ordersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.orders,
    aliasName: 'users__id__orders__owner_id',
  );

  $$OrdersTableProcessedTableManager get ordersRefs {
    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ordersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DeliveryAttemptsTable, List<DeliveryAttempt>>
  _deliveryAttemptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deliveryAttempts,
    aliasName: 'users__id__delivery_attempts__owner_id',
  );

  $$DeliveryAttemptsTableProcessedTableManager get deliveryAttemptsRefs {
    final manager = $$DeliveryAttemptsTableTableManager(
      $_db,
      $_db.deliveryAttempts,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _deliveryAttemptsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProofOfDeliveryTable, List<DeliveryProof>>
  _proofOfDeliveryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.proofOfDelivery,
    aliasName: 'users__id__proof_of_delivery__owner_id',
  );

  $$ProofOfDeliveryTableProcessedTableManager get proofOfDeliveryRefs {
    final manager = $$ProofOfDeliveryTableTableManager(
      $_db,
      $_db.proofOfDelivery,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _proofOfDeliveryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
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

  ColumnWithTypeConverterFilters<PhoneE164?, PhoneE164, String> get phone =>
      $composableBuilder(
        column: $table.phone,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> companiesRefs(
    Expression<bool> Function($$CompaniesTableFilterComposer f) f,
  ) {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentRulesRefs(
    Expression<bool> Function($$PaymentRulesTableFilterComposer f) f,
  ) {
    final $$PaymentRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentRules,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentRulesTableFilterComposer(
            $db: $db,
            $table: $db.paymentRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customersRefs(
    Expression<bool> Function($$CustomersTableFilterComposer f) f,
  ) {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customerAddressesRefs(
    Expression<bool> Function($$CustomerAddressesTableFilterComposer f) f,
  ) {
    final $$CustomerAddressesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerAddresses,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerAddressesTableFilterComposer(
            $db: $db,
            $table: $db.customerAddresses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> batchesRefs(
    Expression<bool> Function($$BatchesTableFilterComposer f) f,
  ) {
    final $$BatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ordersRefs(
    Expression<bool> Function($$OrdersTableFilterComposer f) f,
  ) {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> deliveryAttemptsRefs(
    Expression<bool> Function($$DeliveryAttemptsTableFilterComposer f) f,
  ) {
    final $$DeliveryAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deliveryAttempts,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveryAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.deliveryAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> proofOfDeliveryRefs(
    Expression<bool> Function($$ProofOfDeliveryTableFilterComposer f) f,
  ) {
    final $$ProofOfDeliveryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.proofOfDelivery,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProofOfDeliveryTableFilterComposer(
            $db: $db,
            $table: $db.proofOfDelivery,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
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

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<PhoneE164?, String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  Expression<T> companiesRefs<T extends Object>(
    Expression<T> Function($$CompaniesTableAnnotationComposer a) f,
  ) {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentRulesRefs<T extends Object>(
    Expression<T> Function($$PaymentRulesTableAnnotationComposer a) f,
  ) {
    final $$PaymentRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentRules,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customersRefs<T extends Object>(
    Expression<T> Function($$CustomersTableAnnotationComposer a) f,
  ) {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customerAddressesRefs<T extends Object>(
    Expression<T> Function($$CustomerAddressesTableAnnotationComposer a) f,
  ) {
    final $$CustomerAddressesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customerAddresses,
          getReferencedColumn: (t) => t.ownerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerAddressesTableAnnotationComposer(
                $db: $db,
                $table: $db.customerAddresses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> batchesRefs<T extends Object>(
    Expression<T> Function($$BatchesTableAnnotationComposer a) f,
  ) {
    final $$BatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ordersRefs<T extends Object>(
    Expression<T> Function($$OrdersTableAnnotationComposer a) f,
  ) {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> deliveryAttemptsRefs<T extends Object>(
    Expression<T> Function($$DeliveryAttemptsTableAnnotationComposer a) f,
  ) {
    final $$DeliveryAttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deliveryAttempts,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveryAttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.deliveryAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> proofOfDeliveryRefs<T extends Object>(
    Expression<T> Function($$ProofOfDeliveryTableAnnotationComposer a) f,
  ) {
    final $$ProofOfDeliveryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.proofOfDelivery,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProofOfDeliveryTableAnnotationComposer(
            $db: $db,
            $table: $db.proofOfDelivery,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({
            bool companiesRefs,
            bool paymentRulesRefs,
            bool customersRefs,
            bool customerAddressesRefs,
            bool batchesRefs,
            bool ordersRefs,
            bool deliveryAttemptsRefs,
            bool proofOfDeliveryRefs,
          })
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<PhoneE164?> phone = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                phone: phone,
                displayName: displayName,
                locale: locale,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<PhoneE164?> phone = const Value.absent(),
                required String displayName,
                Value<String> locale = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                phone: phone,
                displayName: displayName,
                locale: locale,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companiesRefs = false,
                paymentRulesRefs = false,
                customersRefs = false,
                customerAddressesRefs = false,
                batchesRefs = false,
                ordersRefs = false,
                deliveryAttemptsRefs = false,
                proofOfDeliveryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (companiesRefs) db.companies,
                    if (paymentRulesRefs) db.paymentRules,
                    if (customersRefs) db.customers,
                    if (customerAddressesRefs) db.customerAddresses,
                    if (batchesRefs) db.batches,
                    if (ordersRefs) db.orders,
                    if (deliveryAttemptsRefs) db.deliveryAttempts,
                    if (proofOfDeliveryRefs) db.proofOfDelivery,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (companiesRefs)
                        await $_getPrefetchedData<User, $UsersTable, Company>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._companiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).companiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentRulesRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          PaymentRule
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._paymentRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customersRefs)
                        await $_getPrefetchedData<User, $UsersTable, Customer>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._customersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).customersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customerAddressesRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          CustomerAddress
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._customerAddressesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).customerAddressesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (batchesRefs)
                        await $_getPrefetchedData<User, $UsersTable, Batch>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._batchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(db, table, p0).batchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ordersRefs)
                        await $_getPrefetchedData<User, $UsersTable, Order>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._ordersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(db, table, p0).ordersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (deliveryAttemptsRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          DeliveryAttempt
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._deliveryAttemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).deliveryAttemptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (proofOfDeliveryRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          DeliveryProof
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._proofOfDeliveryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).proofOfDeliveryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
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

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({
        bool companiesRefs,
        bool paymentRulesRefs,
        bool customersRefs,
        bool customerAddressesRefs,
        bool batchesRefs,
        bool ordersRefs,
        bool deliveryAttemptsRefs,
        bool proofOfDeliveryRefs,
      })
    >;
typedef $$CompaniesTableCreateCompanionBuilder =
    CompaniesCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required int version,
      required String name,
      Value<String?> logoPath,
      Value<String?> contactPhone,
      Value<String?> notes,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$CompaniesTableUpdateCompanionBuilder =
    CompaniesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> name,
      Value<String?> logoPath,
      Value<String?> contactPhone,
      Value<String?> notes,
      Value<bool> isActive,
      Value<int> rowid,
    });

final class $$CompaniesTableReferences
    extends BaseReferences<_$AppDatabase, $CompaniesTable, Company> {
  $$CompaniesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('companies__owner_id__users__id');

  $$UsersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentRulesTable, List<PaymentRule>>
  _paymentRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.paymentRules,
    aliasName: 'companies__id__payment_rules__company_id',
  );

  $$PaymentRulesTableProcessedTableManager get paymentRulesRefs {
    final manager = $$PaymentRulesTableTableManager(
      $_db,
      $_db.paymentRules,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BatchesTable, List<Batch>> _batchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.batches,
    aliasName: 'companies__id__batches__company_id',
  );

  $$BatchesTableProcessedTableManager get batchesRefs {
    final manager = $$BatchesTableTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_batchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrdersTable, List<Order>> _ordersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.orders,
    aliasName: 'companies__id__orders__company_id',
  );

  $$OrdersTableProcessedTableManager get ordersRefs {
    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ordersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompaniesTableFilterComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableFilterComposer({
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

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get ownerId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentRulesRefs(
    Expression<bool> Function($$PaymentRulesTableFilterComposer f) f,
  ) {
    final $$PaymentRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentRules,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentRulesTableFilterComposer(
            $db: $db,
            $table: $db.paymentRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> batchesRefs(
    Expression<bool> Function($$BatchesTableFilterComposer f) f,
  ) {
    final $$BatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ordersRefs(
    Expression<bool> Function($$OrdersTableFilterComposer f) f,
  ) {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableOrderingComposer({
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

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get ownerId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompaniesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableAnnotationComposer({
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

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<String> get contactPhone => $composableBuilder(
    column: $table.contactPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$UsersTableAnnotationComposer get ownerId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentRulesRefs<T extends Object>(
    Expression<T> Function($$PaymentRulesTableAnnotationComposer a) f,
  ) {
    final $$PaymentRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentRules,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> batchesRefs<T extends Object>(
    Expression<T> Function($$BatchesTableAnnotationComposer a) f,
  ) {
    final $$BatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ordersRefs<T extends Object>(
    Expression<T> Function($$OrdersTableAnnotationComposer a) f,
  ) {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompaniesTable,
          Company,
          $$CompaniesTableFilterComposer,
          $$CompaniesTableOrderingComposer,
          $$CompaniesTableAnnotationComposer,
          $$CompaniesTableCreateCompanionBuilder,
          $$CompaniesTableUpdateCompanionBuilder,
          (Company, $$CompaniesTableReferences),
          Company,
          PrefetchHooks Function({
            bool ownerId,
            bool paymentRulesRefs,
            bool batchesRefs,
            bool ordersRefs,
          })
        > {
  $$CompaniesTableTableManager(_$AppDatabase db, $CompaniesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompaniesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompaniesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompaniesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<String?> contactPhone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompaniesCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                name: name,
                logoPath: logoPath,
                contactPhone: contactPhone,
                notes: notes,
                isActive: isActive,
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
                Value<String?> logoPath = const Value.absent(),
                Value<String?> contactPhone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompaniesCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                name: name,
                logoPath: logoPath,
                contactPhone: contactPhone,
                notes: notes,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompaniesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ownerId = false,
                paymentRulesRefs = false,
                batchesRefs = false,
                ordersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentRulesRefs) db.paymentRules,
                    if (batchesRefs) db.batches,
                    if (ordersRefs) db.orders,
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
                        if (ownerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ownerId,
                                    referencedTable: $$CompaniesTableReferences
                                        ._ownerIdTable(db),
                                    referencedColumn: $$CompaniesTableReferences
                                        ._ownerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentRulesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          PaymentRule
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._paymentRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (batchesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Batch
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._batchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).batchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ordersRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Order
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._ordersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).ordersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
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

typedef $$CompaniesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompaniesTable,
      Company,
      $$CompaniesTableFilterComposer,
      $$CompaniesTableOrderingComposer,
      $$CompaniesTableAnnotationComposer,
      $$CompaniesTableCreateCompanionBuilder,
      $$CompaniesTableUpdateCompanionBuilder,
      (Company, $$CompaniesTableReferences),
      Company,
      PrefetchHooks Function({
        bool ownerId,
        bool paymentRulesRefs,
        bool batchesRefs,
        bool ordersRefs,
      })
    >;
typedef $$PaymentRulesTableCreateCompanionBuilder =
    PaymentRulesCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required String companyId,
      required int ruleVersion,
      required String spec,
      required String effectiveFrom,
      Value<int> rowid,
    });
typedef $$PaymentRulesTableUpdateCompanionBuilder =
    PaymentRulesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<String> companyId,
      Value<int> ruleVersion,
      Value<String> spec,
      Value<String> effectiveFrom,
      Value<int> rowid,
    });

final class $$PaymentRulesTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentRulesTable, PaymentRule> {
  $$PaymentRulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('payment_rules__owner_id__users__id');

  $$UsersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('payment_rules__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentRulesTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentRulesTable> {
  $$PaymentRulesTableFilterComposer({
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

  ColumnFilters<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spec => $composableBuilder(
    column: $table.spec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get ownerId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentRulesTable> {
  $$PaymentRulesTableOrderingComposer({
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

  ColumnOrderings<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spec => $composableBuilder(
    column: $table.spec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get ownerId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentRulesTable> {
  $$PaymentRulesTableAnnotationComposer({
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

  GeneratedColumn<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spec =>
      $composableBuilder(column: $table.spec, builder: (column) => column);

  GeneratedColumn<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  $$UsersTableAnnotationComposer get ownerId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentRulesTable,
          PaymentRule,
          $$PaymentRulesTableFilterComposer,
          $$PaymentRulesTableOrderingComposer,
          $$PaymentRulesTableAnnotationComposer,
          $$PaymentRulesTableCreateCompanionBuilder,
          $$PaymentRulesTableUpdateCompanionBuilder,
          (PaymentRule, $$PaymentRulesTableReferences),
          PaymentRule,
          PrefetchHooks Function({bool ownerId, bool companyId})
        > {
  $$PaymentRulesTableTableManager(_$AppDatabase db, $PaymentRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<int> ruleVersion = const Value.absent(),
                Value<String> spec = const Value.absent(),
                Value<String> effectiveFrom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentRulesCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                companyId: companyId,
                ruleVersion: ruleVersion,
                spec: spec,
                effectiveFrom: effectiveFrom,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required DateTime createdAt,
                required String companyId,
                required int ruleVersion,
                required String spec,
                required String effectiveFrom,
                Value<int> rowid = const Value.absent(),
              }) => PaymentRulesCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                companyId: companyId,
                ruleVersion: ruleVersion,
                spec: spec,
                effectiveFrom: effectiveFrom,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ownerId = false, companyId = false}) {
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
                    if (ownerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ownerId,
                                referencedTable: $$PaymentRulesTableReferences
                                    ._ownerIdTable(db),
                                referencedColumn: $$PaymentRulesTableReferences
                                    ._ownerIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable: $$PaymentRulesTableReferences
                                    ._companyIdTable(db),
                                referencedColumn: $$PaymentRulesTableReferences
                                    ._companyIdTable(db)
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

typedef $$PaymentRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentRulesTable,
      PaymentRule,
      $$PaymentRulesTableFilterComposer,
      $$PaymentRulesTableOrderingComposer,
      $$PaymentRulesTableAnnotationComposer,
      $$PaymentRulesTableCreateCompanionBuilder,
      $$PaymentRulesTableUpdateCompanionBuilder,
      (PaymentRule, $$PaymentRulesTableReferences),
      PaymentRule,
      PrefetchHooks Function({bool ownerId, bool companyId})
    >;
typedef $$WilayasTableCreateCompanionBuilder =
    WilayasCompanion Function({
      Value<int> code,
      required String nameFr,
      required String nameAr,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> geohash,
    });
typedef $$WilayasTableUpdateCompanionBuilder =
    WilayasCompanion Function({
      Value<int> code,
      Value<String> nameFr,
      Value<String> nameAr,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> geohash,
    });

final class $$WilayasTableReferences
    extends BaseReferences<_$AppDatabase, $WilayasTable, Wilaya> {
  $$WilayasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CommunesTable, List<Commune>> _communesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.communes,
    aliasName: 'wilayas__code__communes__wilaya_code',
  );

  $$CommunesTableProcessedTableManager get communesRefs {
    final manager = $$CommunesTableTableManager(
      $_db,
      $_db.communes,
    ).filter((f) => f.wilayaCode.code.sqlEquals($_itemColumn<int>('code')!));

    final cache = $_typedResult.readTableOrNull(_communesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CustomerAddressesTable, List<CustomerAddress>>
  _customerAddressesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customerAddresses,
        aliasName: 'wilayas__code__customer_addresses__wilaya_code',
      );

  $$CustomerAddressesTableProcessedTableManager get customerAddressesRefs {
    final manager = $$CustomerAddressesTableTableManager(
      $_db,
      $_db.customerAddresses,
    ).filter((f) => f.wilayaCode.code.sqlEquals($_itemColumn<int>('code')!));

    final cache = $_typedResult.readTableOrNull(
      _customerAddressesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WilayasTableFilterComposer
    extends Composer<_$AppDatabase, $WilayasTable> {
  $$WilayasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameFr => $composableBuilder(
    column: $table.nameFr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geohash => $composableBuilder(
    column: $table.geohash,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> communesRefs(
    Expression<bool> Function($$CommunesTableFilterComposer f) f,
  ) {
    final $$CommunesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.communes,
      getReferencedColumn: (t) => t.wilayaCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommunesTableFilterComposer(
            $db: $db,
            $table: $db.communes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customerAddressesRefs(
    Expression<bool> Function($$CustomerAddressesTableFilterComposer f) f,
  ) {
    final $$CustomerAddressesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.customerAddresses,
      getReferencedColumn: (t) => t.wilayaCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerAddressesTableFilterComposer(
            $db: $db,
            $table: $db.customerAddresses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WilayasTableOrderingComposer
    extends Composer<_$AppDatabase, $WilayasTable> {
  $$WilayasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameFr => $composableBuilder(
    column: $table.nameFr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geohash => $composableBuilder(
    column: $table.geohash,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WilayasTableAnnotationComposer
    extends Composer<_$AppDatabase, $WilayasTable> {
  $$WilayasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get nameFr =>
      $composableBuilder(column: $table.nameFr, builder: (column) => column);

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get geohash =>
      $composableBuilder(column: $table.geohash, builder: (column) => column);

  Expression<T> communesRefs<T extends Object>(
    Expression<T> Function($$CommunesTableAnnotationComposer a) f,
  ) {
    final $$CommunesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.communes,
      getReferencedColumn: (t) => t.wilayaCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommunesTableAnnotationComposer(
            $db: $db,
            $table: $db.communes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customerAddressesRefs<T extends Object>(
    Expression<T> Function($$CustomerAddressesTableAnnotationComposer a) f,
  ) {
    final $$CustomerAddressesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.code,
          referencedTable: $db.customerAddresses,
          getReferencedColumn: (t) => t.wilayaCode,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerAddressesTableAnnotationComposer(
                $db: $db,
                $table: $db.customerAddresses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WilayasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WilayasTable,
          Wilaya,
          $$WilayasTableFilterComposer,
          $$WilayasTableOrderingComposer,
          $$WilayasTableAnnotationComposer,
          $$WilayasTableCreateCompanionBuilder,
          $$WilayasTableUpdateCompanionBuilder,
          (Wilaya, $$WilayasTableReferences),
          Wilaya,
          PrefetchHooks Function({
            bool communesRefs,
            bool customerAddressesRefs,
          })
        > {
  $$WilayasTableTableManager(_$AppDatabase db, $WilayasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WilayasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WilayasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WilayasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> code = const Value.absent(),
                Value<String> nameFr = const Value.absent(),
                Value<String> nameAr = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> geohash = const Value.absent(),
              }) => WilayasCompanion(
                code: code,
                nameFr: nameFr,
                nameAr: nameAr,
                latitude: latitude,
                longitude: longitude,
                geohash: geohash,
              ),
          createCompanionCallback:
              ({
                Value<int> code = const Value.absent(),
                required String nameFr,
                required String nameAr,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> geohash = const Value.absent(),
              }) => WilayasCompanion.insert(
                code: code,
                nameFr: nameFr,
                nameAr: nameAr,
                latitude: latitude,
                longitude: longitude,
                geohash: geohash,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WilayasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({communesRefs = false, customerAddressesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (communesRefs) db.communes,
                    if (customerAddressesRefs) db.customerAddresses,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (communesRefs)
                        await $_getPrefetchedData<
                          Wilaya,
                          $WilayasTable,
                          Commune
                        >(
                          currentTable: table,
                          referencedTable: $$WilayasTableReferences
                              ._communesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WilayasTableReferences(
                                db,
                                table,
                                p0,
                              ).communesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wilayaCode == item.code,
                              ),
                          typedResults: items,
                        ),
                      if (customerAddressesRefs)
                        await $_getPrefetchedData<
                          Wilaya,
                          $WilayasTable,
                          CustomerAddress
                        >(
                          currentTable: table,
                          referencedTable: $$WilayasTableReferences
                              ._customerAddressesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WilayasTableReferences(
                                db,
                                table,
                                p0,
                              ).customerAddressesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wilayaCode == item.code,
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

typedef $$WilayasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WilayasTable,
      Wilaya,
      $$WilayasTableFilterComposer,
      $$WilayasTableOrderingComposer,
      $$WilayasTableAnnotationComposer,
      $$WilayasTableCreateCompanionBuilder,
      $$WilayasTableUpdateCompanionBuilder,
      (Wilaya, $$WilayasTableReferences),
      Wilaya,
      PrefetchHooks Function({bool communesRefs, bool customerAddressesRefs})
    >;
typedef $$CommunesTableCreateCompanionBuilder =
    CommunesCompanion Function({
      Value<int> id,
      required int wilayaCode,
      required String nameFr,
      required String nameAr,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> geohash,
      Value<String?> boundary,
    });
typedef $$CommunesTableUpdateCompanionBuilder =
    CommunesCompanion Function({
      Value<int> id,
      Value<int> wilayaCode,
      Value<String> nameFr,
      Value<String> nameAr,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> geohash,
      Value<String?> boundary,
    });

final class $$CommunesTableReferences
    extends BaseReferences<_$AppDatabase, $CommunesTable, Commune> {
  $$CommunesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WilayasTable _wilayaCodeTable(_$AppDatabase db) =>
      db.wilayas.createAlias('communes__wilaya_code__wilayas__code');

  $$WilayasTableProcessedTableManager get wilayaCode {
    final $_column = $_itemColumn<int>('wilaya_code')!;

    final manager = $$WilayasTableTableManager(
      $_db,
      $_db.wilayas,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wilayaCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CustomerAddressesTable, List<CustomerAddress>>
  _customerAddressesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customerAddresses,
        aliasName: 'communes__id__customer_addresses__commune_id',
      );

  $$CustomerAddressesTableProcessedTableManager get customerAddressesRefs {
    final manager = $$CustomerAddressesTableTableManager(
      $_db,
      $_db.customerAddresses,
    ).filter((f) => f.communeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customerAddressesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CommunesTableFilterComposer
    extends Composer<_$AppDatabase, $CommunesTable> {
  $$CommunesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameFr => $composableBuilder(
    column: $table.nameFr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geohash => $composableBuilder(
    column: $table.geohash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boundary => $composableBuilder(
    column: $table.boundary,
    builder: (column) => ColumnFilters(column),
  );

  $$WilayasTableFilterComposer get wilayaCode {
    final $$WilayasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wilayaCode,
      referencedTable: $db.wilayas,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WilayasTableFilterComposer(
            $db: $db,
            $table: $db.wilayas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> customerAddressesRefs(
    Expression<bool> Function($$CustomerAddressesTableFilterComposer f) f,
  ) {
    final $$CustomerAddressesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerAddresses,
      getReferencedColumn: (t) => t.communeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerAddressesTableFilterComposer(
            $db: $db,
            $table: $db.customerAddresses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CommunesTableOrderingComposer
    extends Composer<_$AppDatabase, $CommunesTable> {
  $$CommunesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameFr => $composableBuilder(
    column: $table.nameFr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geohash => $composableBuilder(
    column: $table.geohash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boundary => $composableBuilder(
    column: $table.boundary,
    builder: (column) => ColumnOrderings(column),
  );

  $$WilayasTableOrderingComposer get wilayaCode {
    final $$WilayasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wilayaCode,
      referencedTable: $db.wilayas,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WilayasTableOrderingComposer(
            $db: $db,
            $table: $db.wilayas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommunesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommunesTable> {
  $$CommunesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameFr =>
      $composableBuilder(column: $table.nameFr, builder: (column) => column);

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get geohash =>
      $composableBuilder(column: $table.geohash, builder: (column) => column);

  GeneratedColumn<String> get boundary =>
      $composableBuilder(column: $table.boundary, builder: (column) => column);

  $$WilayasTableAnnotationComposer get wilayaCode {
    final $$WilayasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wilayaCode,
      referencedTable: $db.wilayas,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WilayasTableAnnotationComposer(
            $db: $db,
            $table: $db.wilayas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> customerAddressesRefs<T extends Object>(
    Expression<T> Function($$CustomerAddressesTableAnnotationComposer a) f,
  ) {
    final $$CustomerAddressesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customerAddresses,
          getReferencedColumn: (t) => t.communeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerAddressesTableAnnotationComposer(
                $db: $db,
                $table: $db.customerAddresses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CommunesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommunesTable,
          Commune,
          $$CommunesTableFilterComposer,
          $$CommunesTableOrderingComposer,
          $$CommunesTableAnnotationComposer,
          $$CommunesTableCreateCompanionBuilder,
          $$CommunesTableUpdateCompanionBuilder,
          (Commune, $$CommunesTableReferences),
          Commune,
          PrefetchHooks Function({bool wilayaCode, bool customerAddressesRefs})
        > {
  $$CommunesTableTableManager(_$AppDatabase db, $CommunesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommunesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommunesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommunesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wilayaCode = const Value.absent(),
                Value<String> nameFr = const Value.absent(),
                Value<String> nameAr = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> geohash = const Value.absent(),
                Value<String?> boundary = const Value.absent(),
              }) => CommunesCompanion(
                id: id,
                wilayaCode: wilayaCode,
                nameFr: nameFr,
                nameAr: nameAr,
                latitude: latitude,
                longitude: longitude,
                geohash: geohash,
                boundary: boundary,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int wilayaCode,
                required String nameFr,
                required String nameAr,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> geohash = const Value.absent(),
                Value<String?> boundary = const Value.absent(),
              }) => CommunesCompanion.insert(
                id: id,
                wilayaCode: wilayaCode,
                nameFr: nameFr,
                nameAr: nameAr,
                latitude: latitude,
                longitude: longitude,
                geohash: geohash,
                boundary: boundary,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CommunesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({wilayaCode = false, customerAddressesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (customerAddressesRefs) db.customerAddresses,
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
                        if (wilayaCode) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.wilayaCode,
                                    referencedTable: $$CommunesTableReferences
                                        ._wilayaCodeTable(db),
                                    referencedColumn: $$CommunesTableReferences
                                        ._wilayaCodeTable(db)
                                        .code,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (customerAddressesRefs)
                        await $_getPrefetchedData<
                          Commune,
                          $CommunesTable,
                          CustomerAddress
                        >(
                          currentTable: table,
                          referencedTable: $$CommunesTableReferences
                              ._customerAddressesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CommunesTableReferences(
                                db,
                                table,
                                p0,
                              ).customerAddressesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.communeId == item.id,
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

typedef $$CommunesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommunesTable,
      Commune,
      $$CommunesTableFilterComposer,
      $$CommunesTableOrderingComposer,
      $$CommunesTableAnnotationComposer,
      $$CommunesTableCreateCompanionBuilder,
      $$CommunesTableUpdateCompanionBuilder,
      (Commune, $$CommunesTableReferences),
      Commune,
      PrefetchHooks Function({bool wilayaCode, bool customerAddressesRefs})
    >;
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required int version,
      required PhoneE164 phoneE164,
      Value<PhoneE164?> phoneAlt,
      required String displayName,
      Value<String?> notes,
      Value<CustomerRiskFlag> riskFlag,
      Value<int> totalOrders,
      Value<int> totalDelivered,
      Value<int> totalFailed,
      Value<DateTime?> lastDeliveredAt,
      Value<int> rowid,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<PhoneE164> phoneE164,
      Value<PhoneE164?> phoneAlt,
      Value<String> displayName,
      Value<String?> notes,
      Value<CustomerRiskFlag> riskFlag,
      Value<int> totalOrders,
      Value<int> totalDelivered,
      Value<int> totalFailed,
      Value<DateTime?> lastDeliveredAt,
      Value<int> rowid,
    });

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, Customer> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('customers__owner_id__users__id');

  $$UsersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CustomerAddressesTable, List<CustomerAddress>>
  _customerAddressesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customerAddresses,
        aliasName: 'customers__id__customer_addresses__customer_id',
      );

  $$CustomerAddressesTableProcessedTableManager get customerAddressesRefs {
    final manager = $$CustomerAddressesTableTableManager(
      $_db,
      $_db.customerAddresses,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customerAddressesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrdersTable, List<Order>> _ordersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.orders,
    aliasName: 'customers__id__orders__customer_id',
  );

  $$OrdersTableProcessedTableManager get ordersRefs {
    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ordersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
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

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PhoneE164, PhoneE164, String> get phoneE164 =>
      $composableBuilder(
        column: $table.phoneE164,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PhoneE164?, PhoneE164, String> get phoneAlt =>
      $composableBuilder(
        column: $table.phoneAlt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CustomerRiskFlag, CustomerRiskFlag, String>
  get riskFlag => $composableBuilder(
    column: $table.riskFlag,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get totalOrders => $composableBuilder(
    column: $table.totalOrders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDelivered => $composableBuilder(
    column: $table.totalDelivered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalFailed => $composableBuilder(
    column: $table.totalFailed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int>
  get lastDeliveredAt => $composableBuilder(
    column: $table.lastDeliveredAt,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$UsersTableFilterComposer get ownerId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> customerAddressesRefs(
    Expression<bool> Function($$CustomerAddressesTableFilterComposer f) f,
  ) {
    final $$CustomerAddressesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerAddresses,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerAddressesTableFilterComposer(
            $db: $db,
            $table: $db.customerAddresses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ordersRefs(
    Expression<bool> Function($$OrdersTableFilterComposer f) f,
  ) {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
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

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneE164 => $composableBuilder(
    column: $table.phoneE164,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneAlt => $composableBuilder(
    column: $table.phoneAlt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riskFlag => $composableBuilder(
    column: $table.riskFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalOrders => $composableBuilder(
    column: $table.totalOrders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDelivered => $composableBuilder(
    column: $table.totalDelivered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalFailed => $composableBuilder(
    column: $table.totalFailed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastDeliveredAt => $composableBuilder(
    column: $table.lastDeliveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get ownerId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
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

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PhoneE164, String> get phoneE164 =>
      $composableBuilder(column: $table.phoneE164, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PhoneE164?, String> get phoneAlt =>
      $composableBuilder(column: $table.phoneAlt, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CustomerRiskFlag, String> get riskFlag =>
      $composableBuilder(column: $table.riskFlag, builder: (column) => column);

  GeneratedColumn<int> get totalOrders => $composableBuilder(
    column: $table.totalOrders,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDelivered => $composableBuilder(
    column: $table.totalDelivered,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalFailed => $composableBuilder(
    column: $table.totalFailed,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get lastDeliveredAt =>
      $composableBuilder(
        column: $table.lastDeliveredAt,
        builder: (column) => column,
      );

  $$UsersTableAnnotationComposer get ownerId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> customerAddressesRefs<T extends Object>(
    Expression<T> Function($$CustomerAddressesTableAnnotationComposer a) f,
  ) {
    final $$CustomerAddressesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customerAddresses,
          getReferencedColumn: (t) => t.customerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerAddressesTableAnnotationComposer(
                $db: $db,
                $table: $db.customerAddresses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> ordersRefs<T extends Object>(
    Expression<T> Function($$OrdersTableAnnotationComposer a) f,
  ) {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, $$CustomersTableReferences),
          Customer,
          PrefetchHooks Function({
            bool ownerId,
            bool customerAddressesRefs,
            bool ordersRefs,
          })
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<PhoneE164> phoneE164 = const Value.absent(),
                Value<PhoneE164?> phoneAlt = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<CustomerRiskFlag> riskFlag = const Value.absent(),
                Value<int> totalOrders = const Value.absent(),
                Value<int> totalDelivered = const Value.absent(),
                Value<int> totalFailed = const Value.absent(),
                Value<DateTime?> lastDeliveredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                phoneE164: phoneE164,
                phoneAlt: phoneAlt,
                displayName: displayName,
                notes: notes,
                riskFlag: riskFlag,
                totalOrders: totalOrders,
                totalDelivered: totalDelivered,
                totalFailed: totalFailed,
                lastDeliveredAt: lastDeliveredAt,
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
                required PhoneE164 phoneE164,
                Value<PhoneE164?> phoneAlt = const Value.absent(),
                required String displayName,
                Value<String?> notes = const Value.absent(),
                Value<CustomerRiskFlag> riskFlag = const Value.absent(),
                Value<int> totalOrders = const Value.absent(),
                Value<int> totalDelivered = const Value.absent(),
                Value<int> totalFailed = const Value.absent(),
                Value<DateTime?> lastDeliveredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                phoneE164: phoneE164,
                phoneAlt: phoneAlt,
                displayName: displayName,
                notes: notes,
                riskFlag: riskFlag,
                totalOrders: totalOrders,
                totalDelivered: totalDelivered,
                totalFailed: totalFailed,
                lastDeliveredAt: lastDeliveredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ownerId = false,
                customerAddressesRefs = false,
                ordersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (customerAddressesRefs) db.customerAddresses,
                    if (ordersRefs) db.orders,
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
                        if (ownerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ownerId,
                                    referencedTable: $$CustomersTableReferences
                                        ._ownerIdTable(db),
                                    referencedColumn: $$CustomersTableReferences
                                        ._ownerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (customerAddressesRefs)
                        await $_getPrefetchedData<
                          Customer,
                          $CustomersTable,
                          CustomerAddress
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._customerAddressesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).customerAddressesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ordersRefs)
                        await $_getPrefetchedData<
                          Customer,
                          $CustomersTable,
                          Order
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._ordersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).ordersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
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

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, $$CustomersTableReferences),
      Customer,
      PrefetchHooks Function({
        bool ownerId,
        bool customerAddressesRefs,
        bool ordersRefs,
      })
    >;
typedef $$CustomerAddressesTableCreateCompanionBuilder =
    CustomerAddressesCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required int version,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> geohash,
      Value<int?> accuracyM,
      required String customerId,
      required int wilayaCode,
      required int communeId,
      Value<String?> detail,
      Value<GeoConfidence> geoConfidence,
      Value<String?> geoSource,
      Value<int> confirmedDeliveries,
      Value<String?> label,
      Value<bool> isPrimary,
      Value<int> rowid,
    });
typedef $$CustomerAddressesTableUpdateCompanionBuilder =
    CustomerAddressesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> geohash,
      Value<int?> accuracyM,
      Value<String> customerId,
      Value<int> wilayaCode,
      Value<int> communeId,
      Value<String?> detail,
      Value<GeoConfidence> geoConfidence,
      Value<String?> geoSource,
      Value<int> confirmedDeliveries,
      Value<String?> label,
      Value<bool> isPrimary,
      Value<int> rowid,
    });

final class $$CustomerAddressesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CustomerAddressesTable,
          CustomerAddress
        > {
  $$CustomerAddressesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('customer_addresses__owner_id__users__id');

  $$UsersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomersTable _customerIdTable(_$AppDatabase db) => db.customers
      .createAlias('customer_addresses__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WilayasTable _wilayaCodeTable(_$AppDatabase db) =>
      db.wilayas.createAlias('customer_addresses__wilaya_code__wilayas__code');

  $$WilayasTableProcessedTableManager get wilayaCode {
    final $_column = $_itemColumn<int>('wilaya_code')!;

    final manager = $$WilayasTableTableManager(
      $_db,
      $_db.wilayas,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wilayaCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CommunesTable _communeIdTable(_$AppDatabase db) =>
      db.communes.createAlias('customer_addresses__commune_id__communes__id');

  $$CommunesTableProcessedTableManager get communeId {
    final $_column = $_itemColumn<int>('commune_id')!;

    final manager = $$CommunesTableTableManager(
      $_db,
      $_db.communes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_communeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OrdersTable, List<Order>> _ordersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.orders,
    aliasName: 'customer_addresses__id__orders__address_id',
  );

  $$OrdersTableProcessedTableManager get ordersRefs {
    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.addressId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ordersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomerAddressesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerAddressesTable> {
  $$CustomerAddressesTableFilterComposer({
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

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geohash => $composableBuilder(
    column: $table.geohash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GeoConfidence, GeoConfidence, int>
  get geoConfidence => $composableBuilder(
    column: $table.geoConfidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get geoSource => $composableBuilder(
    column: $table.geoSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confirmedDeliveries => $composableBuilder(
    column: $table.confirmedDeliveries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get ownerId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WilayasTableFilterComposer get wilayaCode {
    final $$WilayasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wilayaCode,
      referencedTable: $db.wilayas,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WilayasTableFilterComposer(
            $db: $db,
            $table: $db.wilayas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CommunesTableFilterComposer get communeId {
    final $$CommunesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.communeId,
      referencedTable: $db.communes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommunesTableFilterComposer(
            $db: $db,
            $table: $db.communes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> ordersRefs(
    Expression<bool> Function($$OrdersTableFilterComposer f) f,
  ) {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.addressId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomerAddressesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerAddressesTable> {
  $$CustomerAddressesTableOrderingComposer({
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

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geohash => $composableBuilder(
    column: $table.geohash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get geoConfidence => $composableBuilder(
    column: $table.geoConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geoSource => $composableBuilder(
    column: $table.geoSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confirmedDeliveries => $composableBuilder(
    column: $table.confirmedDeliveries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get ownerId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WilayasTableOrderingComposer get wilayaCode {
    final $$WilayasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wilayaCode,
      referencedTable: $db.wilayas,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WilayasTableOrderingComposer(
            $db: $db,
            $table: $db.wilayas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CommunesTableOrderingComposer get communeId {
    final $$CommunesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.communeId,
      referencedTable: $db.communes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommunesTableOrderingComposer(
            $db: $db,
            $table: $db.communes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerAddressesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerAddressesTable> {
  $$CustomerAddressesTableAnnotationComposer({
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

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get geohash =>
      $composableBuilder(column: $table.geohash, builder: (column) => column);

  GeneratedColumn<int> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GeoConfidence, int> get geoConfidence =>
      $composableBuilder(
        column: $table.geoConfidence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get geoSource =>
      $composableBuilder(column: $table.geoSource, builder: (column) => column);

  GeneratedColumn<int> get confirmedDeliveries => $composableBuilder(
    column: $table.confirmedDeliveries,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  $$UsersTableAnnotationComposer get ownerId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WilayasTableAnnotationComposer get wilayaCode {
    final $$WilayasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wilayaCode,
      referencedTable: $db.wilayas,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WilayasTableAnnotationComposer(
            $db: $db,
            $table: $db.wilayas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CommunesTableAnnotationComposer get communeId {
    final $$CommunesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.communeId,
      referencedTable: $db.communes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommunesTableAnnotationComposer(
            $db: $db,
            $table: $db.communes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> ordersRefs<T extends Object>(
    Expression<T> Function($$OrdersTableAnnotationComposer a) f,
  ) {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.addressId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomerAddressesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerAddressesTable,
          CustomerAddress,
          $$CustomerAddressesTableFilterComposer,
          $$CustomerAddressesTableOrderingComposer,
          $$CustomerAddressesTableAnnotationComposer,
          $$CustomerAddressesTableCreateCompanionBuilder,
          $$CustomerAddressesTableUpdateCompanionBuilder,
          (CustomerAddress, $$CustomerAddressesTableReferences),
          CustomerAddress,
          PrefetchHooks Function({
            bool ownerId,
            bool customerId,
            bool wilayaCode,
            bool communeId,
            bool ordersRefs,
          })
        > {
  $$CustomerAddressesTableTableManager(
    _$AppDatabase db,
    $CustomerAddressesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerAddressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomerAddressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomerAddressesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> geohash = const Value.absent(),
                Value<int?> accuracyM = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<int> wilayaCode = const Value.absent(),
                Value<int> communeId = const Value.absent(),
                Value<String?> detail = const Value.absent(),
                Value<GeoConfidence> geoConfidence = const Value.absent(),
                Value<String?> geoSource = const Value.absent(),
                Value<int> confirmedDeliveries = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerAddressesCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                latitude: latitude,
                longitude: longitude,
                geohash: geohash,
                accuracyM: accuracyM,
                customerId: customerId,
                wilayaCode: wilayaCode,
                communeId: communeId,
                detail: detail,
                geoConfidence: geoConfidence,
                geoSource: geoSource,
                confirmedDeliveries: confirmedDeliveries,
                label: label,
                isPrimary: isPrimary,
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
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> geohash = const Value.absent(),
                Value<int?> accuracyM = const Value.absent(),
                required String customerId,
                required int wilayaCode,
                required int communeId,
                Value<String?> detail = const Value.absent(),
                Value<GeoConfidence> geoConfidence = const Value.absent(),
                Value<String?> geoSource = const Value.absent(),
                Value<int> confirmedDeliveries = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerAddressesCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                latitude: latitude,
                longitude: longitude,
                geohash: geohash,
                accuracyM: accuracyM,
                customerId: customerId,
                wilayaCode: wilayaCode,
                communeId: communeId,
                detail: detail,
                geoConfidence: geoConfidence,
                geoSource: geoSource,
                confirmedDeliveries: confirmedDeliveries,
                label: label,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomerAddressesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ownerId = false,
                customerId = false,
                wilayaCode = false,
                communeId = false,
                ordersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (ordersRefs) db.orders],
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
                        if (ownerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ownerId,
                                    referencedTable:
                                        $$CustomerAddressesTableReferences
                                            ._ownerIdTable(db),
                                    referencedColumn:
                                        $$CustomerAddressesTableReferences
                                            ._ownerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable:
                                        $$CustomerAddressesTableReferences
                                            ._customerIdTable(db),
                                    referencedColumn:
                                        $$CustomerAddressesTableReferences
                                            ._customerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (wilayaCode) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.wilayaCode,
                                    referencedTable:
                                        $$CustomerAddressesTableReferences
                                            ._wilayaCodeTable(db),
                                    referencedColumn:
                                        $$CustomerAddressesTableReferences
                                            ._wilayaCodeTable(db)
                                            .code,
                                  )
                                  as T;
                        }
                        if (communeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.communeId,
                                    referencedTable:
                                        $$CustomerAddressesTableReferences
                                            ._communeIdTable(db),
                                    referencedColumn:
                                        $$CustomerAddressesTableReferences
                                            ._communeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ordersRefs)
                        await $_getPrefetchedData<
                          CustomerAddress,
                          $CustomerAddressesTable,
                          Order
                        >(
                          currentTable: table,
                          referencedTable: $$CustomerAddressesTableReferences
                              ._ordersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomerAddressesTableReferences(
                                db,
                                table,
                                p0,
                              ).ordersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.addressId == item.id,
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

typedef $$CustomerAddressesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerAddressesTable,
      CustomerAddress,
      $$CustomerAddressesTableFilterComposer,
      $$CustomerAddressesTableOrderingComposer,
      $$CustomerAddressesTableAnnotationComposer,
      $$CustomerAddressesTableCreateCompanionBuilder,
      $$CustomerAddressesTableUpdateCompanionBuilder,
      (CustomerAddress, $$CustomerAddressesTableReferences),
      CustomerAddress,
      PrefetchHooks Function({
        bool ownerId,
        bool customerId,
        bool wilayaCode,
        bool communeId,
        bool ordersRefs,
      })
    >;
typedef $$BatchesTableCreateCompanionBuilder =
    BatchesCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required int version,
      required String companyId,
      required String serviceDate,
      Value<BatchStatus> status,
      Value<DateTime?> closedAt,
      Value<int> rowid,
    });
typedef $$BatchesTableUpdateCompanionBuilder =
    BatchesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> companyId,
      Value<String> serviceDate,
      Value<BatchStatus> status,
      Value<DateTime?> closedAt,
      Value<int> rowid,
    });

final class $$BatchesTableReferences
    extends BaseReferences<_$AppDatabase, $BatchesTable, Batch> {
  $$BatchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('batches__owner_id__users__id');

  $$UsersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('batches__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OrdersTable, List<Order>> _ordersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.orders,
    aliasName: 'batches__id__orders__batch_id',
  );

  $$OrdersTableProcessedTableManager get ordersRefs {
    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ordersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BatchesTableFilterComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableFilterComposer({
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

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BatchStatus, BatchStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get closedAt =>
      $composableBuilder(
        column: $table.closedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$UsersTableFilterComposer get ownerId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> ordersRefs(
    Expression<bool> Function($$OrdersTableFilterComposer f) f,
  ) {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableOrderingComposer({
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

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get ownerId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableAnnotationComposer({
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

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<BatchStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get ownerId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> ordersRefs<T extends Object>(
    Expression<T> Function($$OrdersTableAnnotationComposer a) f,
  ) {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BatchesTable,
          Batch,
          $$BatchesTableFilterComposer,
          $$BatchesTableOrderingComposer,
          $$BatchesTableAnnotationComposer,
          $$BatchesTableCreateCompanionBuilder,
          $$BatchesTableUpdateCompanionBuilder,
          (Batch, $$BatchesTableReferences),
          Batch,
          PrefetchHooks Function({
            bool ownerId,
            bool companyId,
            bool ordersRefs,
          })
        > {
  $$BatchesTableTableManager(_$AppDatabase db, $BatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> serviceDate = const Value.absent(),
                Value<BatchStatus> status = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                companyId: companyId,
                serviceDate: serviceDate,
                status: status,
                closedAt: closedAt,
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
                required String companyId,
                required String serviceDate,
                Value<BatchStatus> status = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BatchesCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                companyId: companyId,
                serviceDate: serviceDate,
                status: status,
                closedAt: closedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({ownerId = false, companyId = false, ordersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (ordersRefs) db.orders],
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
                        if (ownerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ownerId,
                                    referencedTable: $$BatchesTableReferences
                                        ._ownerIdTable(db),
                                    referencedColumn: $$BatchesTableReferences
                                        ._ownerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable: $$BatchesTableReferences
                                        ._companyIdTable(db),
                                    referencedColumn: $$BatchesTableReferences
                                        ._companyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ordersRefs)
                        await $_getPrefetchedData<Batch, $BatchesTable, Order>(
                          currentTable: table,
                          referencedTable: $$BatchesTableReferences
                              ._ordersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).ordersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.batchId == item.id,
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

typedef $$BatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BatchesTable,
      Batch,
      $$BatchesTableFilterComposer,
      $$BatchesTableOrderingComposer,
      $$BatchesTableAnnotationComposer,
      $$BatchesTableCreateCompanionBuilder,
      $$BatchesTableUpdateCompanionBuilder,
      (Batch, $$BatchesTableReferences),
      Batch,
      PrefetchHooks Function({bool ownerId, bool companyId, bool ordersRefs})
    >;
typedef $$OrdersTableCreateCompanionBuilder =
    OrdersCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required int version,
      required String batchId,
      required String companyId,
      Value<String?> customerId,
      Value<String?> addressId,
      required String trackingNumber,
      Value<DeliveryType> deliveryType,
      Value<OrderStatus> status,
      Value<int> priority,
      Value<String?> windowStart,
      Value<String?> windowEnd,
      Value<String?> notes,
      Value<Centimes> productValue,
      Value<Centimes> codAmount,
      Value<Centimes> deliveryFee,
      Value<Centimes> companyAmount,
      Value<Centimes> driverCommission,
      Value<Centimes> otherFees,
      Value<Centimes> collectedAmount,
      Value<PaymentMethod?> paymentMethod,
      Value<int?> paymentRuleVersion,
      Value<int> attemptCount,
      Value<DateTime?> deliveredAt,
      Value<DeliveryAttemptOutcome?> failureReason,
      Value<int> rowid,
    });
typedef $$OrdersTableUpdateCompanionBuilder =
    OrdersCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> batchId,
      Value<String> companyId,
      Value<String?> customerId,
      Value<String?> addressId,
      Value<String> trackingNumber,
      Value<DeliveryType> deliveryType,
      Value<OrderStatus> status,
      Value<int> priority,
      Value<String?> windowStart,
      Value<String?> windowEnd,
      Value<String?> notes,
      Value<Centimes> productValue,
      Value<Centimes> codAmount,
      Value<Centimes> deliveryFee,
      Value<Centimes> companyAmount,
      Value<Centimes> driverCommission,
      Value<Centimes> otherFees,
      Value<Centimes> collectedAmount,
      Value<PaymentMethod?> paymentMethod,
      Value<int?> paymentRuleVersion,
      Value<int> attemptCount,
      Value<DateTime?> deliveredAt,
      Value<DeliveryAttemptOutcome?> failureReason,
      Value<int> rowid,
    });

final class $$OrdersTableReferences
    extends BaseReferences<_$AppDatabase, $OrdersTable, Order> {
  $$OrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('orders__owner_id__users__id');

  $$UsersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BatchesTable _batchIdTable(_$AppDatabase db) =>
      db.batches.createAlias('orders__batch_id__batches__id');

  $$BatchesTableProcessedTableManager get batchId {
    final $_column = $_itemColumn<String>('batch_id')!;

    final manager = $$BatchesTableTableManager(
      $_db,
      $_db.batches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_batchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('orders__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('orders__customer_id__customers__id');

  $$CustomersTableProcessedTableManager? get customerId {
    final $_column = $_itemColumn<String>('customer_id');
    if ($_column == null) return null;
    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomerAddressesTable _addressIdTable(_$AppDatabase db) => db
      .customerAddresses
      .createAlias('orders__address_id__customer_addresses__id');

  $$CustomerAddressesTableProcessedTableManager? get addressId {
    final $_column = $_itemColumn<String>('address_id');
    if ($_column == null) return null;
    final manager = $$CustomerAddressesTableTableManager(
      $_db,
      $_db.customerAddresses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_addressIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DeliveryAttemptsTable, List<DeliveryAttempt>>
  _deliveryAttemptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deliveryAttempts,
    aliasName: 'orders__id__delivery_attempts__order_id',
  );

  $$DeliveryAttemptsTableProcessedTableManager get deliveryAttemptsRefs {
    final manager = $$DeliveryAttemptsTableTableManager(
      $_db,
      $_db.deliveryAttempts,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _deliveryAttemptsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProofOfDeliveryTable, List<DeliveryProof>>
  _proofOfDeliveryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.proofOfDelivery,
    aliasName: 'orders__id__proof_of_delivery__order_id',
  );

  $$ProofOfDeliveryTableProcessedTableManager get proofOfDeliveryRefs {
    final manager = $$ProofOfDeliveryTableTableManager(
      $_db,
      $_db.proofOfDelivery,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _proofOfDeliveryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
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

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackingNumber => $composableBuilder(
    column: $table.trackingNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DeliveryType, DeliveryType, String>
  get deliveryType => $composableBuilder(
    column: $table.deliveryType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<OrderStatus, OrderStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get windowStart => $composableBuilder(
    column: $table.windowStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get windowEnd => $composableBuilder(
    column: $table.windowEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int> get productValue =>
      $composableBuilder(
        column: $table.productValue,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int> get codAmount =>
      $composableBuilder(
        column: $table.codAmount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int> get deliveryFee =>
      $composableBuilder(
        column: $table.deliveryFee,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int> get companyAmount =>
      $composableBuilder(
        column: $table.companyAmount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int>
  get driverCommission => $composableBuilder(
    column: $table.driverCommission,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int> get otherFees =>
      $composableBuilder(
        column: $table.otherFees,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int> get collectedAmount =>
      $composableBuilder(
        column: $table.collectedAmount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PaymentMethod?, PaymentMethod, String>
  get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get paymentRuleVersion => $composableBuilder(
    column: $table.paymentRuleVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deliveredAt =>
      $composableBuilder(
        column: $table.deliveredAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<
    DeliveryAttemptOutcome?,
    DeliveryAttemptOutcome,
    String
  >
  get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$UsersTableFilterComposer get ownerId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BatchesTableFilterComposer get batchId {
    final $$BatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableFilterComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomerAddressesTableFilterComposer get addressId {
    final $$CustomerAddressesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.addressId,
      referencedTable: $db.customerAddresses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerAddressesTableFilterComposer(
            $db: $db,
            $table: $db.customerAddresses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> deliveryAttemptsRefs(
    Expression<bool> Function($$DeliveryAttemptsTableFilterComposer f) f,
  ) {
    final $$DeliveryAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deliveryAttempts,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveryAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.deliveryAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> proofOfDeliveryRefs(
    Expression<bool> Function($$ProofOfDeliveryTableFilterComposer f) f,
  ) {
    final $$ProofOfDeliveryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.proofOfDelivery,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProofOfDeliveryTableFilterComposer(
            $db: $db,
            $table: $db.proofOfDelivery,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
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

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackingNumber => $composableBuilder(
    column: $table.trackingNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryType => $composableBuilder(
    column: $table.deliveryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get windowStart => $composableBuilder(
    column: $table.windowStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get windowEnd => $composableBuilder(
    column: $table.windowEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productValue => $composableBuilder(
    column: $table.productValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get codAmount => $composableBuilder(
    column: $table.codAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveryFee => $composableBuilder(
    column: $table.deliveryFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get companyAmount => $composableBuilder(
    column: $table.companyAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get driverCommission => $composableBuilder(
    column: $table.driverCommission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get otherFees => $composableBuilder(
    column: $table.otherFees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get collectedAmount => $composableBuilder(
    column: $table.collectedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentRuleVersion => $composableBuilder(
    column: $table.paymentRuleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get ownerId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BatchesTableOrderingComposer get batchId {
    final $$BatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableOrderingComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomerAddressesTableOrderingComposer get addressId {
    final $$CustomerAddressesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.addressId,
      referencedTable: $db.customerAddresses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerAddressesTableOrderingComposer(
            $db: $db,
            $table: $db.customerAddresses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
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

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get trackingNumber => $composableBuilder(
    column: $table.trackingNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DeliveryType, String> get deliveryType =>
      $composableBuilder(
        column: $table.deliveryType,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<OrderStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get windowStart => $composableBuilder(
    column: $table.windowStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get windowEnd =>
      $composableBuilder(column: $table.windowEnd, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Centimes, int> get productValue =>
      $composableBuilder(
        column: $table.productValue,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Centimes, int> get codAmount =>
      $composableBuilder(column: $table.codAmount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Centimes, int> get deliveryFee =>
      $composableBuilder(
        column: $table.deliveryFee,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Centimes, int> get companyAmount =>
      $composableBuilder(
        column: $table.companyAmount,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Centimes, int> get driverCommission =>
      $composableBuilder(
        column: $table.driverCommission,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Centimes, int> get otherFees =>
      $composableBuilder(column: $table.otherFees, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Centimes, int> get collectedAmount =>
      $composableBuilder(
        column: $table.collectedAmount,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<PaymentMethod?, String> get paymentMethod =>
      $composableBuilder(
        column: $table.paymentMethod,
        builder: (column) => column,
      );

  GeneratedColumn<int> get paymentRuleVersion => $composableBuilder(
    column: $table.paymentRuleVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get deliveredAt =>
      $composableBuilder(
        column: $table.deliveredAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DeliveryAttemptOutcome?, String>
  get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  $$UsersTableAnnotationComposer get ownerId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BatchesTableAnnotationComposer get batchId {
    final $$BatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.batchId,
      referencedTable: $db.batches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.batches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomerAddressesTableAnnotationComposer get addressId {
    final $$CustomerAddressesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.addressId,
          referencedTable: $db.customerAddresses,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerAddressesTableAnnotationComposer(
                $db: $db,
                $table: $db.customerAddresses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> deliveryAttemptsRefs<T extends Object>(
    Expression<T> Function($$DeliveryAttemptsTableAnnotationComposer a) f,
  ) {
    final $$DeliveryAttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deliveryAttempts,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeliveryAttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.deliveryAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> proofOfDeliveryRefs<T extends Object>(
    Expression<T> Function($$ProofOfDeliveryTableAnnotationComposer a) f,
  ) {
    final $$ProofOfDeliveryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.proofOfDelivery,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProofOfDeliveryTableAnnotationComposer(
            $db: $db,
            $table: $db.proofOfDelivery,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrdersTable,
          Order,
          $$OrdersTableFilterComposer,
          $$OrdersTableOrderingComposer,
          $$OrdersTableAnnotationComposer,
          $$OrdersTableCreateCompanionBuilder,
          $$OrdersTableUpdateCompanionBuilder,
          (Order, $$OrdersTableReferences),
          Order,
          PrefetchHooks Function({
            bool ownerId,
            bool batchId,
            bool companyId,
            bool customerId,
            bool addressId,
            bool deliveryAttemptsRefs,
            bool proofOfDeliveryRefs,
          })
        > {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String?> addressId = const Value.absent(),
                Value<String> trackingNumber = const Value.absent(),
                Value<DeliveryType> deliveryType = const Value.absent(),
                Value<OrderStatus> status = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String?> windowStart = const Value.absent(),
                Value<String?> windowEnd = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<Centimes> productValue = const Value.absent(),
                Value<Centimes> codAmount = const Value.absent(),
                Value<Centimes> deliveryFee = const Value.absent(),
                Value<Centimes> companyAmount = const Value.absent(),
                Value<Centimes> driverCommission = const Value.absent(),
                Value<Centimes> otherFees = const Value.absent(),
                Value<Centimes> collectedAmount = const Value.absent(),
                Value<PaymentMethod?> paymentMethod = const Value.absent(),
                Value<int?> paymentRuleVersion = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> deliveredAt = const Value.absent(),
                Value<DeliveryAttemptOutcome?> failureReason =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                batchId: batchId,
                companyId: companyId,
                customerId: customerId,
                addressId: addressId,
                trackingNumber: trackingNumber,
                deliveryType: deliveryType,
                status: status,
                priority: priority,
                windowStart: windowStart,
                windowEnd: windowEnd,
                notes: notes,
                productValue: productValue,
                codAmount: codAmount,
                deliveryFee: deliveryFee,
                companyAmount: companyAmount,
                driverCommission: driverCommission,
                otherFees: otherFees,
                collectedAmount: collectedAmount,
                paymentMethod: paymentMethod,
                paymentRuleVersion: paymentRuleVersion,
                attemptCount: attemptCount,
                deliveredAt: deliveredAt,
                failureReason: failureReason,
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
                required String batchId,
                required String companyId,
                Value<String?> customerId = const Value.absent(),
                Value<String?> addressId = const Value.absent(),
                required String trackingNumber,
                Value<DeliveryType> deliveryType = const Value.absent(),
                Value<OrderStatus> status = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String?> windowStart = const Value.absent(),
                Value<String?> windowEnd = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<Centimes> productValue = const Value.absent(),
                Value<Centimes> codAmount = const Value.absent(),
                Value<Centimes> deliveryFee = const Value.absent(),
                Value<Centimes> companyAmount = const Value.absent(),
                Value<Centimes> driverCommission = const Value.absent(),
                Value<Centimes> otherFees = const Value.absent(),
                Value<Centimes> collectedAmount = const Value.absent(),
                Value<PaymentMethod?> paymentMethod = const Value.absent(),
                Value<int?> paymentRuleVersion = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> deliveredAt = const Value.absent(),
                Value<DeliveryAttemptOutcome?> failureReason =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                batchId: batchId,
                companyId: companyId,
                customerId: customerId,
                addressId: addressId,
                trackingNumber: trackingNumber,
                deliveryType: deliveryType,
                status: status,
                priority: priority,
                windowStart: windowStart,
                windowEnd: windowEnd,
                notes: notes,
                productValue: productValue,
                codAmount: codAmount,
                deliveryFee: deliveryFee,
                companyAmount: companyAmount,
                driverCommission: driverCommission,
                otherFees: otherFees,
                collectedAmount: collectedAmount,
                paymentMethod: paymentMethod,
                paymentRuleVersion: paymentRuleVersion,
                attemptCount: attemptCount,
                deliveredAt: deliveredAt,
                failureReason: failureReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$OrdersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ownerId = false,
                batchId = false,
                companyId = false,
                customerId = false,
                addressId = false,
                deliveryAttemptsRefs = false,
                proofOfDeliveryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (deliveryAttemptsRefs) db.deliveryAttempts,
                    if (proofOfDeliveryRefs) db.proofOfDelivery,
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
                        if (ownerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ownerId,
                                    referencedTable: $$OrdersTableReferences
                                        ._ownerIdTable(db),
                                    referencedColumn: $$OrdersTableReferences
                                        ._ownerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (batchId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.batchId,
                                    referencedTable: $$OrdersTableReferences
                                        ._batchIdTable(db),
                                    referencedColumn: $$OrdersTableReferences
                                        ._batchIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable: $$OrdersTableReferences
                                        ._companyIdTable(db),
                                    referencedColumn: $$OrdersTableReferences
                                        ._companyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable: $$OrdersTableReferences
                                        ._customerIdTable(db),
                                    referencedColumn: $$OrdersTableReferences
                                        ._customerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (addressId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.addressId,
                                    referencedTable: $$OrdersTableReferences
                                        ._addressIdTable(db),
                                    referencedColumn: $$OrdersTableReferences
                                        ._addressIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (deliveryAttemptsRefs)
                        await $_getPrefetchedData<
                          Order,
                          $OrdersTable,
                          DeliveryAttempt
                        >(
                          currentTable: table,
                          referencedTable: $$OrdersTableReferences
                              ._deliveryAttemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).deliveryAttemptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (proofOfDeliveryRefs)
                        await $_getPrefetchedData<
                          Order,
                          $OrdersTable,
                          DeliveryProof
                        >(
                          currentTable: table,
                          referencedTable: $$OrdersTableReferences
                              ._proofOfDeliveryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).proofOfDeliveryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.id,
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

typedef $$OrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrdersTable,
      Order,
      $$OrdersTableFilterComposer,
      $$OrdersTableOrderingComposer,
      $$OrdersTableAnnotationComposer,
      $$OrdersTableCreateCompanionBuilder,
      $$OrdersTableUpdateCompanionBuilder,
      (Order, $$OrdersTableReferences),
      Order,
      PrefetchHooks Function({
        bool ownerId,
        bool batchId,
        bool companyId,
        bool customerId,
        bool addressId,
        bool deliveryAttemptsRefs,
        bool proofOfDeliveryRefs,
      })
    >;
typedef $$DeliveryAttemptsTableCreateCompanionBuilder =
    DeliveryAttemptsCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> geohash,
      Value<int?> accuracyM,
      required String orderId,
      required int attemptNo,
      required DeliveryAttemptOutcome outcome,
      Value<String?> outcomeNote,
      required DateTime occurredAt,
      Value<int> rowid,
    });
typedef $$DeliveryAttemptsTableUpdateCompanionBuilder =
    DeliveryAttemptsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> geohash,
      Value<int?> accuracyM,
      Value<String> orderId,
      Value<int> attemptNo,
      Value<DeliveryAttemptOutcome> outcome,
      Value<String?> outcomeNote,
      Value<DateTime> occurredAt,
      Value<int> rowid,
    });

final class $$DeliveryAttemptsTableReferences
    extends
        BaseReferences<_$AppDatabase, $DeliveryAttemptsTable, DeliveryAttempt> {
  $$DeliveryAttemptsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('delivery_attempts__owner_id__users__id');

  $$UsersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OrdersTable _orderIdTable(_$AppDatabase db) =>
      db.orders.createAlias('delivery_attempts__order_id__orders__id');

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DeliveryAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $DeliveryAttemptsTable> {
  $$DeliveryAttemptsTableFilterComposer({
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

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geohash => $composableBuilder(
    column: $table.geohash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptNo => $composableBuilder(
    column: $table.attemptNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    DeliveryAttemptOutcome,
    DeliveryAttemptOutcome,
    String
  >
  get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get outcomeNote => $composableBuilder(
    column: $table.outcomeNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get occurredAt =>
      $composableBuilder(
        column: $table.occurredAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$UsersTableFilterComposer get ownerId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeliveryAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeliveryAttemptsTable> {
  $$DeliveryAttemptsTableOrderingComposer({
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

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geohash => $composableBuilder(
    column: $table.geohash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accuracyM => $composableBuilder(
    column: $table.accuracyM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptNo => $composableBuilder(
    column: $table.attemptNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcomeNote => $composableBuilder(
    column: $table.outcomeNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get ownerId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableOrderingComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeliveryAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeliveryAttemptsTable> {
  $$DeliveryAttemptsTableAnnotationComposer({
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

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get geohash =>
      $composableBuilder(column: $table.geohash, builder: (column) => column);

  GeneratedColumn<int> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<int> get attemptNo =>
      $composableBuilder(column: $table.attemptNo, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DeliveryAttemptOutcome, String>
  get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get outcomeNote => $composableBuilder(
    column: $table.outcomeNote,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get occurredAt =>
      $composableBuilder(
        column: $table.occurredAt,
        builder: (column) => column,
      );

  $$UsersTableAnnotationComposer get ownerId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeliveryAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeliveryAttemptsTable,
          DeliveryAttempt,
          $$DeliveryAttemptsTableFilterComposer,
          $$DeliveryAttemptsTableOrderingComposer,
          $$DeliveryAttemptsTableAnnotationComposer,
          $$DeliveryAttemptsTableCreateCompanionBuilder,
          $$DeliveryAttemptsTableUpdateCompanionBuilder,
          (DeliveryAttempt, $$DeliveryAttemptsTableReferences),
          DeliveryAttempt,
          PrefetchHooks Function({bool ownerId, bool orderId})
        > {
  $$DeliveryAttemptsTableTableManager(
    _$AppDatabase db,
    $DeliveryAttemptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeliveryAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeliveryAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeliveryAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> geohash = const Value.absent(),
                Value<int?> accuracyM = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<int> attemptNo = const Value.absent(),
                Value<DeliveryAttemptOutcome> outcome = const Value.absent(),
                Value<String?> outcomeNote = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeliveryAttemptsCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                latitude: latitude,
                longitude: longitude,
                geohash: geohash,
                accuracyM: accuracyM,
                orderId: orderId,
                attemptNo: attemptNo,
                outcome: outcome,
                outcomeNote: outcomeNote,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required DateTime createdAt,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> geohash = const Value.absent(),
                Value<int?> accuracyM = const Value.absent(),
                required String orderId,
                required int attemptNo,
                required DeliveryAttemptOutcome outcome,
                Value<String?> outcomeNote = const Value.absent(),
                required DateTime occurredAt,
                Value<int> rowid = const Value.absent(),
              }) => DeliveryAttemptsCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                latitude: latitude,
                longitude: longitude,
                geohash: geohash,
                accuracyM: accuracyM,
                orderId: orderId,
                attemptNo: attemptNo,
                outcome: outcome,
                outcomeNote: outcomeNote,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeliveryAttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ownerId = false, orderId = false}) {
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
                    if (ownerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ownerId,
                                referencedTable:
                                    $$DeliveryAttemptsTableReferences
                                        ._ownerIdTable(db),
                                referencedColumn:
                                    $$DeliveryAttemptsTableReferences
                                        ._ownerIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable:
                                    $$DeliveryAttemptsTableReferences
                                        ._orderIdTable(db),
                                referencedColumn:
                                    $$DeliveryAttemptsTableReferences
                                        ._orderIdTable(db)
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

typedef $$DeliveryAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeliveryAttemptsTable,
      DeliveryAttempt,
      $$DeliveryAttemptsTableFilterComposer,
      $$DeliveryAttemptsTableOrderingComposer,
      $$DeliveryAttemptsTableAnnotationComposer,
      $$DeliveryAttemptsTableCreateCompanionBuilder,
      $$DeliveryAttemptsTableUpdateCompanionBuilder,
      (DeliveryAttempt, $$DeliveryAttemptsTableReferences),
      DeliveryAttempt,
      PrefetchHooks Function({bool ownerId, bool orderId})
    >;
typedef $$ProofOfDeliveryTableCreateCompanionBuilder =
    ProofOfDeliveryCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required String orderId,
      Value<String?> photoPath,
      Value<String?> signaturePath,
      Value<double?> latitude,
      Value<double?> longitude,
      required DateTime capturedAt,
      Value<String?> driverNote,
      Value<bool> uploaded,
      Value<int> rowid,
    });
typedef $$ProofOfDeliveryTableUpdateCompanionBuilder =
    ProofOfDeliveryCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<String> orderId,
      Value<String?> photoPath,
      Value<String?> signaturePath,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<DateTime> capturedAt,
      Value<String?> driverNote,
      Value<bool> uploaded,
      Value<int> rowid,
    });

final class $$ProofOfDeliveryTableReferences
    extends
        BaseReferences<_$AppDatabase, $ProofOfDeliveryTable, DeliveryProof> {
  $$ProofOfDeliveryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('proof_of_delivery__owner_id__users__id');

  $$UsersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<String>('owner_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OrdersTable _orderIdTable(_$AppDatabase db) =>
      db.orders.createAlias('proof_of_delivery__order_id__orders__id');

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProofOfDeliveryTableFilterComposer
    extends Composer<_$AppDatabase, $ProofOfDeliveryTable> {
  $$ProofOfDeliveryTableFilterComposer({
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

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signaturePath => $composableBuilder(
    column: $table.signaturePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get capturedAt =>
      $composableBuilder(
        column: $table.capturedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get driverNote => $composableBuilder(
    column: $table.driverNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get ownerId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProofOfDeliveryTableOrderingComposer
    extends Composer<_$AppDatabase, $ProofOfDeliveryTable> {
  $$ProofOfDeliveryTableOrderingComposer({
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

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signaturePath => $composableBuilder(
    column: $table.signaturePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driverNote => $composableBuilder(
    column: $table.driverNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get ownerId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableOrderingComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProofOfDeliveryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProofOfDeliveryTable> {
  $$ProofOfDeliveryTableAnnotationComposer({
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

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get signaturePath => $composableBuilder(
    column: $table.signaturePath,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get capturedAt =>
      $composableBuilder(
        column: $table.capturedAt,
        builder: (column) => column,
      );

  GeneratedColumn<String> get driverNote => $composableBuilder(
    column: $table.driverNote,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get uploaded =>
      $composableBuilder(column: $table.uploaded, builder: (column) => column);

  $$UsersTableAnnotationComposer get ownerId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProofOfDeliveryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProofOfDeliveryTable,
          DeliveryProof,
          $$ProofOfDeliveryTableFilterComposer,
          $$ProofOfDeliveryTableOrderingComposer,
          $$ProofOfDeliveryTableAnnotationComposer,
          $$ProofOfDeliveryTableCreateCompanionBuilder,
          $$ProofOfDeliveryTableUpdateCompanionBuilder,
          (DeliveryProof, $$ProofOfDeliveryTableReferences),
          DeliveryProof,
          PrefetchHooks Function({bool ownerId, bool orderId})
        > {
  $$ProofOfDeliveryTableTableManager(
    _$AppDatabase db,
    $ProofOfDeliveryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProofOfDeliveryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProofOfDeliveryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProofOfDeliveryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> signaturePath = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<String?> driverNote = const Value.absent(),
                Value<bool> uploaded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProofOfDeliveryCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                orderId: orderId,
                photoPath: photoPath,
                signaturePath: signaturePath,
                latitude: latitude,
                longitude: longitude,
                capturedAt: capturedAt,
                driverNote: driverNote,
                uploaded: uploaded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required DateTime createdAt,
                required String orderId,
                Value<String?> photoPath = const Value.absent(),
                Value<String?> signaturePath = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                required DateTime capturedAt,
                Value<String?> driverNote = const Value.absent(),
                Value<bool> uploaded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProofOfDeliveryCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                orderId: orderId,
                photoPath: photoPath,
                signaturePath: signaturePath,
                latitude: latitude,
                longitude: longitude,
                capturedAt: capturedAt,
                driverNote: driverNote,
                uploaded: uploaded,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProofOfDeliveryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ownerId = false, orderId = false}) {
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
                    if (ownerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ownerId,
                                referencedTable:
                                    $$ProofOfDeliveryTableReferences
                                        ._ownerIdTable(db),
                                referencedColumn:
                                    $$ProofOfDeliveryTableReferences
                                        ._ownerIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable:
                                    $$ProofOfDeliveryTableReferences
                                        ._orderIdTable(db),
                                referencedColumn:
                                    $$ProofOfDeliveryTableReferences
                                        ._orderIdTable(db)
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

typedef $$ProofOfDeliveryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProofOfDeliveryTable,
      DeliveryProof,
      $$ProofOfDeliveryTableFilterComposer,
      $$ProofOfDeliveryTableOrderingComposer,
      $$ProofOfDeliveryTableAnnotationComposer,
      $$ProofOfDeliveryTableCreateCompanionBuilder,
      $$ProofOfDeliveryTableUpdateCompanionBuilder,
      (DeliveryProof, $$ProofOfDeliveryTableReferences),
      DeliveryProof,
      PrefetchHooks Function({bool ownerId, bool orderId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db, _db.companies);
  $$PaymentRulesTableTableManager get paymentRules =>
      $$PaymentRulesTableTableManager(_db, _db.paymentRules);
  $$WilayasTableTableManager get wilayas =>
      $$WilayasTableTableManager(_db, _db.wilayas);
  $$CommunesTableTableManager get communes =>
      $$CommunesTableTableManager(_db, _db.communes);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$CustomerAddressesTableTableManager get customerAddresses =>
      $$CustomerAddressesTableTableManager(_db, _db.customerAddresses);
  $$BatchesTableTableManager get batches =>
      $$BatchesTableTableManager(_db, _db.batches);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$DeliveryAttemptsTableTableManager get deliveryAttempts =>
      $$DeliveryAttemptsTableTableManager(_db, _db.deliveryAttempts);
  $$ProofOfDeliveryTableTableManager get proofOfDelivery =>
      $$ProofOfDeliveryTableTableManager(_db, _db.proofOfDelivery);
}
