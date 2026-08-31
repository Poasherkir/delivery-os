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
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
      ),
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      ),
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

  /// Null until the driver tells us their name.
  ///
  /// Same reasoning as [phone], and it matters for the same reason: there is no
  /// signup, so a non-null column would force `data/` to invent a placeholder,
  /// and a placeholder in a *display* field is one that eventually gets shown
  /// to someone. Null is the honest representation of "not asked yet", and the
  /// presentation layer is where a localized stand-in belongs.
  final String? displayName;

  /// Language tag, `ar` or `fr` — or **null, meaning "follow the device"**.
  ///
  /// Nullable on purpose, and the null is the whole point. This column stores
  /// the driver's *preference*, not its effective value on one handset, because
  /// the preference is what syncs at V2. A driver set to "follow the device"
  /// who moves to a phone configured in French wants French; storing the
  /// resolved tag `ar` from the old phone would hand them Arabic on a French
  /// phone with no way to understand why.
  ///
  /// No default, for the same reason. A default of `ar` would record a
  /// preference the driver never expressed, and first launch would be
  /// indistinguishable from someone who deliberately chose Arabic.
  ///
  /// Plain text rather than an enum converter, deliberately. A locale that this
  /// build no longer ships must degrade to "follow the device" rather than
  /// throw — dropping a language must not brick the app for whoever had it
  /// selected. `AppLocales.isSupported` decides; the column just stores.
  ///
  /// The value the first frame reads lives in shared preferences, because the
  /// encrypted database needs an async keystore round trip to open. That store
  /// is a cache of this one: writes go here first and mirror there second, so
  /// it can only ever be stale, never ahead.
  final String? locale;
  const User({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.phone,
    this.displayName,
    this.locale,
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
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || locale != null) {
      map['locale'] = Variable<String>(locale);
    }
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
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      locale: locale == null && nullToAbsent
          ? const Value.absent()
          : Value(locale),
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
      displayName: serializer.fromJson<String?>(json['displayName']),
      locale: serializer.fromJson<String?>(json['locale']),
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
      'displayName': serializer.toJson<String?>(displayName),
      'locale': serializer.toJson<String?>(locale),
    };
  }

  User copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<PhoneE164?> phone = const Value.absent(),
    Value<String?> displayName = const Value.absent(),
    Value<String?> locale = const Value.absent(),
  }) => User(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    phone: phone.present ? phone.value : this.phone,
    displayName: displayName.present ? displayName.value : this.displayName,
    locale: locale.present ? locale.value : this.locale,
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
  final Value<String?> displayName;
  final Value<String?> locale;
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
    this.displayName = const Value.absent(),
    this.locale = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
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
    Value<String?>? displayName,
    Value<String?>? locale,
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
  static const VerificationMeta _isRetiredMeta = const VerificationMeta(
    'isRetired',
  );
  @override
  late final GeneratedColumn<bool> isRetired = GeneratedColumn<bool>(
    'is_retired',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_retired" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    nameFr,
    nameAr,
    latitude,
    longitude,
    geohash,
    isRetired,
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
    if (data.containsKey('is_retired')) {
      context.handle(
        _isRetiredMeta,
        isRetired.isAcceptableOrUnknown(data['is_retired']!, _isRetiredMeta),
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
      isRetired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_retired'],
      )!,
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

  /// True when a dataset update no longer lists this row.
  ///
  /// **The loader never deletes.** Administrative reform merges and renames
  /// wilayas — 48 became 58 in 2019 and 69 in 2025 — and `customer_addresses`
  /// holds foreign keys into this table. Deleting a row that a real customer
  /// address points at would orphan it, and a loader that had to decide which
  /// rows are safe to delete would carry a partial-delete policy nobody can
  /// hold in their head.
  ///
  /// So retirement is a state rather than an absence, with defined behaviour on
  /// each side:
  ///
  /// * **Pickers and search filter on `is_retired = false`** — nobody gets
  ///   offered a wilaya that no longer exists.
  /// * **Lookups by id ignore it entirely** — an address pointing at a merged
  ///   wilaya still resolves and still renders its name, so old orders stay
  ///   readable forever.
  ///
  /// Functional state, not an audit column: the same category as
  /// `matrix_cache.fetched_at`, so it does not disturb invariant 3's
  /// bundled-reference-data rule that this table carries no audit columns.
  final bool isRetired;
  const Wilaya({
    required this.code,
    required this.nameFr,
    required this.nameAr,
    this.latitude,
    this.longitude,
    this.geohash,
    required this.isRetired,
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
    map['is_retired'] = Variable<bool>(isRetired);
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
      isRetired: Value(isRetired),
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
      isRetired: serializer.fromJson<bool>(json['isRetired']),
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
      'isRetired': serializer.toJson<bool>(isRetired),
    };
  }

  Wilaya copyWith({
    int? code,
    String? nameFr,
    String? nameAr,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> geohash = const Value.absent(),
    bool? isRetired,
  }) => Wilaya(
    code: code ?? this.code,
    nameFr: nameFr ?? this.nameFr,
    nameAr: nameAr ?? this.nameAr,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    geohash: geohash.present ? geohash.value : this.geohash,
    isRetired: isRetired ?? this.isRetired,
  );
  Wilaya copyWithCompanion(WilayasCompanion data) {
    return Wilaya(
      code: data.code.present ? data.code.value : this.code,
      nameFr: data.nameFr.present ? data.nameFr.value : this.nameFr,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      geohash: data.geohash.present ? data.geohash.value : this.geohash,
      isRetired: data.isRetired.present ? data.isRetired.value : this.isRetired,
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
          ..write('geohash: $geohash, ')
          ..write('isRetired: $isRetired')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    code,
    nameFr,
    nameAr,
    latitude,
    longitude,
    geohash,
    isRetired,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Wilaya &&
          other.code == this.code &&
          other.nameFr == this.nameFr &&
          other.nameAr == this.nameAr &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.geohash == this.geohash &&
          other.isRetired == this.isRetired);
}

class WilayasCompanion extends UpdateCompanion<Wilaya> {
  final Value<int> code;
  final Value<String> nameFr;
  final Value<String> nameAr;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> geohash;
  final Value<bool> isRetired;
  const WilayasCompanion({
    this.code = const Value.absent(),
    this.nameFr = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geohash = const Value.absent(),
    this.isRetired = const Value.absent(),
  });
  WilayasCompanion.insert({
    this.code = const Value.absent(),
    required String nameFr,
    required String nameAr,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geohash = const Value.absent(),
    this.isRetired = const Value.absent(),
  }) : nameFr = Value(nameFr),
       nameAr = Value(nameAr);
  static Insertable<Wilaya> custom({
    Expression<int>? code,
    Expression<String>? nameFr,
    Expression<String>? nameAr,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? geohash,
    Expression<bool>? isRetired,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (nameFr != null) 'name_fr': nameFr,
      if (nameAr != null) 'name_ar': nameAr,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (geohash != null) 'geohash': geohash,
      if (isRetired != null) 'is_retired': isRetired,
    });
  }

  WilayasCompanion copyWith({
    Value<int>? code,
    Value<String>? nameFr,
    Value<String>? nameAr,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? geohash,
    Value<bool>? isRetired,
  }) {
    return WilayasCompanion(
      code: code ?? this.code,
      nameFr: nameFr ?? this.nameFr,
      nameAr: nameAr ?? this.nameAr,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      isRetired: isRetired ?? this.isRetired,
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
    if (isRetired.present) {
      map['is_retired'] = Variable<bool>(isRetired.value);
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
          ..write('geohash: $geohash, ')
          ..write('isRetired: $isRetired')
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
  static const VerificationMeta _isRetiredMeta = const VerificationMeta(
    'isRetired',
  );
  @override
  late final GeneratedColumn<bool> isRetired = GeneratedColumn<bool>(
    'is_retired',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_retired" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    isRetired,
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
    if (data.containsKey('is_retired')) {
      context.handle(
        _isRetiredMeta,
        isRetired.isAcceptableOrUnknown(data['is_retired']!, _isRetiredMeta),
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
      isRetired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_retired'],
      )!,
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

  /// True when a dataset update no longer lists this commune. See
  /// [Wilayas.isRetired] for the full reasoning.
  ///
  /// Communes are where this earns its keep. The eleven wilayas created in
  /// November 2025 were carved out of existing ones, so commune *shapes* did
  /// not move but their *parent* did — a dataset predating the reform assigns
  /// them to a wilaya that no longer exists. Retiring rather than deleting is
  /// what lets the table absorb that without breaking a single stored address.
  final bool isRetired;
  const Commune({
    required this.id,
    required this.wilayaCode,
    required this.nameFr,
    required this.nameAr,
    this.latitude,
    this.longitude,
    this.geohash,
    this.boundary,
    required this.isRetired,
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
    map['is_retired'] = Variable<bool>(isRetired);
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
      isRetired: Value(isRetired),
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
      isRetired: serializer.fromJson<bool>(json['isRetired']),
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
      'isRetired': serializer.toJson<bool>(isRetired),
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
    bool? isRetired,
  }) => Commune(
    id: id ?? this.id,
    wilayaCode: wilayaCode ?? this.wilayaCode,
    nameFr: nameFr ?? this.nameFr,
    nameAr: nameAr ?? this.nameAr,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    geohash: geohash.present ? geohash.value : this.geohash,
    boundary: boundary.present ? boundary.value : this.boundary,
    isRetired: isRetired ?? this.isRetired,
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
      isRetired: data.isRetired.present ? data.isRetired.value : this.isRetired,
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
          ..write('boundary: $boundary, ')
          ..write('isRetired: $isRetired')
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
    isRetired,
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
          other.boundary == this.boundary &&
          other.isRetired == this.isRetired);
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
  final Value<bool> isRetired;
  const CommunesCompanion({
    this.id = const Value.absent(),
    this.wilayaCode = const Value.absent(),
    this.nameFr = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geohash = const Value.absent(),
    this.boundary = const Value.absent(),
    this.isRetired = const Value.absent(),
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
    this.isRetired = const Value.absent(),
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
    Expression<bool>? isRetired,
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
      if (isRetired != null) 'is_retired': isRetired,
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
    Value<bool>? isRetired,
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
      isRetired: isRetired ?? this.isRetired,
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
    if (isRetired.present) {
      map['is_retired'] = Variable<bool>(isRetired.value);
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
          ..write('boundary: $boundary, ')
          ..write('isRetired: $isRetired')
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
  lastAttemptOutcome =
      GeneratedColumn<String>(
        'last_attempt_outcome',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DeliveryAttemptOutcome?>(
        $OrdersTable.$converterlastAttemptOutcomen,
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
    lastAttemptOutcome,
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
      lastAttemptOutcome: $OrdersTable.$converterlastAttemptOutcomen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_attempt_outcome'],
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
  static TypeConverter<DeliveryAttemptOutcome, String>
  $converterlastAttemptOutcome =
      const EnumTextConverter<DeliveryAttemptOutcome>(
        DeliveryAttemptOutcome.values,
        'DeliveryAttemptOutcome',
      );
  static TypeConverter<DeliveryAttemptOutcome?, String?>
  $converterlastAttemptOutcomen = NullAwareTypeConverter.wrap(
    $converterlastAttemptOutcome,
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

  /// The outcome of the most recent attempt — **any** attempt, not only a
  /// failed one. Null means never attempted.
  ///
  /// **This is a cache.** `delivery_attempts` is the record; this is a
  /// denormalization of its most recent row, so an order list renders without a
  /// join. Nothing derives money from it.
  ///
  /// **Written only by the transaction that inserts the attempt**, never set
  /// independently. That is the EntityStamper argument again: a cache
  /// maintained by convention drifts out of step with its source, a cache
  /// maintained by a single write path cannot.
  ///
  /// Populated on success as well as failure. A field that is only sometimes
  /// maintained is worse than one always maintained — a reader has to know
  /// which case they are in before they can trust it.
  final DeliveryAttemptOutcome? lastAttemptOutcome;
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
    this.lastAttemptOutcome,
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
    if (!nullToAbsent || lastAttemptOutcome != null) {
      map['last_attempt_outcome'] = Variable<String>(
        $OrdersTable.$converterlastAttemptOutcomen.toSql(lastAttemptOutcome),
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
      lastAttemptOutcome: lastAttemptOutcome == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptOutcome),
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
      lastAttemptOutcome: serializer.fromJson<DeliveryAttemptOutcome?>(
        json['lastAttemptOutcome'],
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
      'lastAttemptOutcome': serializer.toJson<DeliveryAttemptOutcome?>(
        lastAttemptOutcome,
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
    Value<DeliveryAttemptOutcome?> lastAttemptOutcome = const Value.absent(),
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
    lastAttemptOutcome: lastAttemptOutcome.present
        ? lastAttemptOutcome.value
        : this.lastAttemptOutcome,
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
      lastAttemptOutcome: data.lastAttemptOutcome.present
          ? data.lastAttemptOutcome.value
          : this.lastAttemptOutcome,
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
          ..write('lastAttemptOutcome: $lastAttemptOutcome')
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
    lastAttemptOutcome,
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
          other.lastAttemptOutcome == this.lastAttemptOutcome);
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
  final Value<DeliveryAttemptOutcome?> lastAttemptOutcome;
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
    this.lastAttemptOutcome = const Value.absent(),
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
    this.lastAttemptOutcome = const Value.absent(),
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
    Expression<String>? lastAttemptOutcome,
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
      if (lastAttemptOutcome != null)
        'last_attempt_outcome': lastAttemptOutcome,
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
    Value<DeliveryAttemptOutcome?>? lastAttemptOutcome,
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
      lastAttemptOutcome: lastAttemptOutcome ?? this.lastAttemptOutcome,
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
    if (lastAttemptOutcome.present) {
      map['last_attempt_outcome'] = Variable<String>(
        $OrdersTable.$converterlastAttemptOutcomen.toSql(
          lastAttemptOutcome.value,
        ),
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
          ..write('lastAttemptOutcome: $lastAttemptOutcome, ')
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

class $RoutesTable extends Routes with TableInfo<$RoutesTable, Route> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutesTable(this.attachedDatabase, [this._alias]);
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
      ).withConverter<DateTime>($RoutesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($RoutesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($RoutesTable.$converterdeletedAtn);
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
  late final GeneratedColumnWithTypeConverter<RouteStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('draft'),
      ).withConverter<RouteStatus>($RoutesTable.$converterstatus);
  static const VerificationMeta _originLatitudeMeta = const VerificationMeta(
    'originLatitude',
  );
  @override
  late final GeneratedColumn<double> originLatitude = GeneratedColumn<double>(
    'origin_latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originLongitudeMeta = const VerificationMeta(
    'originLongitude',
  );
  @override
  late final GeneratedColumn<double> originLongitude = GeneratedColumn<double>(
    'origin_longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalDistanceMMeta = const VerificationMeta(
    'totalDistanceM',
  );
  @override
  late final GeneratedColumn<int> totalDistanceM = GeneratedColumn<int>(
    'total_distance_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalDurationSMeta = const VerificationMeta(
    'totalDurationS',
  );
  @override
  late final GeneratedColumn<int> totalDurationS = GeneratedColumn<int>(
    'total_duration_s',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> optimizedAt =
      GeneratedColumn<int>(
        'optimized_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($RoutesTable.$converteroptimizedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> startedAt =
      GeneratedColumn<int>(
        'started_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($RoutesTable.$converterstartedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> completedAt =
      GeneratedColumn<int>(
        'completed_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($RoutesTable.$convertercompletedAtn);
  static const VerificationMeta _algorithmMeta = const VerificationMeta(
    'algorithm',
  );
  @override
  late final GeneratedColumn<String> algorithm = GeneratedColumn<String>(
    'algorithm',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    serviceDate,
    status,
    originLatitude,
    originLongitude,
    totalDistanceM,
    totalDurationS,
    optimizedAt,
    startedAt,
    completedAt,
    algorithm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Route> instance, {
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
    if (data.containsKey('origin_latitude')) {
      context.handle(
        _originLatitudeMeta,
        originLatitude.isAcceptableOrUnknown(
          data['origin_latitude']!,
          _originLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('origin_longitude')) {
      context.handle(
        _originLongitudeMeta,
        originLongitude.isAcceptableOrUnknown(
          data['origin_longitude']!,
          _originLongitudeMeta,
        ),
      );
    }
    if (data.containsKey('total_distance_m')) {
      context.handle(
        _totalDistanceMMeta,
        totalDistanceM.isAcceptableOrUnknown(
          data['total_distance_m']!,
          _totalDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('total_duration_s')) {
      context.handle(
        _totalDurationSMeta,
        totalDurationS.isAcceptableOrUnknown(
          data['total_duration_s']!,
          _totalDurationSMeta,
        ),
      );
    }
    if (data.containsKey('algorithm')) {
      context.handle(
        _algorithmMeta,
        algorithm.isAcceptableOrUnknown(data['algorithm']!, _algorithmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Route map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Route(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $RoutesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $RoutesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $RoutesTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serviceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_date'],
      )!,
      status: $RoutesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      originLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}origin_latitude'],
      ),
      originLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}origin_longitude'],
      ),
      totalDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_distance_m'],
      ),
      totalDurationS: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_duration_s'],
      ),
      optimizedAt: $RoutesTable.$converteroptimizedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}optimized_at'],
        ),
      ),
      startedAt: $RoutesTable.$converterstartedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}started_at'],
        ),
      ),
      completedAt: $RoutesTable.$convertercompletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}completed_at'],
        ),
      ),
      algorithm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}algorithm'],
      ),
    );
  }

  @override
  $RoutesTable createAlias(String alias) {
    return $RoutesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<RouteStatus, String> $converterstatus =
      const EnumTextConverter<RouteStatus>(RouteStatus.values, 'RouteStatus');
  static TypeConverter<DateTime, int> $converteroptimizedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converteroptimizedAtn =
      NullAwareTypeConverter.wrap($converteroptimizedAt);
  static TypeConverter<DateTime, int> $converterstartedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterstartedAtn =
      NullAwareTypeConverter.wrap($converterstartedAt);
  static TypeConverter<DateTime, int> $convertercompletedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $convertercompletedAtn =
      NullAwareTypeConverter.wrap($convertercompletedAt);
}

class Route extends DataClass implements Insertable<Route> {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Soft delete. Null means live.
  final DateTime? deletedAt;

  /// Incremented on every write. Starts at 1.
  final int version;

  /// `YYYY-MM-DD`. The business day, same convention as batches.
  final String serviceDate;
  final RouteStatus status;

  /// Where the driver started. No accuracy radius: this is a chosen origin,
  /// not a measured fix, so [GeoFixColumns] would be the wrong shape.
  final double? originLatitude;
  final double? originLongitude;
  final int? totalDistanceM;
  final int? totalDurationS;
  final DateTime? optimizedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  /// Which solver produced the sequence: `dart-2opt-v1`, later `ortools-v1`.
  ///
  /// Recorded so a route that looks wrong months later can be attributed to
  /// the algorithm that built it rather than guessed at.
  final String? algorithm;
  const Route({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.serviceDate,
    required this.status,
    this.originLatitude,
    this.originLongitude,
    this.totalDistanceM,
    this.totalDurationS,
    this.optimizedAt,
    this.startedAt,
    this.completedAt,
    this.algorithm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $RoutesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $RoutesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $RoutesTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['version'] = Variable<int>(version);
    map['service_date'] = Variable<String>(serviceDate);
    {
      map['status'] = Variable<String>(
        $RoutesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || originLatitude != null) {
      map['origin_latitude'] = Variable<double>(originLatitude);
    }
    if (!nullToAbsent || originLongitude != null) {
      map['origin_longitude'] = Variable<double>(originLongitude);
    }
    if (!nullToAbsent || totalDistanceM != null) {
      map['total_distance_m'] = Variable<int>(totalDistanceM);
    }
    if (!nullToAbsent || totalDurationS != null) {
      map['total_duration_s'] = Variable<int>(totalDurationS);
    }
    if (!nullToAbsent || optimizedAt != null) {
      map['optimized_at'] = Variable<int>(
        $RoutesTable.$converteroptimizedAtn.toSql(optimizedAt),
      );
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<int>(
        $RoutesTable.$converterstartedAtn.toSql(startedAt),
      );
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(
        $RoutesTable.$convertercompletedAtn.toSql(completedAt),
      );
    }
    if (!nullToAbsent || algorithm != null) {
      map['algorithm'] = Variable<String>(algorithm);
    }
    return map;
  }

  RoutesCompanion toCompanion(bool nullToAbsent) {
    return RoutesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      serviceDate: Value(serviceDate),
      status: Value(status),
      originLatitude: originLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(originLatitude),
      originLongitude: originLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(originLongitude),
      totalDistanceM: totalDistanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(totalDistanceM),
      totalDurationS: totalDurationS == null && nullToAbsent
          ? const Value.absent()
          : Value(totalDurationS),
      optimizedAt: optimizedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(optimizedAt),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      algorithm: algorithm == null && nullToAbsent
          ? const Value.absent()
          : Value(algorithm),
    );
  }

  factory Route.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Route(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      serviceDate: serializer.fromJson<String>(json['serviceDate']),
      status: serializer.fromJson<RouteStatus>(json['status']),
      originLatitude: serializer.fromJson<double?>(json['originLatitude']),
      originLongitude: serializer.fromJson<double?>(json['originLongitude']),
      totalDistanceM: serializer.fromJson<int?>(json['totalDistanceM']),
      totalDurationS: serializer.fromJson<int?>(json['totalDurationS']),
      optimizedAt: serializer.fromJson<DateTime?>(json['optimizedAt']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      algorithm: serializer.fromJson<String?>(json['algorithm']),
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
      'serviceDate': serializer.toJson<String>(serviceDate),
      'status': serializer.toJson<RouteStatus>(status),
      'originLatitude': serializer.toJson<double?>(originLatitude),
      'originLongitude': serializer.toJson<double?>(originLongitude),
      'totalDistanceM': serializer.toJson<int?>(totalDistanceM),
      'totalDurationS': serializer.toJson<int?>(totalDurationS),
      'optimizedAt': serializer.toJson<DateTime?>(optimizedAt),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'algorithm': serializer.toJson<String?>(algorithm),
    };
  }

  Route copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? serviceDate,
    RouteStatus? status,
    Value<double?> originLatitude = const Value.absent(),
    Value<double?> originLongitude = const Value.absent(),
    Value<int?> totalDistanceM = const Value.absent(),
    Value<int?> totalDurationS = const Value.absent(),
    Value<DateTime?> optimizedAt = const Value.absent(),
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> algorithm = const Value.absent(),
  }) => Route(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    serviceDate: serviceDate ?? this.serviceDate,
    status: status ?? this.status,
    originLatitude: originLatitude.present
        ? originLatitude.value
        : this.originLatitude,
    originLongitude: originLongitude.present
        ? originLongitude.value
        : this.originLongitude,
    totalDistanceM: totalDistanceM.present
        ? totalDistanceM.value
        : this.totalDistanceM,
    totalDurationS: totalDurationS.present
        ? totalDurationS.value
        : this.totalDurationS,
    optimizedAt: optimizedAt.present ? optimizedAt.value : this.optimizedAt,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    algorithm: algorithm.present ? algorithm.value : this.algorithm,
  );
  Route copyWithCompanion(RoutesCompanion data) {
    return Route(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      serviceDate: data.serviceDate.present
          ? data.serviceDate.value
          : this.serviceDate,
      status: data.status.present ? data.status.value : this.status,
      originLatitude: data.originLatitude.present
          ? data.originLatitude.value
          : this.originLatitude,
      originLongitude: data.originLongitude.present
          ? data.originLongitude.value
          : this.originLongitude,
      totalDistanceM: data.totalDistanceM.present
          ? data.totalDistanceM.value
          : this.totalDistanceM,
      totalDurationS: data.totalDurationS.present
          ? data.totalDurationS.value
          : this.totalDurationS,
      optimizedAt: data.optimizedAt.present
          ? data.optimizedAt.value
          : this.optimizedAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      algorithm: data.algorithm.present ? data.algorithm.value : this.algorithm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Route(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('status: $status, ')
          ..write('originLatitude: $originLatitude, ')
          ..write('originLongitude: $originLongitude, ')
          ..write('totalDistanceM: $totalDistanceM, ')
          ..write('totalDurationS: $totalDurationS, ')
          ..write('optimizedAt: $optimizedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('algorithm: $algorithm')
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
    serviceDate,
    status,
    originLatitude,
    originLongitude,
    totalDistanceM,
    totalDurationS,
    optimizedAt,
    startedAt,
    completedAt,
    algorithm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Route &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.serviceDate == this.serviceDate &&
          other.status == this.status &&
          other.originLatitude == this.originLatitude &&
          other.originLongitude == this.originLongitude &&
          other.totalDistanceM == this.totalDistanceM &&
          other.totalDurationS == this.totalDurationS &&
          other.optimizedAt == this.optimizedAt &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.algorithm == this.algorithm);
}

class RoutesCompanion extends UpdateCompanion<Route> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> serviceDate;
  final Value<RouteStatus> status;
  final Value<double?> originLatitude;
  final Value<double?> originLongitude;
  final Value<int?> totalDistanceM;
  final Value<int?> totalDurationS;
  final Value<DateTime?> optimizedAt;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String?> algorithm;
  final Value<int> rowid;
  const RoutesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.serviceDate = const Value.absent(),
    this.status = const Value.absent(),
    this.originLatitude = const Value.absent(),
    this.originLongitude = const Value.absent(),
    this.totalDistanceM = const Value.absent(),
    this.totalDurationS = const Value.absent(),
    this.optimizedAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutesCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required int version,
    required String serviceDate,
    this.status = const Value.absent(),
    this.originLatitude = const Value.absent(),
    this.originLongitude = const Value.absent(),
    this.totalDistanceM = const Value.absent(),
    this.totalDurationS = const Value.absent(),
    this.optimizedAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       version = Value(version),
       serviceDate = Value(serviceDate);
  static Insertable<Route> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? version,
    Expression<String>? serviceDate,
    Expression<String>? status,
    Expression<double>? originLatitude,
    Expression<double>? originLongitude,
    Expression<int>? totalDistanceM,
    Expression<int>? totalDurationS,
    Expression<int>? optimizedAt,
    Expression<int>? startedAt,
    Expression<int>? completedAt,
    Expression<String>? algorithm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (serviceDate != null) 'service_date': serviceDate,
      if (status != null) 'status': status,
      if (originLatitude != null) 'origin_latitude': originLatitude,
      if (originLongitude != null) 'origin_longitude': originLongitude,
      if (totalDistanceM != null) 'total_distance_m': totalDistanceM,
      if (totalDurationS != null) 'total_duration_s': totalDurationS,
      if (optimizedAt != null) 'optimized_at': optimizedAt,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (algorithm != null) 'algorithm': algorithm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? serviceDate,
    Value<RouteStatus>? status,
    Value<double?>? originLatitude,
    Value<double?>? originLongitude,
    Value<int?>? totalDistanceM,
    Value<int?>? totalDurationS,
    Value<DateTime?>? optimizedAt,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? completedAt,
    Value<String?>? algorithm,
    Value<int>? rowid,
  }) {
    return RoutesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      serviceDate: serviceDate ?? this.serviceDate,
      status: status ?? this.status,
      originLatitude: originLatitude ?? this.originLatitude,
      originLongitude: originLongitude ?? this.originLongitude,
      totalDistanceM: totalDistanceM ?? this.totalDistanceM,
      totalDurationS: totalDurationS ?? this.totalDurationS,
      optimizedAt: optimizedAt ?? this.optimizedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      algorithm: algorithm ?? this.algorithm,
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
        $RoutesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $RoutesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $RoutesTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serviceDate.present) {
      map['service_date'] = Variable<String>(serviceDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $RoutesTable.$converterstatus.toSql(status.value),
      );
    }
    if (originLatitude.present) {
      map['origin_latitude'] = Variable<double>(originLatitude.value);
    }
    if (originLongitude.present) {
      map['origin_longitude'] = Variable<double>(originLongitude.value);
    }
    if (totalDistanceM.present) {
      map['total_distance_m'] = Variable<int>(totalDistanceM.value);
    }
    if (totalDurationS.present) {
      map['total_duration_s'] = Variable<int>(totalDurationS.value);
    }
    if (optimizedAt.present) {
      map['optimized_at'] = Variable<int>(
        $RoutesTable.$converteroptimizedAtn.toSql(optimizedAt.value),
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(
        $RoutesTable.$converterstartedAtn.toSql(startedAt.value),
      );
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(
        $RoutesTable.$convertercompletedAtn.toSql(completedAt.value),
      );
    }
    if (algorithm.present) {
      map['algorithm'] = Variable<String>(algorithm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('status: $status, ')
          ..write('originLatitude: $originLatitude, ')
          ..write('originLongitude: $originLongitude, ')
          ..write('totalDistanceM: $totalDistanceM, ')
          ..write('totalDurationS: $totalDurationS, ')
          ..write('optimizedAt: $optimizedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('algorithm: $algorithm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RouteStopsTable extends RouteStops
    with TableInfo<$RouteStopsTable, RouteStop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RouteStopsTable(this.attachedDatabase, [this._alias]);
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
      ).withConverter<DateTime>($RouteStopsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($RouteStopsTable.$converterupdatedAt);
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<String> routeId = GeneratedColumn<String>(
    'route_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routes (id) ON DELETE CASCADE',
    ),
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
      'REFERENCES orders (id)',
    ),
  );
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
  static const VerificationMeta _legDistanceMMeta = const VerificationMeta(
    'legDistanceM',
  );
  @override
  late final GeneratedColumn<int> legDistanceM = GeneratedColumn<int>(
    'leg_distance_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legDurationSMeta = const VerificationMeta(
    'legDurationS',
  );
  @override
  late final GeneratedColumn<int> legDurationS = GeneratedColumn<int>(
    'leg_duration_s',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> eta =
      GeneratedColumn<int>(
        'eta',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($RouteStopsTable.$converteretan);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> arrivedAt =
      GeneratedColumn<int>(
        'arrived_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($RouteStopsTable.$converterarrivedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> departedAt =
      GeneratedColumn<int>(
        'departed_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($RouteStopsTable.$converterdepartedAtn);
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    routeId,
    orderId,
    sequence,
    legDistanceM,
    legDurationS,
    eta,
    arrivedAt,
    departedAt,
    isLocked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'route_stops';
  @override
  VerificationContext validateIntegrity(
    Insertable<RouteStop> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('leg_distance_m')) {
      context.handle(
        _legDistanceMMeta,
        legDistanceM.isAcceptableOrUnknown(
          data['leg_distance_m']!,
          _legDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('leg_duration_s')) {
      context.handle(
        _legDurationSMeta,
        legDurationS.isAcceptableOrUnknown(
          data['leg_duration_s']!,
          _legDurationSMeta,
        ),
      );
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {routeId, sequence},
  ];
  @override
  RouteStop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RouteStop(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: $RouteStopsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $RouteStopsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      legDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}leg_distance_m'],
      ),
      legDurationS: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}leg_duration_s'],
      ),
      eta: $RouteStopsTable.$converteretan.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}eta'],
        ),
      ),
      arrivedAt: $RouteStopsTable.$converterarrivedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}arrived_at'],
        ),
      ),
      departedAt: $RouteStopsTable.$converterdepartedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}departed_at'],
        ),
      ),
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
    );
  }

  @override
  $RouteStopsTable createAlias(String alias) {
    return $RouteStopsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $convertereta =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converteretan =
      NullAwareTypeConverter.wrap($convertereta);
  static TypeConverter<DateTime, int> $converterarrivedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterarrivedAtn =
      NullAwareTypeConverter.wrap($converterarrivedAt);
  static TypeConverter<DateTime, int> $converterdepartedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterdepartedAtn =
      NullAwareTypeConverter.wrap($converterdepartedAt);
}

class RouteStop extends DataClass implements Insertable<RouteStop> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String routeId;
  final String orderId;

  /// Position in the route, 1-based and unique within it.
  final int sequence;
  final int? legDistanceM;
  final int? legDurationS;

  /// Start time plus cumulative leg durations plus service time per stop
  /// (§10.1). Recomputed on every re-optimization.
  final DateTime? eta;
  final DateTime? arrivedAt;
  final DateTime? departedAt;

  /// A driver-locked stop keeps its index through re-optimization (§10.1).
  final bool isLocked;
  const RouteStop({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.routeId,
    required this.orderId,
    required this.sequence,
    this.legDistanceM,
    this.legDurationS,
    this.eta,
    this.arrivedAt,
    this.departedAt,
    required this.isLocked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['created_at'] = Variable<int>(
        $RouteStopsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $RouteStopsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    map['route_id'] = Variable<String>(routeId);
    map['order_id'] = Variable<String>(orderId);
    map['sequence'] = Variable<int>(sequence);
    if (!nullToAbsent || legDistanceM != null) {
      map['leg_distance_m'] = Variable<int>(legDistanceM);
    }
    if (!nullToAbsent || legDurationS != null) {
      map['leg_duration_s'] = Variable<int>(legDurationS);
    }
    if (!nullToAbsent || eta != null) {
      map['eta'] = Variable<int>($RouteStopsTable.$converteretan.toSql(eta));
    }
    if (!nullToAbsent || arrivedAt != null) {
      map['arrived_at'] = Variable<int>(
        $RouteStopsTable.$converterarrivedAtn.toSql(arrivedAt),
      );
    }
    if (!nullToAbsent || departedAt != null) {
      map['departed_at'] = Variable<int>(
        $RouteStopsTable.$converterdepartedAtn.toSql(departedAt),
      );
    }
    map['is_locked'] = Variable<bool>(isLocked);
    return map;
  }

  RouteStopsCompanion toCompanion(bool nullToAbsent) {
    return RouteStopsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      routeId: Value(routeId),
      orderId: Value(orderId),
      sequence: Value(sequence),
      legDistanceM: legDistanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(legDistanceM),
      legDurationS: legDurationS == null && nullToAbsent
          ? const Value.absent()
          : Value(legDurationS),
      eta: eta == null && nullToAbsent ? const Value.absent() : Value(eta),
      arrivedAt: arrivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(arrivedAt),
      departedAt: departedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(departedAt),
      isLocked: Value(isLocked),
    );
  }

  factory RouteStop.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RouteStop(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      routeId: serializer.fromJson<String>(json['routeId']),
      orderId: serializer.fromJson<String>(json['orderId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      legDistanceM: serializer.fromJson<int?>(json['legDistanceM']),
      legDurationS: serializer.fromJson<int?>(json['legDurationS']),
      eta: serializer.fromJson<DateTime?>(json['eta']),
      arrivedAt: serializer.fromJson<DateTime?>(json['arrivedAt']),
      departedAt: serializer.fromJson<DateTime?>(json['departedAt']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'routeId': serializer.toJson<String>(routeId),
      'orderId': serializer.toJson<String>(orderId),
      'sequence': serializer.toJson<int>(sequence),
      'legDistanceM': serializer.toJson<int?>(legDistanceM),
      'legDurationS': serializer.toJson<int?>(legDurationS),
      'eta': serializer.toJson<DateTime?>(eta),
      'arrivedAt': serializer.toJson<DateTime?>(arrivedAt),
      'departedAt': serializer.toJson<DateTime?>(departedAt),
      'isLocked': serializer.toJson<bool>(isLocked),
    };
  }

  RouteStop copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? routeId,
    String? orderId,
    int? sequence,
    Value<int?> legDistanceM = const Value.absent(),
    Value<int?> legDurationS = const Value.absent(),
    Value<DateTime?> eta = const Value.absent(),
    Value<DateTime?> arrivedAt = const Value.absent(),
    Value<DateTime?> departedAt = const Value.absent(),
    bool? isLocked,
  }) => RouteStop(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    routeId: routeId ?? this.routeId,
    orderId: orderId ?? this.orderId,
    sequence: sequence ?? this.sequence,
    legDistanceM: legDistanceM.present ? legDistanceM.value : this.legDistanceM,
    legDurationS: legDurationS.present ? legDurationS.value : this.legDurationS,
    eta: eta.present ? eta.value : this.eta,
    arrivedAt: arrivedAt.present ? arrivedAt.value : this.arrivedAt,
    departedAt: departedAt.present ? departedAt.value : this.departedAt,
    isLocked: isLocked ?? this.isLocked,
  );
  RouteStop copyWithCompanion(RouteStopsCompanion data) {
    return RouteStop(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      legDistanceM: data.legDistanceM.present
          ? data.legDistanceM.value
          : this.legDistanceM,
      legDurationS: data.legDurationS.present
          ? data.legDurationS.value
          : this.legDurationS,
      eta: data.eta.present ? data.eta.value : this.eta,
      arrivedAt: data.arrivedAt.present ? data.arrivedAt.value : this.arrivedAt,
      departedAt: data.departedAt.present
          ? data.departedAt.value
          : this.departedAt,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RouteStop(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('routeId: $routeId, ')
          ..write('orderId: $orderId, ')
          ..write('sequence: $sequence, ')
          ..write('legDistanceM: $legDistanceM, ')
          ..write('legDurationS: $legDurationS, ')
          ..write('eta: $eta, ')
          ..write('arrivedAt: $arrivedAt, ')
          ..write('departedAt: $departedAt, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    routeId,
    orderId,
    sequence,
    legDistanceM,
    legDurationS,
    eta,
    arrivedAt,
    departedAt,
    isLocked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteStop &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.routeId == this.routeId &&
          other.orderId == this.orderId &&
          other.sequence == this.sequence &&
          other.legDistanceM == this.legDistanceM &&
          other.legDurationS == this.legDurationS &&
          other.eta == this.eta &&
          other.arrivedAt == this.arrivedAt &&
          other.departedAt == this.departedAt &&
          other.isLocked == this.isLocked);
}

class RouteStopsCompanion extends UpdateCompanion<RouteStop> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> routeId;
  final Value<String> orderId;
  final Value<int> sequence;
  final Value<int?> legDistanceM;
  final Value<int?> legDurationS;
  final Value<DateTime?> eta;
  final Value<DateTime?> arrivedAt;
  final Value<DateTime?> departedAt;
  final Value<bool> isLocked;
  final Value<int> rowid;
  const RouteStopsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.routeId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.legDistanceM = const Value.absent(),
    this.legDurationS = const Value.absent(),
    this.eta = const Value.absent(),
    this.arrivedAt = const Value.absent(),
    this.departedAt = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RouteStopsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String routeId,
    required String orderId,
    required int sequence,
    this.legDistanceM = const Value.absent(),
    this.legDurationS = const Value.absent(),
    this.eta = const Value.absent(),
    this.arrivedAt = const Value.absent(),
    this.departedAt = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       routeId = Value(routeId),
       orderId = Value(orderId),
       sequence = Value(sequence);
  static Insertable<RouteStop> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? routeId,
    Expression<String>? orderId,
    Expression<int>? sequence,
    Expression<int>? legDistanceM,
    Expression<int>? legDurationS,
    Expression<int>? eta,
    Expression<int>? arrivedAt,
    Expression<int>? departedAt,
    Expression<bool>? isLocked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (routeId != null) 'route_id': routeId,
      if (orderId != null) 'order_id': orderId,
      if (sequence != null) 'sequence': sequence,
      if (legDistanceM != null) 'leg_distance_m': legDistanceM,
      if (legDurationS != null) 'leg_duration_s': legDurationS,
      if (eta != null) 'eta': eta,
      if (arrivedAt != null) 'arrived_at': arrivedAt,
      if (departedAt != null) 'departed_at': departedAt,
      if (isLocked != null) 'is_locked': isLocked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RouteStopsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? routeId,
    Value<String>? orderId,
    Value<int>? sequence,
    Value<int?>? legDistanceM,
    Value<int?>? legDurationS,
    Value<DateTime?>? eta,
    Value<DateTime?>? arrivedAt,
    Value<DateTime?>? departedAt,
    Value<bool>? isLocked,
    Value<int>? rowid,
  }) {
    return RouteStopsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      routeId: routeId ?? this.routeId,
      orderId: orderId ?? this.orderId,
      sequence: sequence ?? this.sequence,
      legDistanceM: legDistanceM ?? this.legDistanceM,
      legDurationS: legDurationS ?? this.legDurationS,
      eta: eta ?? this.eta,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      departedAt: departedAt ?? this.departedAt,
      isLocked: isLocked ?? this.isLocked,
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
        $RouteStopsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $RouteStopsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (routeId.present) {
      map['route_id'] = Variable<String>(routeId.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (legDistanceM.present) {
      map['leg_distance_m'] = Variable<int>(legDistanceM.value);
    }
    if (legDurationS.present) {
      map['leg_duration_s'] = Variable<int>(legDurationS.value);
    }
    if (eta.present) {
      map['eta'] = Variable<int>(
        $RouteStopsTable.$converteretan.toSql(eta.value),
      );
    }
    if (arrivedAt.present) {
      map['arrived_at'] = Variable<int>(
        $RouteStopsTable.$converterarrivedAtn.toSql(arrivedAt.value),
      );
    }
    if (departedAt.present) {
      map['departed_at'] = Variable<int>(
        $RouteStopsTable.$converterdepartedAtn.toSql(departedAt.value),
      );
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RouteStopsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('routeId: $routeId, ')
          ..write('orderId: $orderId, ')
          ..write('sequence: $sequence, ')
          ..write('legDistanceM: $legDistanceM, ')
          ..write('legDurationS: $legDurationS, ')
          ..write('eta: $eta, ')
          ..write('arrivedAt: $arrivedAt, ')
          ..write('departedAt: $departedAt, ')
          ..write('isLocked: $isLocked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatrixCacheTable extends MatrixCache
    with TableInfo<$MatrixCacheTable, MatrixCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatrixCacheTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pointHashMeta = const VerificationMeta(
    'pointHash',
  );
  @override
  late final GeneratedColumn<String> pointHash = GeneratedColumn<String>(
    'point_hash',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 64,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationsMeta = const VerificationMeta(
    'durations',
  );
  @override
  late final GeneratedColumn<String> durations = GeneratedColumn<String>(
    'durations',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distancesMeta = const VerificationMeta(
    'distances',
  );
  @override
  late final GeneratedColumn<String> distances = GeneratedColumn<String>(
    'distances',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> fetchedAt =
      GeneratedColumn<int>(
        'fetched_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($MatrixCacheTable.$converterfetchedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pointHash,
    durations,
    distances,
    provider,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matrix_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatrixCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('point_hash')) {
      context.handle(
        _pointHashMeta,
        pointHash.isAcceptableOrUnknown(data['point_hash']!, _pointHashMeta),
      );
    } else if (isInserting) {
      context.missing(_pointHashMeta);
    }
    if (data.containsKey('durations')) {
      context.handle(
        _durationsMeta,
        durations.isAcceptableOrUnknown(data['durations']!, _durationsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationsMeta);
    }
    if (data.containsKey('distances')) {
      context.handle(
        _distancesMeta,
        distances.isAcceptableOrUnknown(data['distances']!, _distancesMeta),
      );
    } else if (isInserting) {
      context.missing(_distancesMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {pointHash, provider},
  ];
  @override
  MatrixCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatrixCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pointHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}point_hash'],
      )!,
      durations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}durations'],
      )!,
      distances: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distances'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      fetchedAt: $MatrixCacheTable.$converterfetchedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}fetched_at'],
        )!,
      ),
    );
  }

  @override
  $MatrixCacheTable createAlias(String alias) {
    return $MatrixCacheTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterfetchedAt =
      const UtcMillisecondsConverter();
}

class MatrixCacheData extends DataClass implements Insertable<MatrixCacheData> {
  final String id;

  /// sha256 of the coordinate set, sorted and rounded to five decimals
  /// (§10.1). Rounding is what makes a re-optimization after one stop moves a
  /// few metres a cache hit rather than a paid request.
  final String pointHash;

  /// Raw JSON. A cache of a provider response, stored as it arrived — parsing
  /// it into a typed model would tie the cache to today's shape, and the stakes
  /// of a mismatch here are only a cache miss.
  final String durations;
  final String distances;

  /// `mapbox`, `osrm`, `haversine`. Part of the key: the same coordinates
  /// answered by a different provider are a different result.
  final String provider;
  final DateTime fetchedAt;
  const MatrixCacheData({
    required this.id,
    required this.pointHash,
    required this.durations,
    required this.distances,
    required this.provider,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['point_hash'] = Variable<String>(pointHash);
    map['durations'] = Variable<String>(durations);
    map['distances'] = Variable<String>(distances);
    map['provider'] = Variable<String>(provider);
    {
      map['fetched_at'] = Variable<int>(
        $MatrixCacheTable.$converterfetchedAt.toSql(fetchedAt),
      );
    }
    return map;
  }

  MatrixCacheCompanion toCompanion(bool nullToAbsent) {
    return MatrixCacheCompanion(
      id: Value(id),
      pointHash: Value(pointHash),
      durations: Value(durations),
      distances: Value(distances),
      provider: Value(provider),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory MatrixCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatrixCacheData(
      id: serializer.fromJson<String>(json['id']),
      pointHash: serializer.fromJson<String>(json['pointHash']),
      durations: serializer.fromJson<String>(json['durations']),
      distances: serializer.fromJson<String>(json['distances']),
      provider: serializer.fromJson<String>(json['provider']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pointHash': serializer.toJson<String>(pointHash),
      'durations': serializer.toJson<String>(durations),
      'distances': serializer.toJson<String>(distances),
      'provider': serializer.toJson<String>(provider),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  MatrixCacheData copyWith({
    String? id,
    String? pointHash,
    String? durations,
    String? distances,
    String? provider,
    DateTime? fetchedAt,
  }) => MatrixCacheData(
    id: id ?? this.id,
    pointHash: pointHash ?? this.pointHash,
    durations: durations ?? this.durations,
    distances: distances ?? this.distances,
    provider: provider ?? this.provider,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  MatrixCacheData copyWithCompanion(MatrixCacheCompanion data) {
    return MatrixCacheData(
      id: data.id.present ? data.id.value : this.id,
      pointHash: data.pointHash.present ? data.pointHash.value : this.pointHash,
      durations: data.durations.present ? data.durations.value : this.durations,
      distances: data.distances.present ? data.distances.value : this.distances,
      provider: data.provider.present ? data.provider.value : this.provider,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatrixCacheData(')
          ..write('id: $id, ')
          ..write('pointHash: $pointHash, ')
          ..write('durations: $durations, ')
          ..write('distances: $distances, ')
          ..write('provider: $provider, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pointHash, durations, distances, provider, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatrixCacheData &&
          other.id == this.id &&
          other.pointHash == this.pointHash &&
          other.durations == this.durations &&
          other.distances == this.distances &&
          other.provider == this.provider &&
          other.fetchedAt == this.fetchedAt);
}

class MatrixCacheCompanion extends UpdateCompanion<MatrixCacheData> {
  final Value<String> id;
  final Value<String> pointHash;
  final Value<String> durations;
  final Value<String> distances;
  final Value<String> provider;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const MatrixCacheCompanion({
    this.id = const Value.absent(),
    this.pointHash = const Value.absent(),
    this.durations = const Value.absent(),
    this.distances = const Value.absent(),
    this.provider = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatrixCacheCompanion.insert({
    required String id,
    required String pointHash,
    required String durations,
    required String distances,
    required String provider,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pointHash = Value(pointHash),
       durations = Value(durations),
       distances = Value(distances),
       provider = Value(provider),
       fetchedAt = Value(fetchedAt);
  static Insertable<MatrixCacheData> custom({
    Expression<String>? id,
    Expression<String>? pointHash,
    Expression<String>? durations,
    Expression<String>? distances,
    Expression<String>? provider,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pointHash != null) 'point_hash': pointHash,
      if (durations != null) 'durations': durations,
      if (distances != null) 'distances': distances,
      if (provider != null) 'provider': provider,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatrixCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? pointHash,
    Value<String>? durations,
    Value<String>? distances,
    Value<String>? provider,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return MatrixCacheCompanion(
      id: id ?? this.id,
      pointHash: pointHash ?? this.pointHash,
      durations: durations ?? this.durations,
      distances: distances ?? this.distances,
      provider: provider ?? this.provider,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pointHash.present) {
      map['point_hash'] = Variable<String>(pointHash.value);
    }
    if (durations.present) {
      map['durations'] = Variable<String>(durations.value);
    }
    if (distances.present) {
      map['distances'] = Variable<String>(distances.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(
        $MatrixCacheTable.$converterfetchedAt.toSql(fetchedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatrixCacheCompanion(')
          ..write('id: $id, ')
          ..write('pointHash: $pointHash, ')
          ..write('durations: $durations, ')
          ..write('distances: $distances, ')
          ..write('provider: $provider, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
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
      ).withConverter<DateTime>($ExpensesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ExpensesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ExpensesTable.$converterdeletedAtn);
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
  late final GeneratedColumnWithTypeConverter<ExpenseCategory, String>
  category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ExpenseCategory>($ExpensesTable.$convertercategory);
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int> amount =
      GeneratedColumn<int>(
        'amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Centimes>($ExpensesTable.$converteramount);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptPathMeta = const VerificationMeta(
    'receiptPath',
  );
  @override
  late final GeneratedColumn<String> receiptPath = GeneratedColumn<String>(
    'receipt_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    serviceDate,
    category,
    amount,
    note,
    receiptPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
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
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('receipt_path')) {
      context.handle(
        _receiptPathMeta,
        receiptPath.isAcceptableOrUnknown(
          data['receipt_path']!,
          _receiptPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $ExpensesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $ExpensesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $ExpensesTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serviceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_date'],
      )!,
      category: $ExpensesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      amount: $ExpensesTable.$converteramount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}amount'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      receiptPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_path'],
      ),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<ExpenseCategory, String> $convertercategory =
      const EnumTextConverter<ExpenseCategory>(
        ExpenseCategory.values,
        'ExpenseCategory',
      );
  static TypeConverter<Centimes, int> $converteramount =
      const CentimesConverter();
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Soft delete. Null means live.
  final DateTime? deletedAt;

  /// Incremented on every write. Starts at 1.
  final int version;

  /// `YYYY-MM-DD`. Expenses belong to a business day, not to a batch — a tank
  /// of fuel covers every company the driver worked that day.
  final String serviceDate;
  final ExpenseCategory category;
  final Centimes amount;
  final String? note;

  /// App-private path (§13).
  final String? receiptPath;
  const Expense({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.serviceDate,
    required this.category,
    required this.amount,
    this.note,
    this.receiptPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $ExpensesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $ExpensesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $ExpensesTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['version'] = Variable<int>(version);
    map['service_date'] = Variable<String>(serviceDate);
    {
      map['category'] = Variable<String>(
        $ExpensesTable.$convertercategory.toSql(category),
      );
    }
    {
      map['amount'] = Variable<int>(
        $ExpensesTable.$converteramount.toSql(amount),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || receiptPath != null) {
      map['receipt_path'] = Variable<String>(receiptPath);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      serviceDate: Value(serviceDate),
      category: Value(category),
      amount: Value(amount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      receiptPath: receiptPath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptPath),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      serviceDate: serializer.fromJson<String>(json['serviceDate']),
      category: serializer.fromJson<ExpenseCategory>(json['category']),
      amount: serializer.fromJson<Centimes>(json['amount']),
      note: serializer.fromJson<String?>(json['note']),
      receiptPath: serializer.fromJson<String?>(json['receiptPath']),
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
      'serviceDate': serializer.toJson<String>(serviceDate),
      'category': serializer.toJson<ExpenseCategory>(category),
      'amount': serializer.toJson<Centimes>(amount),
      'note': serializer.toJson<String?>(note),
      'receiptPath': serializer.toJson<String?>(receiptPath),
    };
  }

  Expense copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? serviceDate,
    ExpenseCategory? category,
    Centimes? amount,
    Value<String?> note = const Value.absent(),
    Value<String?> receiptPath = const Value.absent(),
  }) => Expense(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    serviceDate: serviceDate ?? this.serviceDate,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    note: note.present ? note.value : this.note,
    receiptPath: receiptPath.present ? receiptPath.value : this.receiptPath,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      serviceDate: data.serviceDate.present
          ? data.serviceDate.value
          : this.serviceDate,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
      receiptPath: data.receiptPath.present
          ? data.receiptPath.value
          : this.receiptPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('receiptPath: $receiptPath')
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
    serviceDate,
    category,
    amount,
    note,
    receiptPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.serviceDate == this.serviceDate &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.receiptPath == this.receiptPath);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> serviceDate;
  final Value<ExpenseCategory> category;
  final Value<Centimes> amount;
  final Value<String?> note;
  final Value<String?> receiptPath;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.serviceDate = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required int version,
    required String serviceDate,
    required ExpenseCategory category,
    required Centimes amount,
    this.note = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       version = Value(version),
       serviceDate = Value(serviceDate),
       category = Value(category),
       amount = Value(amount);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? version,
    Expression<String>? serviceDate,
    Expression<String>? category,
    Expression<int>? amount,
    Expression<String>? note,
    Expression<String>? receiptPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (serviceDate != null) 'service_date': serviceDate,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (receiptPath != null) 'receipt_path': receiptPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? serviceDate,
    Value<ExpenseCategory>? category,
    Value<Centimes>? amount,
    Value<String?>? note,
    Value<String?>? receiptPath,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      serviceDate: serviceDate ?? this.serviceDate,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      receiptPath: receiptPath ?? this.receiptPath,
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
        $ExpensesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $ExpensesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $ExpensesTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serviceDate.present) {
      map['service_date'] = Variable<String>(serviceDate.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $ExpensesTable.$convertercategory.toSql(category.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<int>(
        $ExpensesTable.$converteramount.toSql(amount.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (receiptPath.present) {
      map['receipt_path'] = Variable<String>(receiptPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailySettlementsTable extends DailySettlements
    with TableInfo<$DailySettlementsTable, DailySettlement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailySettlementsTable(this.attachedDatabase, [this._alias]);
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
      ).withConverter<DateTime>($DailySettlementsTable.$convertercreatedAt);
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
      'UNIQUE REFERENCES batches (id)',
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
  static const VerificationMeta _ordersTotalMeta = const VerificationMeta(
    'ordersTotal',
  );
  @override
  late final GeneratedColumn<int> ordersTotal = GeneratedColumn<int>(
    'orders_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordersDeliveredMeta = const VerificationMeta(
    'ordersDelivered',
  );
  @override
  late final GeneratedColumn<int> ordersDelivered = GeneratedColumn<int>(
    'orders_delivered',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordersFailedMeta = const VerificationMeta(
    'ordersFailed',
  );
  @override
  late final GeneratedColumn<int> ordersFailed = GeneratedColumn<int>(
    'orders_failed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordersPendingMeta = const VerificationMeta(
    'ordersPending',
  );
  @override
  late final GeneratedColumn<int> ordersPending = GeneratedColumn<int>(
    'orders_pending',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int>
  expectedCollection =
      GeneratedColumn<int>(
        'expected_collection',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Centimes>(
        $DailySettlementsTable.$converterexpectedCollection,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int> actualCollection =
      GeneratedColumn<int>(
        'actual_collection',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Centimes>(
        $DailySettlementsTable.$converteractualCollection,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int> companyAmount =
      GeneratedColumn<int>(
        'company_amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Centimes>($DailySettlementsTable.$convertercompanyAmount);
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int> driverGross =
      GeneratedColumn<int>(
        'driver_gross',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Centimes>($DailySettlementsTable.$converterdriverGross);
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int> expensesAllocated =
      GeneratedColumn<int>(
        'expenses_allocated',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Centimes>(
        $DailySettlementsTable.$converterexpensesAllocated,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int> driverNet =
      GeneratedColumn<int>(
        'driver_net',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Centimes>($DailySettlementsTable.$converterdriverNet);
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
  static const VerificationMeta _snapshotMeta = const VerificationMeta(
    'snapshot',
  );
  @override
  late final GeneratedColumn<String> snapshot = GeneratedColumn<String>(
    'snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 64,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> confirmedAt =
      GeneratedColumn<int>(
        'confirmed_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($DailySettlementsTable.$converterconfirmedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    batchId,
    serviceDate,
    ordersTotal,
    ordersDelivered,
    ordersFailed,
    ordersPending,
    expectedCollection,
    actualCollection,
    companyAmount,
    driverGross,
    expensesAllocated,
    driverNet,
    ruleVersion,
    snapshot,
    contentHash,
    confirmedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_settlements';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailySettlement> instance, {
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
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_batchIdMeta);
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
    if (data.containsKey('orders_total')) {
      context.handle(
        _ordersTotalMeta,
        ordersTotal.isAcceptableOrUnknown(
          data['orders_total']!,
          _ordersTotalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ordersTotalMeta);
    }
    if (data.containsKey('orders_delivered')) {
      context.handle(
        _ordersDeliveredMeta,
        ordersDelivered.isAcceptableOrUnknown(
          data['orders_delivered']!,
          _ordersDeliveredMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ordersDeliveredMeta);
    }
    if (data.containsKey('orders_failed')) {
      context.handle(
        _ordersFailedMeta,
        ordersFailed.isAcceptableOrUnknown(
          data['orders_failed']!,
          _ordersFailedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ordersFailedMeta);
    }
    if (data.containsKey('orders_pending')) {
      context.handle(
        _ordersPendingMeta,
        ordersPending.isAcceptableOrUnknown(
          data['orders_pending']!,
          _ordersPendingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ordersPendingMeta);
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
    if (data.containsKey('snapshot')) {
      context.handle(
        _snapshotMeta,
        snapshot.isAcceptableOrUnknown(data['snapshot']!, _snapshotMeta),
      );
    } else if (isInserting) {
      context.missing(_snapshotMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailySettlement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailySettlement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $DailySettlementsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      )!,
      serviceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_date'],
      )!,
      ordersTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orders_total'],
      )!,
      ordersDelivered: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orders_delivered'],
      )!,
      ordersFailed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orders_failed'],
      )!,
      ordersPending: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orders_pending'],
      )!,
      expectedCollection: $DailySettlementsTable.$converterexpectedCollection
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}expected_collection'],
            )!,
          ),
      actualCollection: $DailySettlementsTable.$converteractualCollection
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}actual_collection'],
            )!,
          ),
      companyAmount: $DailySettlementsTable.$convertercompanyAmount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}company_amount'],
        )!,
      ),
      driverGross: $DailySettlementsTable.$converterdriverGross.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}driver_gross'],
        )!,
      ),
      expensesAllocated: $DailySettlementsTable.$converterexpensesAllocated
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}expenses_allocated'],
            )!,
          ),
      driverNet: $DailySettlementsTable.$converterdriverNet.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}driver_net'],
        )!,
      ),
      ruleVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_version'],
      )!,
      snapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      confirmedAt: $DailySettlementsTable.$converterconfirmedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}confirmed_at'],
        )!,
      ),
    );
  }

  @override
  $DailySettlementsTable createAlias(String alias) {
    return $DailySettlementsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<Centimes, int> $converterexpectedCollection =
      const CentimesConverter();
  static TypeConverter<Centimes, int> $converteractualCollection =
      const CentimesConverter();
  static TypeConverter<Centimes, int> $convertercompanyAmount =
      const CentimesConverter();
  static TypeConverter<Centimes, int> $converterdriverGross =
      const CentimesConverter();
  static TypeConverter<Centimes, int> $converterexpensesAllocated =
      const CentimesConverter();
  static TypeConverter<Centimes, int> $converterdriverNet =
      const CentimesConverter();
  static TypeConverter<DateTime, int> $converterconfirmedAt =
      const UtcMillisecondsConverter();
}

class DailySettlement extends DataClass implements Insertable<DailySettlement> {
  final String id;
  final String ownerId;
  final DateTime createdAt;

  /// One settlement per batch, enforced.
  final String batchId;
  final String serviceDate;
  final int ordersTotal;
  final int ordersDelivered;
  final int ordersFailed;
  final int ordersPending;

  /// What the day should have collected.
  final Centimes expectedCollection;

  /// What it actually collected. The gap is what the driver and the agency
  /// argue about, and the reason this app exists.
  final Centimes actualCollection;
  final Centimes companyAmount;
  final Centimes driverGross;
  final Centimes expensesAllocated;
  final Centimes driverNet;

  /// The `payment_rules.rule_version` this was computed under. Business data,
  /// not an audit column.
  final int ruleVersion;

  /// The per-order breakdown, frozen as raw JSON.
  ///
  /// **Never a typed converter, for the same reason as `payment_rules.spec`
  /// and more sharply.** Freezing the snapshot is the entire point: it has to
  /// stay readable and reproducible years after the models that produced it
  /// have changed shape. If it deserializes through a live model, a refactor
  /// silently rewrites history — and this is the history a driver would take
  /// to an agency to prove they are owed money.
  final String snapshot;

  /// sha256 of the canonical JSON of [snapshot]. What makes tampering
  /// detectable and what a server compares against at V2 rather than
  /// overwriting.
  final String contentHash;
  final DateTime confirmedAt;
  const DailySettlement({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.batchId,
    required this.serviceDate,
    required this.ordersTotal,
    required this.ordersDelivered,
    required this.ordersFailed,
    required this.ordersPending,
    required this.expectedCollection,
    required this.actualCollection,
    required this.companyAmount,
    required this.driverGross,
    required this.expensesAllocated,
    required this.driverNet,
    required this.ruleVersion,
    required this.snapshot,
    required this.contentHash,
    required this.confirmedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $DailySettlementsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    map['batch_id'] = Variable<String>(batchId);
    map['service_date'] = Variable<String>(serviceDate);
    map['orders_total'] = Variable<int>(ordersTotal);
    map['orders_delivered'] = Variable<int>(ordersDelivered);
    map['orders_failed'] = Variable<int>(ordersFailed);
    map['orders_pending'] = Variable<int>(ordersPending);
    {
      map['expected_collection'] = Variable<int>(
        $DailySettlementsTable.$converterexpectedCollection.toSql(
          expectedCollection,
        ),
      );
    }
    {
      map['actual_collection'] = Variable<int>(
        $DailySettlementsTable.$converteractualCollection.toSql(
          actualCollection,
        ),
      );
    }
    {
      map['company_amount'] = Variable<int>(
        $DailySettlementsTable.$convertercompanyAmount.toSql(companyAmount),
      );
    }
    {
      map['driver_gross'] = Variable<int>(
        $DailySettlementsTable.$converterdriverGross.toSql(driverGross),
      );
    }
    {
      map['expenses_allocated'] = Variable<int>(
        $DailySettlementsTable.$converterexpensesAllocated.toSql(
          expensesAllocated,
        ),
      );
    }
    {
      map['driver_net'] = Variable<int>(
        $DailySettlementsTable.$converterdriverNet.toSql(driverNet),
      );
    }
    map['rule_version'] = Variable<int>(ruleVersion);
    map['snapshot'] = Variable<String>(snapshot);
    map['content_hash'] = Variable<String>(contentHash);
    {
      map['confirmed_at'] = Variable<int>(
        $DailySettlementsTable.$converterconfirmedAt.toSql(confirmedAt),
      );
    }
    return map;
  }

  DailySettlementsCompanion toCompanion(bool nullToAbsent) {
    return DailySettlementsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      batchId: Value(batchId),
      serviceDate: Value(serviceDate),
      ordersTotal: Value(ordersTotal),
      ordersDelivered: Value(ordersDelivered),
      ordersFailed: Value(ordersFailed),
      ordersPending: Value(ordersPending),
      expectedCollection: Value(expectedCollection),
      actualCollection: Value(actualCollection),
      companyAmount: Value(companyAmount),
      driverGross: Value(driverGross),
      expensesAllocated: Value(expensesAllocated),
      driverNet: Value(driverNet),
      ruleVersion: Value(ruleVersion),
      snapshot: Value(snapshot),
      contentHash: Value(contentHash),
      confirmedAt: Value(confirmedAt),
    );
  }

  factory DailySettlement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySettlement(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      batchId: serializer.fromJson<String>(json['batchId']),
      serviceDate: serializer.fromJson<String>(json['serviceDate']),
      ordersTotal: serializer.fromJson<int>(json['ordersTotal']),
      ordersDelivered: serializer.fromJson<int>(json['ordersDelivered']),
      ordersFailed: serializer.fromJson<int>(json['ordersFailed']),
      ordersPending: serializer.fromJson<int>(json['ordersPending']),
      expectedCollection: serializer.fromJson<Centimes>(
        json['expectedCollection'],
      ),
      actualCollection: serializer.fromJson<Centimes>(json['actualCollection']),
      companyAmount: serializer.fromJson<Centimes>(json['companyAmount']),
      driverGross: serializer.fromJson<Centimes>(json['driverGross']),
      expensesAllocated: serializer.fromJson<Centimes>(
        json['expensesAllocated'],
      ),
      driverNet: serializer.fromJson<Centimes>(json['driverNet']),
      ruleVersion: serializer.fromJson<int>(json['ruleVersion']),
      snapshot: serializer.fromJson<String>(json['snapshot']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      confirmedAt: serializer.fromJson<DateTime>(json['confirmedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'batchId': serializer.toJson<String>(batchId),
      'serviceDate': serializer.toJson<String>(serviceDate),
      'ordersTotal': serializer.toJson<int>(ordersTotal),
      'ordersDelivered': serializer.toJson<int>(ordersDelivered),
      'ordersFailed': serializer.toJson<int>(ordersFailed),
      'ordersPending': serializer.toJson<int>(ordersPending),
      'expectedCollection': serializer.toJson<Centimes>(expectedCollection),
      'actualCollection': serializer.toJson<Centimes>(actualCollection),
      'companyAmount': serializer.toJson<Centimes>(companyAmount),
      'driverGross': serializer.toJson<Centimes>(driverGross),
      'expensesAllocated': serializer.toJson<Centimes>(expensesAllocated),
      'driverNet': serializer.toJson<Centimes>(driverNet),
      'ruleVersion': serializer.toJson<int>(ruleVersion),
      'snapshot': serializer.toJson<String>(snapshot),
      'contentHash': serializer.toJson<String>(contentHash),
      'confirmedAt': serializer.toJson<DateTime>(confirmedAt),
    };
  }

  DailySettlement copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    String? batchId,
    String? serviceDate,
    int? ordersTotal,
    int? ordersDelivered,
    int? ordersFailed,
    int? ordersPending,
    Centimes? expectedCollection,
    Centimes? actualCollection,
    Centimes? companyAmount,
    Centimes? driverGross,
    Centimes? expensesAllocated,
    Centimes? driverNet,
    int? ruleVersion,
    String? snapshot,
    String? contentHash,
    DateTime? confirmedAt,
  }) => DailySettlement(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    batchId: batchId ?? this.batchId,
    serviceDate: serviceDate ?? this.serviceDate,
    ordersTotal: ordersTotal ?? this.ordersTotal,
    ordersDelivered: ordersDelivered ?? this.ordersDelivered,
    ordersFailed: ordersFailed ?? this.ordersFailed,
    ordersPending: ordersPending ?? this.ordersPending,
    expectedCollection: expectedCollection ?? this.expectedCollection,
    actualCollection: actualCollection ?? this.actualCollection,
    companyAmount: companyAmount ?? this.companyAmount,
    driverGross: driverGross ?? this.driverGross,
    expensesAllocated: expensesAllocated ?? this.expensesAllocated,
    driverNet: driverNet ?? this.driverNet,
    ruleVersion: ruleVersion ?? this.ruleVersion,
    snapshot: snapshot ?? this.snapshot,
    contentHash: contentHash ?? this.contentHash,
    confirmedAt: confirmedAt ?? this.confirmedAt,
  );
  DailySettlement copyWithCompanion(DailySettlementsCompanion data) {
    return DailySettlement(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      serviceDate: data.serviceDate.present
          ? data.serviceDate.value
          : this.serviceDate,
      ordersTotal: data.ordersTotal.present
          ? data.ordersTotal.value
          : this.ordersTotal,
      ordersDelivered: data.ordersDelivered.present
          ? data.ordersDelivered.value
          : this.ordersDelivered,
      ordersFailed: data.ordersFailed.present
          ? data.ordersFailed.value
          : this.ordersFailed,
      ordersPending: data.ordersPending.present
          ? data.ordersPending.value
          : this.ordersPending,
      expectedCollection: data.expectedCollection.present
          ? data.expectedCollection.value
          : this.expectedCollection,
      actualCollection: data.actualCollection.present
          ? data.actualCollection.value
          : this.actualCollection,
      companyAmount: data.companyAmount.present
          ? data.companyAmount.value
          : this.companyAmount,
      driverGross: data.driverGross.present
          ? data.driverGross.value
          : this.driverGross,
      expensesAllocated: data.expensesAllocated.present
          ? data.expensesAllocated.value
          : this.expensesAllocated,
      driverNet: data.driverNet.present ? data.driverNet.value : this.driverNet,
      ruleVersion: data.ruleVersion.present
          ? data.ruleVersion.value
          : this.ruleVersion,
      snapshot: data.snapshot.present ? data.snapshot.value : this.snapshot,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      confirmedAt: data.confirmedAt.present
          ? data.confirmedAt.value
          : this.confirmedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySettlement(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('batchId: $batchId, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('ordersTotal: $ordersTotal, ')
          ..write('ordersDelivered: $ordersDelivered, ')
          ..write('ordersFailed: $ordersFailed, ')
          ..write('ordersPending: $ordersPending, ')
          ..write('expectedCollection: $expectedCollection, ')
          ..write('actualCollection: $actualCollection, ')
          ..write('companyAmount: $companyAmount, ')
          ..write('driverGross: $driverGross, ')
          ..write('expensesAllocated: $expensesAllocated, ')
          ..write('driverNet: $driverNet, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('snapshot: $snapshot, ')
          ..write('contentHash: $contentHash, ')
          ..write('confirmedAt: $confirmedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    createdAt,
    batchId,
    serviceDate,
    ordersTotal,
    ordersDelivered,
    ordersFailed,
    ordersPending,
    expectedCollection,
    actualCollection,
    companyAmount,
    driverGross,
    expensesAllocated,
    driverNet,
    ruleVersion,
    snapshot,
    contentHash,
    confirmedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySettlement &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.batchId == this.batchId &&
          other.serviceDate == this.serviceDate &&
          other.ordersTotal == this.ordersTotal &&
          other.ordersDelivered == this.ordersDelivered &&
          other.ordersFailed == this.ordersFailed &&
          other.ordersPending == this.ordersPending &&
          other.expectedCollection == this.expectedCollection &&
          other.actualCollection == this.actualCollection &&
          other.companyAmount == this.companyAmount &&
          other.driverGross == this.driverGross &&
          other.expensesAllocated == this.expensesAllocated &&
          other.driverNet == this.driverNet &&
          other.ruleVersion == this.ruleVersion &&
          other.snapshot == this.snapshot &&
          other.contentHash == this.contentHash &&
          other.confirmedAt == this.confirmedAt);
}

class DailySettlementsCompanion extends UpdateCompanion<DailySettlement> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<String> batchId;
  final Value<String> serviceDate;
  final Value<int> ordersTotal;
  final Value<int> ordersDelivered;
  final Value<int> ordersFailed;
  final Value<int> ordersPending;
  final Value<Centimes> expectedCollection;
  final Value<Centimes> actualCollection;
  final Value<Centimes> companyAmount;
  final Value<Centimes> driverGross;
  final Value<Centimes> expensesAllocated;
  final Value<Centimes> driverNet;
  final Value<int> ruleVersion;
  final Value<String> snapshot;
  final Value<String> contentHash;
  final Value<DateTime> confirmedAt;
  final Value<int> rowid;
  const DailySettlementsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.batchId = const Value.absent(),
    this.serviceDate = const Value.absent(),
    this.ordersTotal = const Value.absent(),
    this.ordersDelivered = const Value.absent(),
    this.ordersFailed = const Value.absent(),
    this.ordersPending = const Value.absent(),
    this.expectedCollection = const Value.absent(),
    this.actualCollection = const Value.absent(),
    this.companyAmount = const Value.absent(),
    this.driverGross = const Value.absent(),
    this.expensesAllocated = const Value.absent(),
    this.driverNet = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.snapshot = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.confirmedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailySettlementsCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required String batchId,
    required String serviceDate,
    required int ordersTotal,
    required int ordersDelivered,
    required int ordersFailed,
    required int ordersPending,
    required Centimes expectedCollection,
    required Centimes actualCollection,
    required Centimes companyAmount,
    required Centimes driverGross,
    required Centimes expensesAllocated,
    required Centimes driverNet,
    required int ruleVersion,
    required String snapshot,
    required String contentHash,
    required DateTime confirmedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       batchId = Value(batchId),
       serviceDate = Value(serviceDate),
       ordersTotal = Value(ordersTotal),
       ordersDelivered = Value(ordersDelivered),
       ordersFailed = Value(ordersFailed),
       ordersPending = Value(ordersPending),
       expectedCollection = Value(expectedCollection),
       actualCollection = Value(actualCollection),
       companyAmount = Value(companyAmount),
       driverGross = Value(driverGross),
       expensesAllocated = Value(expensesAllocated),
       driverNet = Value(driverNet),
       ruleVersion = Value(ruleVersion),
       snapshot = Value(snapshot),
       contentHash = Value(contentHash),
       confirmedAt = Value(confirmedAt);
  static Insertable<DailySettlement> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<String>? batchId,
    Expression<String>? serviceDate,
    Expression<int>? ordersTotal,
    Expression<int>? ordersDelivered,
    Expression<int>? ordersFailed,
    Expression<int>? ordersPending,
    Expression<int>? expectedCollection,
    Expression<int>? actualCollection,
    Expression<int>? companyAmount,
    Expression<int>? driverGross,
    Expression<int>? expensesAllocated,
    Expression<int>? driverNet,
    Expression<int>? ruleVersion,
    Expression<String>? snapshot,
    Expression<String>? contentHash,
    Expression<int>? confirmedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (batchId != null) 'batch_id': batchId,
      if (serviceDate != null) 'service_date': serviceDate,
      if (ordersTotal != null) 'orders_total': ordersTotal,
      if (ordersDelivered != null) 'orders_delivered': ordersDelivered,
      if (ordersFailed != null) 'orders_failed': ordersFailed,
      if (ordersPending != null) 'orders_pending': ordersPending,
      if (expectedCollection != null) 'expected_collection': expectedCollection,
      if (actualCollection != null) 'actual_collection': actualCollection,
      if (companyAmount != null) 'company_amount': companyAmount,
      if (driverGross != null) 'driver_gross': driverGross,
      if (expensesAllocated != null) 'expenses_allocated': expensesAllocated,
      if (driverNet != null) 'driver_net': driverNet,
      if (ruleVersion != null) 'rule_version': ruleVersion,
      if (snapshot != null) 'snapshot': snapshot,
      if (contentHash != null) 'content_hash': contentHash,
      if (confirmedAt != null) 'confirmed_at': confirmedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailySettlementsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<String>? batchId,
    Value<String>? serviceDate,
    Value<int>? ordersTotal,
    Value<int>? ordersDelivered,
    Value<int>? ordersFailed,
    Value<int>? ordersPending,
    Value<Centimes>? expectedCollection,
    Value<Centimes>? actualCollection,
    Value<Centimes>? companyAmount,
    Value<Centimes>? driverGross,
    Value<Centimes>? expensesAllocated,
    Value<Centimes>? driverNet,
    Value<int>? ruleVersion,
    Value<String>? snapshot,
    Value<String>? contentHash,
    Value<DateTime>? confirmedAt,
    Value<int>? rowid,
  }) {
    return DailySettlementsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      batchId: batchId ?? this.batchId,
      serviceDate: serviceDate ?? this.serviceDate,
      ordersTotal: ordersTotal ?? this.ordersTotal,
      ordersDelivered: ordersDelivered ?? this.ordersDelivered,
      ordersFailed: ordersFailed ?? this.ordersFailed,
      ordersPending: ordersPending ?? this.ordersPending,
      expectedCollection: expectedCollection ?? this.expectedCollection,
      actualCollection: actualCollection ?? this.actualCollection,
      companyAmount: companyAmount ?? this.companyAmount,
      driverGross: driverGross ?? this.driverGross,
      expensesAllocated: expensesAllocated ?? this.expensesAllocated,
      driverNet: driverNet ?? this.driverNet,
      ruleVersion: ruleVersion ?? this.ruleVersion,
      snapshot: snapshot ?? this.snapshot,
      contentHash: contentHash ?? this.contentHash,
      confirmedAt: confirmedAt ?? this.confirmedAt,
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
        $DailySettlementsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (serviceDate.present) {
      map['service_date'] = Variable<String>(serviceDate.value);
    }
    if (ordersTotal.present) {
      map['orders_total'] = Variable<int>(ordersTotal.value);
    }
    if (ordersDelivered.present) {
      map['orders_delivered'] = Variable<int>(ordersDelivered.value);
    }
    if (ordersFailed.present) {
      map['orders_failed'] = Variable<int>(ordersFailed.value);
    }
    if (ordersPending.present) {
      map['orders_pending'] = Variable<int>(ordersPending.value);
    }
    if (expectedCollection.present) {
      map['expected_collection'] = Variable<int>(
        $DailySettlementsTable.$converterexpectedCollection.toSql(
          expectedCollection.value,
        ),
      );
    }
    if (actualCollection.present) {
      map['actual_collection'] = Variable<int>(
        $DailySettlementsTable.$converteractualCollection.toSql(
          actualCollection.value,
        ),
      );
    }
    if (companyAmount.present) {
      map['company_amount'] = Variable<int>(
        $DailySettlementsTable.$convertercompanyAmount.toSql(
          companyAmount.value,
        ),
      );
    }
    if (driverGross.present) {
      map['driver_gross'] = Variable<int>(
        $DailySettlementsTable.$converterdriverGross.toSql(driverGross.value),
      );
    }
    if (expensesAllocated.present) {
      map['expenses_allocated'] = Variable<int>(
        $DailySettlementsTable.$converterexpensesAllocated.toSql(
          expensesAllocated.value,
        ),
      );
    }
    if (driverNet.present) {
      map['driver_net'] = Variable<int>(
        $DailySettlementsTable.$converterdriverNet.toSql(driverNet.value),
      );
    }
    if (ruleVersion.present) {
      map['rule_version'] = Variable<int>(ruleVersion.value);
    }
    if (snapshot.present) {
      map['snapshot'] = Variable<String>(snapshot.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (confirmedAt.present) {
      map['confirmed_at'] = Variable<int>(
        $DailySettlementsTable.$converterconfirmedAt.toSql(confirmedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySettlementsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('batchId: $batchId, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('ordersTotal: $ordersTotal, ')
          ..write('ordersDelivered: $ordersDelivered, ')
          ..write('ordersFailed: $ordersFailed, ')
          ..write('ordersPending: $ordersPending, ')
          ..write('expectedCollection: $expectedCollection, ')
          ..write('actualCollection: $actualCollection, ')
          ..write('companyAmount: $companyAmount, ')
          ..write('driverGross: $driverGross, ')
          ..write('expensesAllocated: $expensesAllocated, ')
          ..write('driverNet: $driverNet, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('snapshot: $snapshot, ')
          ..write('contentHash: $contentHash, ')
          ..write('confirmedAt: $confirmedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettlementAdjustmentsTable extends SettlementAdjustments
    with TableInfo<$SettlementAdjustmentsTable, SettlementAdjustment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettlementAdjustmentsTable(this.attachedDatabase, [this._alias]);
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
      ).withConverter<DateTime>(
        $SettlementAdjustmentsTable.$convertercreatedAt,
      );
  static const VerificationMeta _settlementIdMeta = const VerificationMeta(
    'settlementId',
  );
  @override
  late final GeneratedColumn<String> settlementId = GeneratedColumn<String>(
    'settlement_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES daily_settlements (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int> amount =
      GeneratedColumn<int>(
        'amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Centimes>($SettlementAdjustmentsTable.$converteramount);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    settlementId,
    amount,
    reason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settlement_adjustments';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettlementAdjustment> instance, {
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
    if (data.containsKey('settlement_id')) {
      context.handle(
        _settlementIdMeta,
        settlementId.isAcceptableOrUnknown(
          data['settlement_id']!,
          _settlementIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settlementIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettlementAdjustment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettlementAdjustment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $SettlementAdjustmentsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      settlementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settlement_id'],
      )!,
      amount: $SettlementAdjustmentsTable.$converteramount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}amount'],
        )!,
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
    );
  }

  @override
  $SettlementAdjustmentsTable createAlias(String alias) {
    return $SettlementAdjustmentsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<Centimes, int> $converteramount =
      const CentimesConverter();
}

class SettlementAdjustment extends DataClass
    implements Insertable<SettlementAdjustment> {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final String settlementId;

  /// Signed. A correction can go either way, which is why [Centimes] permits
  /// negatives at all.
  final Centimes amount;
  final String reason;
  const SettlementAdjustment({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.settlementId,
    required this.amount,
    required this.reason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $SettlementAdjustmentsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    map['settlement_id'] = Variable<String>(settlementId);
    {
      map['amount'] = Variable<int>(
        $SettlementAdjustmentsTable.$converteramount.toSql(amount),
      );
    }
    map['reason'] = Variable<String>(reason);
    return map;
  }

  SettlementAdjustmentsCompanion toCompanion(bool nullToAbsent) {
    return SettlementAdjustmentsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      settlementId: Value(settlementId),
      amount: Value(amount),
      reason: Value(reason),
    );
  }

  factory SettlementAdjustment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettlementAdjustment(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      settlementId: serializer.fromJson<String>(json['settlementId']),
      amount: serializer.fromJson<Centimes>(json['amount']),
      reason: serializer.fromJson<String>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'settlementId': serializer.toJson<String>(settlementId),
      'amount': serializer.toJson<Centimes>(amount),
      'reason': serializer.toJson<String>(reason),
    };
  }

  SettlementAdjustment copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    String? settlementId,
    Centimes? amount,
    String? reason,
  }) => SettlementAdjustment(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    settlementId: settlementId ?? this.settlementId,
    amount: amount ?? this.amount,
    reason: reason ?? this.reason,
  );
  SettlementAdjustment copyWithCompanion(SettlementAdjustmentsCompanion data) {
    return SettlementAdjustment(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      settlementId: data.settlementId.present
          ? data.settlementId.value
          : this.settlementId,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettlementAdjustment(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('settlementId: $settlementId, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ownerId, createdAt, settlementId, amount, reason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettlementAdjustment &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.settlementId == this.settlementId &&
          other.amount == this.amount &&
          other.reason == this.reason);
}

class SettlementAdjustmentsCompanion
    extends UpdateCompanion<SettlementAdjustment> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<String> settlementId;
  final Value<Centimes> amount;
  final Value<String> reason;
  final Value<int> rowid;
  const SettlementAdjustmentsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.settlementId = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettlementAdjustmentsCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required String settlementId,
    required Centimes amount,
    required String reason,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       settlementId = Value(settlementId),
       amount = Value(amount),
       reason = Value(reason);
  static Insertable<SettlementAdjustment> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<String>? settlementId,
    Expression<int>? amount,
    Expression<String>? reason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (settlementId != null) 'settlement_id': settlementId,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettlementAdjustmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<String>? settlementId,
    Value<Centimes>? amount,
    Value<String>? reason,
    Value<int>? rowid,
  }) {
    return SettlementAdjustmentsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      settlementId: settlementId ?? this.settlementId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
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
        $SettlementAdjustmentsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (settlementId.present) {
      map['settlement_id'] = Variable<String>(settlementId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(
        $SettlementAdjustmentsTable.$converteramount.toSql(amount.value),
      );
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettlementAdjustmentsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('settlementId: $settlementId, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemittancesTable extends Remittances
    with TableInfo<$RemittancesTable, Remittance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemittancesTable(this.attachedDatabase, [this._alias]);
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
      ).withConverter<DateTime>($RemittancesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($RemittancesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($RemittancesTable.$converterdeletedAtn);
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
  @override
  late final GeneratedColumnWithTypeConverter<Centimes, int> amount =
      GeneratedColumn<int>(
        'amount',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Centimes>($RemittancesTable.$converteramount);
  @override
  late final GeneratedColumnWithTypeConverter<RemittanceMethod, String> method =
      GeneratedColumn<String>(
        'method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RemittanceMethod>($RemittancesTable.$convertermethod);
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptPathMeta = const VerificationMeta(
    'receiptPath',
  );
  @override
  late final GeneratedColumn<String> receiptPath = GeneratedColumn<String>(
    'receipt_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coversFromMeta = const VerificationMeta(
    'coversFrom',
  );
  @override
  late final GeneratedColumn<String> coversFrom = GeneratedColumn<String>(
    'covers_from',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coversToMeta = const VerificationMeta(
    'coversTo',
  );
  @override
  late final GeneratedColumn<String> coversTo = GeneratedColumn<String>(
    'covers_to',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> remittedAt =
      GeneratedColumn<int>(
        'remitted_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($RemittancesTable.$converterremittedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    updatedAt,
    deletedAt,
    version,
    companyId,
    amount,
    method,
    reference,
    receiptPath,
    coversFrom,
    coversTo,
    remittedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remittances';
  @override
  VerificationContext validateIntegrity(
    Insertable<Remittance> instance, {
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
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('receipt_path')) {
      context.handle(
        _receiptPathMeta,
        receiptPath.isAcceptableOrUnknown(
          data['receipt_path']!,
          _receiptPathMeta,
        ),
      );
    }
    if (data.containsKey('covers_from')) {
      context.handle(
        _coversFromMeta,
        coversFrom.isAcceptableOrUnknown(data['covers_from']!, _coversFromMeta),
      );
    }
    if (data.containsKey('covers_to')) {
      context.handle(
        _coversToMeta,
        coversTo.isAcceptableOrUnknown(data['covers_to']!, _coversToMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Remittance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Remittance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $RemittancesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $RemittancesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $RemittancesTable.$converterdeletedAtn.fromSql(
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
      amount: $RemittancesTable.$converteramount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}amount'],
        )!,
      ),
      method: $RemittancesTable.$convertermethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}method'],
        )!,
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      receiptPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_path'],
      ),
      coversFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}covers_from'],
      ),
      coversTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}covers_to'],
      ),
      remittedAt: $RemittancesTable.$converterremittedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}remitted_at'],
        )!,
      ),
    );
  }

  @override
  $RemittancesTable createAlias(String alias) {
    return $RemittancesTable(attachedDatabase, alias);
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
  static TypeConverter<RemittanceMethod, String> $convertermethod =
      const EnumTextConverter<RemittanceMethod>(
        RemittanceMethod.values,
        'RemittanceMethod',
      );
  static TypeConverter<DateTime, int> $converterremittedAt =
      const UtcMillisecondsConverter();
}

class Remittance extends DataClass implements Insertable<Remittance> {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Soft delete. Null means live.
  final DateTime? deletedAt;

  /// Incremented on every write. Starts at 1.
  final int version;
  final String companyId;
  final Centimes amount;
  final RemittanceMethod method;

  /// Transfer reference or receipt number, as written on the paper.
  final String? reference;
  final String? receiptPath;

  /// The span of business days this payment covers. Nullable because a driver
  /// often hands over a round number without attributing it to specific days.
  final String? coversFrom;
  final String? coversTo;
  final DateTime remittedAt;
  const Remittance({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    required this.companyId,
    required this.amount,
    required this.method,
    this.reference,
    this.receiptPath,
    this.coversFrom,
    this.coversTo,
    required this.remittedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $RemittancesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $RemittancesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $RemittancesTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    map['version'] = Variable<int>(version);
    map['company_id'] = Variable<String>(companyId);
    {
      map['amount'] = Variable<int>(
        $RemittancesTable.$converteramount.toSql(amount),
      );
    }
    {
      map['method'] = Variable<String>(
        $RemittancesTable.$convertermethod.toSql(method),
      );
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || receiptPath != null) {
      map['receipt_path'] = Variable<String>(receiptPath);
    }
    if (!nullToAbsent || coversFrom != null) {
      map['covers_from'] = Variable<String>(coversFrom);
    }
    if (!nullToAbsent || coversTo != null) {
      map['covers_to'] = Variable<String>(coversTo);
    }
    {
      map['remitted_at'] = Variable<int>(
        $RemittancesTable.$converterremittedAt.toSql(remittedAt),
      );
    }
    return map;
  }

  RemittancesCompanion toCompanion(bool nullToAbsent) {
    return RemittancesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      companyId: Value(companyId),
      amount: Value(amount),
      method: Value(method),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      receiptPath: receiptPath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptPath),
      coversFrom: coversFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(coversFrom),
      coversTo: coversTo == null && nullToAbsent
          ? const Value.absent()
          : Value(coversTo),
      remittedAt: Value(remittedAt),
    );
  }

  factory Remittance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Remittance(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      companyId: serializer.fromJson<String>(json['companyId']),
      amount: serializer.fromJson<Centimes>(json['amount']),
      method: serializer.fromJson<RemittanceMethod>(json['method']),
      reference: serializer.fromJson<String?>(json['reference']),
      receiptPath: serializer.fromJson<String?>(json['receiptPath']),
      coversFrom: serializer.fromJson<String?>(json['coversFrom']),
      coversTo: serializer.fromJson<String?>(json['coversTo']),
      remittedAt: serializer.fromJson<DateTime>(json['remittedAt']),
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
      'amount': serializer.toJson<Centimes>(amount),
      'method': serializer.toJson<RemittanceMethod>(method),
      'reference': serializer.toJson<String?>(reference),
      'receiptPath': serializer.toJson<String?>(receiptPath),
      'coversFrom': serializer.toJson<String?>(coversFrom),
      'coversTo': serializer.toJson<String?>(coversTo),
      'remittedAt': serializer.toJson<DateTime>(remittedAt),
    };
  }

  Remittance copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    String? companyId,
    Centimes? amount,
    RemittanceMethod? method,
    Value<String?> reference = const Value.absent(),
    Value<String?> receiptPath = const Value.absent(),
    Value<String?> coversFrom = const Value.absent(),
    Value<String?> coversTo = const Value.absent(),
    DateTime? remittedAt,
  }) => Remittance(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    companyId: companyId ?? this.companyId,
    amount: amount ?? this.amount,
    method: method ?? this.method,
    reference: reference.present ? reference.value : this.reference,
    receiptPath: receiptPath.present ? receiptPath.value : this.receiptPath,
    coversFrom: coversFrom.present ? coversFrom.value : this.coversFrom,
    coversTo: coversTo.present ? coversTo.value : this.coversTo,
    remittedAt: remittedAt ?? this.remittedAt,
  );
  Remittance copyWithCompanion(RemittancesCompanion data) {
    return Remittance(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      amount: data.amount.present ? data.amount.value : this.amount,
      method: data.method.present ? data.method.value : this.method,
      reference: data.reference.present ? data.reference.value : this.reference,
      receiptPath: data.receiptPath.present
          ? data.receiptPath.value
          : this.receiptPath,
      coversFrom: data.coversFrom.present
          ? data.coversFrom.value
          : this.coversFrom,
      coversTo: data.coversTo.present ? data.coversTo.value : this.coversTo,
      remittedAt: data.remittedAt.present
          ? data.remittedAt.value
          : this.remittedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Remittance(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('companyId: $companyId, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('reference: $reference, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('coversFrom: $coversFrom, ')
          ..write('coversTo: $coversTo, ')
          ..write('remittedAt: $remittedAt')
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
    amount,
    method,
    reference,
    receiptPath,
    coversFrom,
    coversTo,
    remittedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Remittance &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.companyId == this.companyId &&
          other.amount == this.amount &&
          other.method == this.method &&
          other.reference == this.reference &&
          other.receiptPath == this.receiptPath &&
          other.coversFrom == this.coversFrom &&
          other.coversTo == this.coversTo &&
          other.remittedAt == this.remittedAt);
}

class RemittancesCompanion extends UpdateCompanion<Remittance> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String> companyId;
  final Value<Centimes> amount;
  final Value<RemittanceMethod> method;
  final Value<String?> reference;
  final Value<String?> receiptPath;
  final Value<String?> coversFrom;
  final Value<String?> coversTo;
  final Value<DateTime> remittedAt;
  final Value<int> rowid;
  const RemittancesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.companyId = const Value.absent(),
    this.amount = const Value.absent(),
    this.method = const Value.absent(),
    this.reference = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.coversFrom = const Value.absent(),
    this.coversTo = const Value.absent(),
    this.remittedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemittancesCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required int version,
    required String companyId,
    required Centimes amount,
    required RemittanceMethod method,
    this.reference = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.coversFrom = const Value.absent(),
    this.coversTo = const Value.absent(),
    required DateTime remittedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       version = Value(version),
       companyId = Value(companyId),
       amount = Value(amount),
       method = Value(method),
       remittedAt = Value(remittedAt);
  static Insertable<Remittance> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? version,
    Expression<String>? companyId,
    Expression<int>? amount,
    Expression<String>? method,
    Expression<String>? reference,
    Expression<String>? receiptPath,
    Expression<String>? coversFrom,
    Expression<String>? coversTo,
    Expression<int>? remittedAt,
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
      if (amount != null) 'amount': amount,
      if (method != null) 'method': method,
      if (reference != null) 'reference': reference,
      if (receiptPath != null) 'receipt_path': receiptPath,
      if (coversFrom != null) 'covers_from': coversFrom,
      if (coversTo != null) 'covers_to': coversTo,
      if (remittedAt != null) 'remitted_at': remittedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemittancesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String>? companyId,
    Value<Centimes>? amount,
    Value<RemittanceMethod>? method,
    Value<String?>? reference,
    Value<String?>? receiptPath,
    Value<String?>? coversFrom,
    Value<String?>? coversTo,
    Value<DateTime>? remittedAt,
    Value<int>? rowid,
  }) {
    return RemittancesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      companyId: companyId ?? this.companyId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      reference: reference ?? this.reference,
      receiptPath: receiptPath ?? this.receiptPath,
      coversFrom: coversFrom ?? this.coversFrom,
      coversTo: coversTo ?? this.coversTo,
      remittedAt: remittedAt ?? this.remittedAt,
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
        $RemittancesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $RemittancesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $RemittancesTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(
        $RemittancesTable.$converteramount.toSql(amount.value),
      );
    }
    if (method.present) {
      map['method'] = Variable<String>(
        $RemittancesTable.$convertermethod.toSql(method.value),
      );
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (receiptPath.present) {
      map['receipt_path'] = Variable<String>(receiptPath.value);
    }
    if (coversFrom.present) {
      map['covers_from'] = Variable<String>(coversFrom.value);
    }
    if (coversTo.present) {
      map['covers_to'] = Variable<String>(coversTo.value);
    }
    if (remittedAt.present) {
      map['remitted_at'] = Variable<int>(
        $RemittancesTable.$converterremittedAt.toSql(remittedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemittancesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('companyId: $companyId, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('reference: $reference, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('coversFrom: $coversFrom, ')
          ..write('coversTo: $coversTo, ')
          ..write('remittedAt: $remittedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
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
  late final GeneratedColumnWithTypeConverter<OutboxOperation, String>
  operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<OutboxOperation>($OutboxTable.$converteroperation);
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
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
      ).withConverter<DateTime>($OutboxTable.$convertercreatedAt);
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> syncedAt =
      GeneratedColumn<int>(
        'synced_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($OutboxTable.$convertersyncedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    payload,
    deviceId,
    createdAt,
    attempts,
    lastError,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: $OutboxTable.$converteroperation.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}operation'],
        )!,
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: $OutboxTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      syncedAt: $OutboxTable.$convertersyncedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}synced_at'],
        ),
      ),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }

  static TypeConverter<OutboxOperation, String> $converteroperation =
      const EnumTextConverter<OutboxOperation>(
        OutboxOperation.values,
        'OutboxOperation',
      );
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $convertersyncedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime?, int?> $convertersyncedAtn =
      NullAwareTypeConverter.wrap($convertersyncedAt);
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final String id;
  final String entityType;
  final String entityId;

  /// **Commands, not state diffs** (§11.2). `order.deliver { collected, at }`
  /// replays correctly whatever else changed; `{ status: 'delivered' }` does
  /// not, because it silently overwrites what another device did.
  final OutboxOperation operation;

  /// Raw JSON. Whatever the command carried, kept exactly as recorded — this
  /// is replayed verbatim, so parsing it through a live model would let a
  /// refactor change what a queued write means.
  final String payload;

  /// Persisted at first launch (§11.5). Distinguishes two devices belonging to
  /// the same driver, which is the case the idempotency key has to survive.
  final String deviceId;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  /// Null until the row has been accepted by a server. Non-null rows are
  /// eligible for trimming.
  final DateTime? syncedAt;
  const OutboxData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.deviceId,
    required this.createdAt,
    required this.attempts,
    this.lastError,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    {
      map['operation'] = Variable<String>(
        $OutboxTable.$converteroperation.toSql(operation),
      );
    }
    map['payload'] = Variable<String>(payload);
    map['device_id'] = Variable<String>(deviceId);
    {
      map['created_at'] = Variable<int>(
        $OutboxTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<int>(
        $OutboxTable.$convertersyncedAtn.toSql(syncedAt),
      );
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory OutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<OutboxOperation>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<OutboxOperation>(operation),
      'payload': serializer.toJson<String>(payload),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  OutboxData copyWith({
    String? id,
    String? entityType,
    String? entityId,
    OutboxOperation? operation,
    String? payload,
    String? deviceId,
    DateTime? createdAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => OutboxData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    deviceId: deviceId ?? this.deviceId,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    payload,
    deviceId,
    createdAt,
    attempts,
    lastError,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.syncedAt == this.syncedAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<OutboxOperation> operation;
  final Value<String> payload;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required OutboxOperation operation,
    required String payload,
    required String deviceId,
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payload = Value(payload),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt);
  static Insertable<OutboxData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<String>? deviceId,
    Expression<int>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<OutboxOperation>? operation,
    Value<String>? payload,
    Value<String>? deviceId,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return OutboxCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(
        $OutboxTable.$converteroperation.toSql(operation.value),
      );
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $OutboxTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(
        $OutboxTable.$convertersyncedAtn.toSql(syncedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
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
      ).withConverter<DateTime>($AuditLogsTable.$convertercreatedAt);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 36,
      maxTextLength: 36,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beforeMeta = const VerificationMeta('before');
  @override
  late final GeneratedColumn<String> before = GeneratedColumn<String>(
    'before',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterMeta = const VerificationMeta('after');
  @override
  late final GeneratedColumn<String> after = GeneratedColumn<String>(
    'after',
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
      ).withConverter<DateTime>($AuditLogsTable.$converteroccurredAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    createdAt,
    entityType,
    entityId,
    action,
    before,
    after,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
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
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('before')) {
      context.handle(
        _beforeMeta,
        before.isAcceptableOrUnknown(data['before']!, _beforeMeta),
      );
    }
    if (data.containsKey('after')) {
      context.handle(
        _afterMeta,
        after.isAcceptableOrUnknown(data['after']!, _afterMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      createdAt: $AuditLogsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      before: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before'],
      ),
      after: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after'],
      ),
      occurredAt: $AuditLogsTable.$converteroccurredAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}occurred_at'],
        )!,
      ),
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisecondsConverter();
  static TypeConverter<DateTime, int> $converteroccurredAt =
      const UtcMillisecondsConverter();
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final String entityType;
  final String entityId;

  /// What happened: `remittance.amend`, `pin.demote`, `order.deliver`.
  final String action;

  /// Raw JSON, both of them, and nullable — a creation has no before, a
  /// deletion has no after. Stored as recorded so an audit entry stays
  /// readable after the model that produced it has changed.
  final String? before;
  final String? after;

  /// When the change happened, as distinct from when the row was written.
  final DateTime occurredAt;
  const AuditLog({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.before,
    this.after,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['created_at'] = Variable<int>(
        $AuditLogsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || before != null) {
      map['before'] = Variable<String>(before);
    }
    if (!nullToAbsent || after != null) {
      map['after'] = Variable<String>(after);
    }
    {
      map['occurred_at'] = Variable<int>(
        $AuditLogsTable.$converteroccurredAt.toSql(occurredAt),
      );
    }
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      createdAt: Value(createdAt),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      before: before == null && nullToAbsent
          ? const Value.absent()
          : Value(before),
      after: after == null && nullToAbsent
          ? const Value.absent()
          : Value(after),
      occurredAt: Value(occurredAt),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      before: serializer.fromJson<String?>(json['before']),
      after: serializer.fromJson<String?>(json['after']),
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
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'before': serializer.toJson<String?>(before),
      'after': serializer.toJson<String?>(after),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  AuditLog copyWith({
    String? id,
    String? ownerId,
    DateTime? createdAt,
    String? entityType,
    String? entityId,
    String? action,
    Value<String?> before = const Value.absent(),
    Value<String?> after = const Value.absent(),
    DateTime? occurredAt,
  }) => AuditLog(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    createdAt: createdAt ?? this.createdAt,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    before: before.present ? before.value : this.before,
    after: after.present ? after.value : this.after,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      before: data.before.present ? data.before.value : this.before,
      after: data.after.present ? data.after.value : this.after,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('before: $before, ')
          ..write('after: $after, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    createdAt,
    entityType,
    entityId,
    action,
    before,
    after,
    occurredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.before == this.before &&
          other.after == this.after &&
          other.occurredAt == this.occurredAt);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<DateTime> createdAt;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String?> before;
  final Value<String?> after;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.before = const Value.absent(),
    this.after = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    required String ownerId,
    required DateTime createdAt,
    required String entityType,
    required String entityId,
    required String action,
    this.before = const Value.absent(),
    this.after = const Value.absent(),
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       createdAt = Value(createdAt),
       entityType = Value(entityType),
       entityId = Value(entityId),
       action = Value(action),
       occurredAt = Value(occurredAt);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<int>? createdAt,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? before,
    Expression<String>? after,
    Expression<int>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (before != null) 'before': before,
      if (after != null) 'after': after,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<DateTime>? createdAt,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? action,
    Value<String?>? before,
    Value<String?>? after,
    Value<DateTime>? occurredAt,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      before: before ?? this.before,
      after: after ?? this.after,
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
        $AuditLogsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (before.present) {
      map['before'] = Variable<String>(before.value);
    }
    if (after.present) {
      map['after'] = Variable<String>(after.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(
        $AuditLogsTable.$converteroccurredAt.toSql(occurredAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('before: $before, ')
          ..write('after: $after, ')
          ..write('occurredAt: $occurredAt, ')
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
  late final $RoutesTable routes = $RoutesTable(this);
  late final $RouteStopsTable routeStops = $RouteStopsTable(this);
  late final $MatrixCacheTable matrixCache = $MatrixCacheTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $DailySettlementsTable dailySettlements = $DailySettlementsTable(
    this,
  );
  late final $SettlementAdjustmentsTable settlementAdjustments =
      $SettlementAdjustmentsTable(this);
  late final $RemittancesTable remittances = $RemittancesTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final Index idxCustomersOwnerPhone = Index(
    'idx_customers_owner_phone',
    'CREATE UNIQUE INDEX idx_customers_owner_phone ON customers (owner_id, phone_e164) WHERE deleted_at IS NULL',
  );
  late final Index idxAddrCommune = Index(
    'idx_addr_commune',
    'CREATE INDEX idx_addr_commune ON customer_addresses (commune_id)',
  );
  late final Index idxBatchesOwnerDate = Index(
    'idx_batches_owner_date',
    'CREATE INDEX idx_batches_owner_date ON batches (owner_id, service_date DESC)',
  );
  late final Index idxOrdersOwnerStatus = Index(
    'idx_orders_owner_status',
    'CREATE INDEX idx_orders_owner_status ON orders (owner_id, status) WHERE deleted_at IS NULL',
  );
  late final Index idxOrdersBatch = Index(
    'idx_orders_batch',
    'CREATE INDEX idx_orders_batch ON orders (batch_id) WHERE deleted_at IS NULL',
  );
  late final Index idxOrdersTracking = Index(
    'idx_orders_tracking',
    'CREATE INDEX idx_orders_tracking ON orders (owner_id, tracking_number)',
  );
  late final Index idxExpensesOwnerDate = Index(
    'idx_expenses_owner_date',
    'CREATE INDEX idx_expenses_owner_date ON expenses (owner_id, service_date DESC)',
  );
  late final Index idxSettlementsOwnerDate = Index(
    'idx_settlements_owner_date',
    'CREATE INDEX idx_settlements_owner_date ON daily_settlements (owner_id, service_date DESC)',
  );
  late final Index idxRemitOwnerCompany = Index(
    'idx_remit_owner_company',
    'CREATE INDEX idx_remit_owner_company ON remittances (owner_id, company_id, remitted_at DESC)',
  );
  late final Index idxOutboxPending = Index(
    'idx_outbox_pending',
    'CREATE INDEX idx_outbox_pending ON outbox (created_at) WHERE synced_at IS NULL',
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
    routes,
    routeStops,
    matrixCache,
    expenses,
    dailySettlements,
    settlementAdjustments,
    remittances,
    outbox,
    auditLogs,
    idxCustomersOwnerPhone,
    idxAddrCommune,
    idxBatchesOwnerDate,
    idxOrdersOwnerStatus,
    idxOrdersBatch,
    idxOrdersTracking,
    idxExpensesOwnerDate,
    idxSettlementsOwnerDate,
    idxRemitOwnerCompany,
    idxOutboxPending,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('route_stops', kind: UpdateKind.delete)],
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
      Value<String?> displayName,
      Value<String?> locale,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<PhoneE164?> phone,
      Value<String?> displayName,
      Value<String?> locale,
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

  static MultiTypedResultKey<$RoutesTable, List<Route>> _routesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.routes,
    aliasName: 'users__id__routes__owner_id',
  );

  $$RoutesTableProcessedTableManager get routesRefs {
    final manager = $$RoutesTableTableManager(
      $_db,
      $_db.routes,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'users__id__expenses__owner_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DailySettlementsTable, List<DailySettlement>>
  _dailySettlementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailySettlements,
    aliasName: 'users__id__daily_settlements__owner_id',
  );

  $$DailySettlementsTableProcessedTableManager get dailySettlementsRefs {
    final manager = $$DailySettlementsTableTableManager(
      $_db,
      $_db.dailySettlements,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dailySettlementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SettlementAdjustmentsTable,
    List<SettlementAdjustment>
  >
  _settlementAdjustmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.settlementAdjustments,
        aliasName: 'users__id__settlement_adjustments__owner_id',
      );

  $$SettlementAdjustmentsTableProcessedTableManager
  get settlementAdjustmentsRefs {
    final manager = $$SettlementAdjustmentsTableTableManager(
      $_db,
      $_db.settlementAdjustments,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _settlementAdjustmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemittancesTable, List<Remittance>>
  _remittancesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.remittances,
    aliasName: 'users__id__remittances__owner_id',
  );

  $$RemittancesTableProcessedTableManager get remittancesRefs {
    final manager = $$RemittancesTableTableManager(
      $_db,
      $_db.remittances,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remittancesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AuditLogsTable, List<AuditLog>>
  _auditLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.auditLogs,
    aliasName: 'users__id__audit_logs__owner_id',
  );

  $$AuditLogsTableProcessedTableManager get auditLogsRefs {
    final manager = $$AuditLogsTableTableManager(
      $_db,
      $_db.auditLogs,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_auditLogsRefsTable($_db));
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

  Expression<bool> routesRefs(
    Expression<bool> Function($$RoutesTableFilterComposer f) f,
  ) {
    final $$RoutesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableFilterComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dailySettlementsRefs(
    Expression<bool> Function($$DailySettlementsTableFilterComposer f) f,
  ) {
    final $$DailySettlementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailySettlements,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailySettlementsTableFilterComposer(
            $db: $db,
            $table: $db.dailySettlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> settlementAdjustmentsRefs(
    Expression<bool> Function($$SettlementAdjustmentsTableFilterComposer f) f,
  ) {
    final $$SettlementAdjustmentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.settlementAdjustments,
          getReferencedColumn: (t) => t.ownerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SettlementAdjustmentsTableFilterComposer(
                $db: $db,
                $table: $db.settlementAdjustments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> remittancesRefs(
    Expression<bool> Function($$RemittancesTableFilterComposer f) f,
  ) {
    final $$RemittancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.remittances,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemittancesTableFilterComposer(
            $db: $db,
            $table: $db.remittances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> auditLogsRefs(
    Expression<bool> Function($$AuditLogsTableFilterComposer f) f,
  ) {
    final $$AuditLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.auditLogs,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditLogsTableFilterComposer(
            $db: $db,
            $table: $db.auditLogs,
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

  Expression<T> routesRefs<T extends Object>(
    Expression<T> Function($$RoutesTableAnnotationComposer a) f,
  ) {
    final $$RoutesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableAnnotationComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dailySettlementsRefs<T extends Object>(
    Expression<T> Function($$DailySettlementsTableAnnotationComposer a) f,
  ) {
    final $$DailySettlementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailySettlements,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailySettlementsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailySettlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> settlementAdjustmentsRefs<T extends Object>(
    Expression<T> Function($$SettlementAdjustmentsTableAnnotationComposer a) f,
  ) {
    final $$SettlementAdjustmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.settlementAdjustments,
          getReferencedColumn: (t) => t.ownerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SettlementAdjustmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.settlementAdjustments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> remittancesRefs<T extends Object>(
    Expression<T> Function($$RemittancesTableAnnotationComposer a) f,
  ) {
    final $$RemittancesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.remittances,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemittancesTableAnnotationComposer(
            $db: $db,
            $table: $db.remittances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> auditLogsRefs<T extends Object>(
    Expression<T> Function($$AuditLogsTableAnnotationComposer a) f,
  ) {
    final $$AuditLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.auditLogs,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.auditLogs,
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
            bool routesRefs,
            bool expensesRefs,
            bool dailySettlementsRefs,
            bool settlementAdjustmentsRefs,
            bool remittancesRefs,
            bool auditLogsRefs,
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
                Value<String?> displayName = const Value.absent(),
                Value<String?> locale = const Value.absent(),
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
                Value<String?> displayName = const Value.absent(),
                Value<String?> locale = const Value.absent(),
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
                routesRefs = false,
                expensesRefs = false,
                dailySettlementsRefs = false,
                settlementAdjustmentsRefs = false,
                remittancesRefs = false,
                auditLogsRefs = false,
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
                    if (routesRefs) db.routes,
                    if (expensesRefs) db.expenses,
                    if (dailySettlementsRefs) db.dailySettlements,
                    if (settlementAdjustmentsRefs) db.settlementAdjustments,
                    if (remittancesRefs) db.remittances,
                    if (auditLogsRefs) db.auditLogs,
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
                      if (routesRefs)
                        await $_getPrefetchedData<User, $UsersTable, Route>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._routesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(db, table, p0).routesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedData<User, $UsersTable, Expense>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dailySettlementsRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          DailySettlement
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._dailySettlementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).dailySettlementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (settlementAdjustmentsRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          SettlementAdjustment
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._settlementAdjustmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).settlementAdjustmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (remittancesRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          Remittance
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._remittancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).remittancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ownerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (auditLogsRefs)
                        await $_getPrefetchedData<User, $UsersTable, AuditLog>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._auditLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).auditLogsRefs,
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
        bool routesRefs,
        bool expensesRefs,
        bool dailySettlementsRefs,
        bool settlementAdjustmentsRefs,
        bool remittancesRefs,
        bool auditLogsRefs,
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

  static MultiTypedResultKey<$RemittancesTable, List<Remittance>>
  _remittancesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.remittances,
    aliasName: 'companies__id__remittances__company_id',
  );

  $$RemittancesTableProcessedTableManager get remittancesRefs {
    final manager = $$RemittancesTableTableManager(
      $_db,
      $_db.remittances,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remittancesRefsTable($_db));
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

  Expression<bool> remittancesRefs(
    Expression<bool> Function($$RemittancesTableFilterComposer f) f,
  ) {
    final $$RemittancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.remittances,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemittancesTableFilterComposer(
            $db: $db,
            $table: $db.remittances,
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

  Expression<T> remittancesRefs<T extends Object>(
    Expression<T> Function($$RemittancesTableAnnotationComposer a) f,
  ) {
    final $$RemittancesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.remittances,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemittancesTableAnnotationComposer(
            $db: $db,
            $table: $db.remittances,
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
            bool remittancesRefs,
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
                remittancesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentRulesRefs) db.paymentRules,
                    if (batchesRefs) db.batches,
                    if (ordersRefs) db.orders,
                    if (remittancesRefs) db.remittances,
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
                      if (remittancesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Remittance
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._remittancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).remittancesRefs,
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
        bool remittancesRefs,
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
      Value<bool> isRetired,
    });
typedef $$WilayasTableUpdateCompanionBuilder =
    WilayasCompanion Function({
      Value<int> code,
      Value<String> nameFr,
      Value<String> nameAr,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> geohash,
      Value<bool> isRetired,
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

  ColumnFilters<bool> get isRetired => $composableBuilder(
    column: $table.isRetired,
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

  ColumnOrderings<bool> get isRetired => $composableBuilder(
    column: $table.isRetired,
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

  GeneratedColumn<bool> get isRetired =>
      $composableBuilder(column: $table.isRetired, builder: (column) => column);

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
                Value<bool> isRetired = const Value.absent(),
              }) => WilayasCompanion(
                code: code,
                nameFr: nameFr,
                nameAr: nameAr,
                latitude: latitude,
                longitude: longitude,
                geohash: geohash,
                isRetired: isRetired,
              ),
          createCompanionCallback:
              ({
                Value<int> code = const Value.absent(),
                required String nameFr,
                required String nameAr,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> geohash = const Value.absent(),
                Value<bool> isRetired = const Value.absent(),
              }) => WilayasCompanion.insert(
                code: code,
                nameFr: nameFr,
                nameAr: nameAr,
                latitude: latitude,
                longitude: longitude,
                geohash: geohash,
                isRetired: isRetired,
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
      Value<bool> isRetired,
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
      Value<bool> isRetired,
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

  ColumnFilters<bool> get isRetired => $composableBuilder(
    column: $table.isRetired,
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

  ColumnOrderings<bool> get isRetired => $composableBuilder(
    column: $table.isRetired,
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

  GeneratedColumn<bool> get isRetired =>
      $composableBuilder(column: $table.isRetired, builder: (column) => column);

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
                Value<bool> isRetired = const Value.absent(),
              }) => CommunesCompanion(
                id: id,
                wilayaCode: wilayaCode,
                nameFr: nameFr,
                nameAr: nameAr,
                latitude: latitude,
                longitude: longitude,
                geohash: geohash,
                boundary: boundary,
                isRetired: isRetired,
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
                Value<bool> isRetired = const Value.absent(),
              }) => CommunesCompanion.insert(
                id: id,
                wilayaCode: wilayaCode,
                nameFr: nameFr,
                nameAr: nameAr,
                latitude: latitude,
                longitude: longitude,
                geohash: geohash,
                boundary: boundary,
                isRetired: isRetired,
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

  static MultiTypedResultKey<$DailySettlementsTable, List<DailySettlement>>
  _dailySettlementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailySettlements,
    aliasName: 'batches__id__daily_settlements__batch_id',
  );

  $$DailySettlementsTableProcessedTableManager get dailySettlementsRefs {
    final manager = $$DailySettlementsTableTableManager(
      $_db,
      $_db.dailySettlements,
    ).filter((f) => f.batchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dailySettlementsRefsTable($_db),
    );
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

  Expression<bool> dailySettlementsRefs(
    Expression<bool> Function($$DailySettlementsTableFilterComposer f) f,
  ) {
    final $$DailySettlementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailySettlements,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailySettlementsTableFilterComposer(
            $db: $db,
            $table: $db.dailySettlements,
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

  Expression<T> dailySettlementsRefs<T extends Object>(
    Expression<T> Function($$DailySettlementsTableAnnotationComposer a) f,
  ) {
    final $$DailySettlementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailySettlements,
      getReferencedColumn: (t) => t.batchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailySettlementsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailySettlements,
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
            bool dailySettlementsRefs,
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
              ({
                ownerId = false,
                companyId = false,
                ordersRefs = false,
                dailySettlementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ordersRefs) db.orders,
                    if (dailySettlementsRefs) db.dailySettlements,
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
                      if (dailySettlementsRefs)
                        await $_getPrefetchedData<
                          Batch,
                          $BatchesTable,
                          DailySettlement
                        >(
                          currentTable: table,
                          referencedTable: $$BatchesTableReferences
                              ._dailySettlementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).dailySettlementsRefs,
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
      PrefetchHooks Function({
        bool ownerId,
        bool companyId,
        bool ordersRefs,
        bool dailySettlementsRefs,
      })
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
      Value<DeliveryAttemptOutcome?> lastAttemptOutcome,
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
      Value<DeliveryAttemptOutcome?> lastAttemptOutcome,
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

  static MultiTypedResultKey<$RouteStopsTable, List<RouteStop>>
  _routeStopsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routeStops,
    aliasName: 'orders__id__route_stops__order_id',
  );

  $$RouteStopsTableProcessedTableManager get routeStopsRefs {
    final manager = $$RouteStopsTableTableManager(
      $_db,
      $_db.routeStops,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routeStopsRefsTable($_db));
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
  get lastAttemptOutcome => $composableBuilder(
    column: $table.lastAttemptOutcome,
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

  Expression<bool> routeStopsRefs(
    Expression<bool> Function($$RouteStopsTableFilterComposer f) f,
  ) {
    final $$RouteStopsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routeStops,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RouteStopsTableFilterComposer(
            $db: $db,
            $table: $db.routeStops,
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

  ColumnOrderings<String> get lastAttemptOutcome => $composableBuilder(
    column: $table.lastAttemptOutcome,
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
  get lastAttemptOutcome => $composableBuilder(
    column: $table.lastAttemptOutcome,
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

  Expression<T> routeStopsRefs<T extends Object>(
    Expression<T> Function($$RouteStopsTableAnnotationComposer a) f,
  ) {
    final $$RouteStopsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routeStops,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RouteStopsTableAnnotationComposer(
            $db: $db,
            $table: $db.routeStops,
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
            bool routeStopsRefs,
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
                Value<DeliveryAttemptOutcome?> lastAttemptOutcome =
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
                lastAttemptOutcome: lastAttemptOutcome,
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
                Value<DeliveryAttemptOutcome?> lastAttemptOutcome =
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
                lastAttemptOutcome: lastAttemptOutcome,
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
                routeStopsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (deliveryAttemptsRefs) db.deliveryAttempts,
                    if (proofOfDeliveryRefs) db.proofOfDelivery,
                    if (routeStopsRefs) db.routeStops,
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
                      if (routeStopsRefs)
                        await $_getPrefetchedData<
                          Order,
                          $OrdersTable,
                          RouteStop
                        >(
                          currentTable: table,
                          referencedTable: $$OrdersTableReferences
                              ._routeStopsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).routeStopsRefs,
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
        bool routeStopsRefs,
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
typedef $$RoutesTableCreateCompanionBuilder =
    RoutesCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required int version,
      required String serviceDate,
      Value<RouteStatus> status,
      Value<double?> originLatitude,
      Value<double?> originLongitude,
      Value<int?> totalDistanceM,
      Value<int?> totalDurationS,
      Value<DateTime?> optimizedAt,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<String?> algorithm,
      Value<int> rowid,
    });
typedef $$RoutesTableUpdateCompanionBuilder =
    RoutesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> serviceDate,
      Value<RouteStatus> status,
      Value<double?> originLatitude,
      Value<double?> originLongitude,
      Value<int?> totalDistanceM,
      Value<int?> totalDurationS,
      Value<DateTime?> optimizedAt,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<String?> algorithm,
      Value<int> rowid,
    });

final class $$RoutesTableReferences
    extends BaseReferences<_$AppDatabase, $RoutesTable, Route> {
  $$RoutesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('routes__owner_id__users__id');

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

  static MultiTypedResultKey<$RouteStopsTable, List<RouteStop>>
  _routeStopsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routeStops,
    aliasName: 'routes__id__route_stops__route_id',
  );

  $$RouteStopsTableProcessedTableManager get routeStopsRefs {
    final manager = $$RouteStopsTableTableManager(
      $_db,
      $_db.routeStops,
    ).filter((f) => f.routeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routeStopsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<RouteStatus, RouteStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get originLatitude => $composableBuilder(
    column: $table.originLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get originLongitude => $composableBuilder(
    column: $table.originLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDistanceM => $composableBuilder(
    column: $table.totalDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDurationS => $composableBuilder(
    column: $table.totalDurationS,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get optimizedAt =>
      $composableBuilder(
        column: $table.optimizedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get startedAt =>
      $composableBuilder(
        column: $table.startedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get completedAt =>
      $composableBuilder(
        column: $table.completedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get algorithm => $composableBuilder(
    column: $table.algorithm,
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

  Expression<bool> routeStopsRefs(
    Expression<bool> Function($$RouteStopsTableFilterComposer f) f,
  ) {
    final $$RouteStopsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routeStops,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RouteStopsTableFilterComposer(
            $db: $db,
            $table: $db.routeStops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableOrderingComposer({
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

  ColumnOrderings<double> get originLatitude => $composableBuilder(
    column: $table.originLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get originLongitude => $composableBuilder(
    column: $table.originLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDistanceM => $composableBuilder(
    column: $table.totalDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDurationS => $composableBuilder(
    column: $table.totalDurationS,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get optimizedAt => $composableBuilder(
    column: $table.optimizedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get algorithm => $composableBuilder(
    column: $table.algorithm,
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

class $$RoutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<RouteStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get originLatitude => $composableBuilder(
    column: $table.originLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get originLongitude => $composableBuilder(
    column: $table.originLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDistanceM => $composableBuilder(
    column: $table.totalDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDurationS => $composableBuilder(
    column: $table.totalDurationS,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get optimizedAt =>
      $composableBuilder(
        column: $table.optimizedAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get completedAt =>
      $composableBuilder(
        column: $table.completedAt,
        builder: (column) => column,
      );

  GeneratedColumn<String> get algorithm =>
      $composableBuilder(column: $table.algorithm, builder: (column) => column);

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

  Expression<T> routeStopsRefs<T extends Object>(
    Expression<T> Function($$RouteStopsTableAnnotationComposer a) f,
  ) {
    final $$RouteStopsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routeStops,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RouteStopsTableAnnotationComposer(
            $db: $db,
            $table: $db.routeStops,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutesTable,
          Route,
          $$RoutesTableFilterComposer,
          $$RoutesTableOrderingComposer,
          $$RoutesTableAnnotationComposer,
          $$RoutesTableCreateCompanionBuilder,
          $$RoutesTableUpdateCompanionBuilder,
          (Route, $$RoutesTableReferences),
          Route,
          PrefetchHooks Function({bool ownerId, bool routeStopsRefs})
        > {
  $$RoutesTableTableManager(_$AppDatabase db, $RoutesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> serviceDate = const Value.absent(),
                Value<RouteStatus> status = const Value.absent(),
                Value<double?> originLatitude = const Value.absent(),
                Value<double?> originLongitude = const Value.absent(),
                Value<int?> totalDistanceM = const Value.absent(),
                Value<int?> totalDurationS = const Value.absent(),
                Value<DateTime?> optimizedAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> algorithm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutesCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                serviceDate: serviceDate,
                status: status,
                originLatitude: originLatitude,
                originLongitude: originLongitude,
                totalDistanceM: totalDistanceM,
                totalDurationS: totalDurationS,
                optimizedAt: optimizedAt,
                startedAt: startedAt,
                completedAt: completedAt,
                algorithm: algorithm,
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
                required String serviceDate,
                Value<RouteStatus> status = const Value.absent(),
                Value<double?> originLatitude = const Value.absent(),
                Value<double?> originLongitude = const Value.absent(),
                Value<int?> totalDistanceM = const Value.absent(),
                Value<int?> totalDurationS = const Value.absent(),
                Value<DateTime?> optimizedAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> algorithm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutesCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                serviceDate: serviceDate,
                status: status,
                originLatitude: originLatitude,
                originLongitude: originLongitude,
                totalDistanceM: totalDistanceM,
                totalDurationS: totalDurationS,
                optimizedAt: optimizedAt,
                startedAt: startedAt,
                completedAt: completedAt,
                algorithm: algorithm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RoutesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({ownerId = false, routeStopsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routeStopsRefs) db.routeStops],
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
                                referencedTable: $$RoutesTableReferences
                                    ._ownerIdTable(db),
                                referencedColumn: $$RoutesTableReferences
                                    ._ownerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routeStopsRefs)
                    await $_getPrefetchedData<Route, $RoutesTable, RouteStop>(
                      currentTable: table,
                      referencedTable: $$RoutesTableReferences
                          ._routeStopsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoutesTableReferences(db, table, p0).routeStopsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.routeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutesTable,
      Route,
      $$RoutesTableFilterComposer,
      $$RoutesTableOrderingComposer,
      $$RoutesTableAnnotationComposer,
      $$RoutesTableCreateCompanionBuilder,
      $$RoutesTableUpdateCompanionBuilder,
      (Route, $$RoutesTableReferences),
      Route,
      PrefetchHooks Function({bool ownerId, bool routeStopsRefs})
    >;
typedef $$RouteStopsTableCreateCompanionBuilder =
    RouteStopsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String routeId,
      required String orderId,
      required int sequence,
      Value<int?> legDistanceM,
      Value<int?> legDurationS,
      Value<DateTime?> eta,
      Value<DateTime?> arrivedAt,
      Value<DateTime?> departedAt,
      Value<bool> isLocked,
      Value<int> rowid,
    });
typedef $$RouteStopsTableUpdateCompanionBuilder =
    RouteStopsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> routeId,
      Value<String> orderId,
      Value<int> sequence,
      Value<int?> legDistanceM,
      Value<int?> legDurationS,
      Value<DateTime?> eta,
      Value<DateTime?> arrivedAt,
      Value<DateTime?> departedAt,
      Value<bool> isLocked,
      Value<int> rowid,
    });

final class $$RouteStopsTableReferences
    extends BaseReferences<_$AppDatabase, $RouteStopsTable, RouteStop> {
  $$RouteStopsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutesTable _routeIdTable(_$AppDatabase db) =>
      db.routes.createAlias('route_stops__route_id__routes__id');

  $$RoutesTableProcessedTableManager get routeId {
    final $_column = $_itemColumn<String>('route_id')!;

    final manager = $$RoutesTableTableManager(
      $_db,
      $_db.routes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OrdersTable _orderIdTable(_$AppDatabase db) =>
      db.orders.createAlias('route_stops__order_id__orders__id');

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

class $$RouteStopsTableFilterComposer
    extends Composer<_$AppDatabase, $RouteStopsTable> {
  $$RouteStopsTableFilterComposer({
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

  ColumnFilters<int> get legDistanceM => $composableBuilder(
    column: $table.legDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get legDurationS => $composableBuilder(
    column: $table.legDurationS,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get eta =>
      $composableBuilder(
        column: $table.eta,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get arrivedAt =>
      $composableBuilder(
        column: $table.arrivedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get departedAt =>
      $composableBuilder(
        column: $table.departedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutesTableFilterComposer get routeId {
    final $$RoutesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableFilterComposer(
            $db: $db,
            $table: $db.routes,
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

class $$RouteStopsTableOrderingComposer
    extends Composer<_$AppDatabase, $RouteStopsTable> {
  $$RouteStopsTableOrderingComposer({
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

  ColumnOrderings<int> get legDistanceM => $composableBuilder(
    column: $table.legDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get legDurationS => $composableBuilder(
    column: $table.legDurationS,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eta => $composableBuilder(
    column: $table.eta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get arrivedAt => $composableBuilder(
    column: $table.arrivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get departedAt => $composableBuilder(
    column: $table.departedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutesTableOrderingComposer get routeId {
    final $$RoutesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableOrderingComposer(
            $db: $db,
            $table: $db.routes,
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

class $$RouteStopsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RouteStopsTable> {
  $$RouteStopsTableAnnotationComposer({
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

  GeneratedColumn<int> get legDistanceM => $composableBuilder(
    column: $table.legDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get legDurationS => $composableBuilder(
    column: $table.legDurationS,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get eta =>
      $composableBuilder(column: $table.eta, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get arrivedAt =>
      $composableBuilder(column: $table.arrivedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get departedAt =>
      $composableBuilder(
        column: $table.departedAt,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  $$RoutesTableAnnotationComposer get routeId {
    final $$RoutesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableAnnotationComposer(
            $db: $db,
            $table: $db.routes,
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

class $$RouteStopsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RouteStopsTable,
          RouteStop,
          $$RouteStopsTableFilterComposer,
          $$RouteStopsTableOrderingComposer,
          $$RouteStopsTableAnnotationComposer,
          $$RouteStopsTableCreateCompanionBuilder,
          $$RouteStopsTableUpdateCompanionBuilder,
          (RouteStop, $$RouteStopsTableReferences),
          RouteStop,
          PrefetchHooks Function({bool routeId, bool orderId})
        > {
  $$RouteStopsTableTableManager(_$AppDatabase db, $RouteStopsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RouteStopsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RouteStopsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RouteStopsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> routeId = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<int?> legDistanceM = const Value.absent(),
                Value<int?> legDurationS = const Value.absent(),
                Value<DateTime?> eta = const Value.absent(),
                Value<DateTime?> arrivedAt = const Value.absent(),
                Value<DateTime?> departedAt = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RouteStopsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                routeId: routeId,
                orderId: orderId,
                sequence: sequence,
                legDistanceM: legDistanceM,
                legDurationS: legDurationS,
                eta: eta,
                arrivedAt: arrivedAt,
                departedAt: departedAt,
                isLocked: isLocked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String routeId,
                required String orderId,
                required int sequence,
                Value<int?> legDistanceM = const Value.absent(),
                Value<int?> legDurationS = const Value.absent(),
                Value<DateTime?> eta = const Value.absent(),
                Value<DateTime?> arrivedAt = const Value.absent(),
                Value<DateTime?> departedAt = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RouteStopsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                routeId: routeId,
                orderId: orderId,
                sequence: sequence,
                legDistanceM: legDistanceM,
                legDurationS: legDurationS,
                eta: eta,
                arrivedAt: arrivedAt,
                departedAt: departedAt,
                isLocked: isLocked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RouteStopsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routeId = false, orderId = false}) {
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
                    if (routeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.routeId,
                                referencedTable: $$RouteStopsTableReferences
                                    ._routeIdTable(db),
                                referencedColumn: $$RouteStopsTableReferences
                                    ._routeIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable: $$RouteStopsTableReferences
                                    ._orderIdTable(db),
                                referencedColumn: $$RouteStopsTableReferences
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

typedef $$RouteStopsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RouteStopsTable,
      RouteStop,
      $$RouteStopsTableFilterComposer,
      $$RouteStopsTableOrderingComposer,
      $$RouteStopsTableAnnotationComposer,
      $$RouteStopsTableCreateCompanionBuilder,
      $$RouteStopsTableUpdateCompanionBuilder,
      (RouteStop, $$RouteStopsTableReferences),
      RouteStop,
      PrefetchHooks Function({bool routeId, bool orderId})
    >;
typedef $$MatrixCacheTableCreateCompanionBuilder =
    MatrixCacheCompanion Function({
      required String id,
      required String pointHash,
      required String durations,
      required String distances,
      required String provider,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$MatrixCacheTableUpdateCompanionBuilder =
    MatrixCacheCompanion Function({
      Value<String> id,
      Value<String> pointHash,
      Value<String> durations,
      Value<String> distances,
      Value<String> provider,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$MatrixCacheTableFilterComposer
    extends Composer<_$AppDatabase, $MatrixCacheTable> {
  $$MatrixCacheTableFilterComposer({
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

  ColumnFilters<String> get pointHash => $composableBuilder(
    column: $table.pointHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get durations => $composableBuilder(
    column: $table.durations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get distances => $composableBuilder(
    column: $table.distances,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get fetchedAt =>
      $composableBuilder(
        column: $table.fetchedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$MatrixCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $MatrixCacheTable> {
  $$MatrixCacheTableOrderingComposer({
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

  ColumnOrderings<String> get pointHash => $composableBuilder(
    column: $table.pointHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get durations => $composableBuilder(
    column: $table.durations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distances => $composableBuilder(
    column: $table.distances,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MatrixCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatrixCacheTable> {
  $$MatrixCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pointHash =>
      $composableBuilder(column: $table.pointHash, builder: (column) => column);

  GeneratedColumn<String> get durations =>
      $composableBuilder(column: $table.durations, builder: (column) => column);

  GeneratedColumn<String> get distances =>
      $composableBuilder(column: $table.distances, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$MatrixCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MatrixCacheTable,
          MatrixCacheData,
          $$MatrixCacheTableFilterComposer,
          $$MatrixCacheTableOrderingComposer,
          $$MatrixCacheTableAnnotationComposer,
          $$MatrixCacheTableCreateCompanionBuilder,
          $$MatrixCacheTableUpdateCompanionBuilder,
          (
            MatrixCacheData,
            BaseReferences<_$AppDatabase, $MatrixCacheTable, MatrixCacheData>,
          ),
          MatrixCacheData,
          PrefetchHooks Function()
        > {
  $$MatrixCacheTableTableManager(_$AppDatabase db, $MatrixCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatrixCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatrixCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatrixCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pointHash = const Value.absent(),
                Value<String> durations = const Value.absent(),
                Value<String> distances = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatrixCacheCompanion(
                id: id,
                pointHash: pointHash,
                durations: durations,
                distances: distances,
                provider: provider,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pointHash,
                required String durations,
                required String distances,
                required String provider,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => MatrixCacheCompanion.insert(
                id: id,
                pointHash: pointHash,
                durations: durations,
                distances: distances,
                provider: provider,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MatrixCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MatrixCacheTable,
      MatrixCacheData,
      $$MatrixCacheTableFilterComposer,
      $$MatrixCacheTableOrderingComposer,
      $$MatrixCacheTableAnnotationComposer,
      $$MatrixCacheTableCreateCompanionBuilder,
      $$MatrixCacheTableUpdateCompanionBuilder,
      (
        MatrixCacheData,
        BaseReferences<_$AppDatabase, $MatrixCacheTable, MatrixCacheData>,
      ),
      MatrixCacheData,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required int version,
      required String serviceDate,
      required ExpenseCategory category,
      required Centimes amount,
      Value<String?> note,
      Value<String?> receiptPath,
      Value<int> rowid,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> serviceDate,
      Value<ExpenseCategory> category,
      Value<Centimes> amount,
      Value<String?> note,
      Value<String?> receiptPath,
      Value<int> rowid,
    });

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('expenses__owner_id__users__id');

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
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ExpenseCategory, ExpenseCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int> get amount =>
      $composableBuilder(
        column: $table.amount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
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
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
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

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<ExpenseCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Centimes, int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
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
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({bool ownerId})
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> serviceDate = const Value.absent(),
                Value<ExpenseCategory> category = const Value.absent(),
                Value<Centimes> amount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                serviceDate: serviceDate,
                category: category,
                amount: amount,
                note: note,
                receiptPath: receiptPath,
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
                required String serviceDate,
                required ExpenseCategory category,
                required Centimes amount,
                Value<String?> note = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                serviceDate: serviceDate,
                category: category,
                amount: amount,
                note: note,
                receiptPath: receiptPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ownerId = false}) {
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
                                referencedTable: $$ExpensesTableReferences
                                    ._ownerIdTable(db),
                                referencedColumn: $$ExpensesTableReferences
                                    ._ownerIdTable(db)
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

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({bool ownerId})
    >;
typedef $$DailySettlementsTableCreateCompanionBuilder =
    DailySettlementsCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required String batchId,
      required String serviceDate,
      required int ordersTotal,
      required int ordersDelivered,
      required int ordersFailed,
      required int ordersPending,
      required Centimes expectedCollection,
      required Centimes actualCollection,
      required Centimes companyAmount,
      required Centimes driverGross,
      required Centimes expensesAllocated,
      required Centimes driverNet,
      required int ruleVersion,
      required String snapshot,
      required String contentHash,
      required DateTime confirmedAt,
      Value<int> rowid,
    });
typedef $$DailySettlementsTableUpdateCompanionBuilder =
    DailySettlementsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<String> batchId,
      Value<String> serviceDate,
      Value<int> ordersTotal,
      Value<int> ordersDelivered,
      Value<int> ordersFailed,
      Value<int> ordersPending,
      Value<Centimes> expectedCollection,
      Value<Centimes> actualCollection,
      Value<Centimes> companyAmount,
      Value<Centimes> driverGross,
      Value<Centimes> expensesAllocated,
      Value<Centimes> driverNet,
      Value<int> ruleVersion,
      Value<String> snapshot,
      Value<String> contentHash,
      Value<DateTime> confirmedAt,
      Value<int> rowid,
    });

final class $$DailySettlementsTableReferences
    extends
        BaseReferences<_$AppDatabase, $DailySettlementsTable, DailySettlement> {
  $$DailySettlementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('daily_settlements__owner_id__users__id');

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
      db.batches.createAlias('daily_settlements__batch_id__batches__id');

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

  static MultiTypedResultKey<
    $SettlementAdjustmentsTable,
    List<SettlementAdjustment>
  >
  _settlementAdjustmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.settlementAdjustments,
        aliasName:
            'daily_settlements__id__settlement_adjustments__settlement_id',
      );

  $$SettlementAdjustmentsTableProcessedTableManager
  get settlementAdjustmentsRefs {
    final manager = $$SettlementAdjustmentsTableTableManager(
      $_db,
      $_db.settlementAdjustments,
    ).filter((f) => f.settlementId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _settlementAdjustmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DailySettlementsTableFilterComposer
    extends Composer<_$AppDatabase, $DailySettlementsTable> {
  $$DailySettlementsTableFilterComposer({
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

  ColumnFilters<String> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordersTotal => $composableBuilder(
    column: $table.ordersTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordersDelivered => $composableBuilder(
    column: $table.ordersDelivered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordersFailed => $composableBuilder(
    column: $table.ordersFailed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordersPending => $composableBuilder(
    column: $table.ordersPending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int>
  get expectedCollection => $composableBuilder(
    column: $table.expectedCollection,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int>
  get actualCollection => $composableBuilder(
    column: $table.actualCollection,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int> get companyAmount =>
      $composableBuilder(
        column: $table.companyAmount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int> get driverGross =>
      $composableBuilder(
        column: $table.driverGross,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int>
  get expensesAllocated => $composableBuilder(
    column: $table.expensesAllocated,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Centimes, Centimes, int> get driverNet =>
      $composableBuilder(
        column: $table.driverNet,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshot => $composableBuilder(
    column: $table.snapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get confirmedAt =>
      $composableBuilder(
        column: $table.confirmedAt,
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

  Expression<bool> settlementAdjustmentsRefs(
    Expression<bool> Function($$SettlementAdjustmentsTableFilterComposer f) f,
  ) {
    final $$SettlementAdjustmentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.settlementAdjustments,
          getReferencedColumn: (t) => t.settlementId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SettlementAdjustmentsTableFilterComposer(
                $db: $db,
                $table: $db.settlementAdjustments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DailySettlementsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailySettlementsTable> {
  $$DailySettlementsTableOrderingComposer({
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

  ColumnOrderings<String> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordersTotal => $composableBuilder(
    column: $table.ordersTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordersDelivered => $composableBuilder(
    column: $table.ordersDelivered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordersFailed => $composableBuilder(
    column: $table.ordersFailed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordersPending => $composableBuilder(
    column: $table.ordersPending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedCollection => $composableBuilder(
    column: $table.expectedCollection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualCollection => $composableBuilder(
    column: $table.actualCollection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get companyAmount => $composableBuilder(
    column: $table.companyAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get driverGross => $composableBuilder(
    column: $table.driverGross,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expensesAllocated => $composableBuilder(
    column: $table.expensesAllocated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get driverNet => $composableBuilder(
    column: $table.driverNet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshot => $composableBuilder(
    column: $table.snapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confirmedAt => $composableBuilder(
    column: $table.confirmedAt,
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
}

class $$DailySettlementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailySettlementsTable> {
  $$DailySettlementsTableAnnotationComposer({
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

  GeneratedColumn<String> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordersTotal => $composableBuilder(
    column: $table.ordersTotal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordersDelivered => $composableBuilder(
    column: $table.ordersDelivered,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordersFailed => $composableBuilder(
    column: $table.ordersFailed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordersPending => $composableBuilder(
    column: $table.ordersPending,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Centimes, int> get expectedCollection =>
      $composableBuilder(
        column: $table.expectedCollection,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Centimes, int> get actualCollection =>
      $composableBuilder(
        column: $table.actualCollection,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Centimes, int> get companyAmount =>
      $composableBuilder(
        column: $table.companyAmount,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Centimes, int> get driverGross =>
      $composableBuilder(
        column: $table.driverGross,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Centimes, int> get expensesAllocated =>
      $composableBuilder(
        column: $table.expensesAllocated,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Centimes, int> get driverNet =>
      $composableBuilder(column: $table.driverNet, builder: (column) => column);

  GeneratedColumn<int> get ruleVersion => $composableBuilder(
    column: $table.ruleVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snapshot =>
      $composableBuilder(column: $table.snapshot, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get confirmedAt =>
      $composableBuilder(
        column: $table.confirmedAt,
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

  Expression<T> settlementAdjustmentsRefs<T extends Object>(
    Expression<T> Function($$SettlementAdjustmentsTableAnnotationComposer a) f,
  ) {
    final $$SettlementAdjustmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.settlementAdjustments,
          getReferencedColumn: (t) => t.settlementId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SettlementAdjustmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.settlementAdjustments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DailySettlementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailySettlementsTable,
          DailySettlement,
          $$DailySettlementsTableFilterComposer,
          $$DailySettlementsTableOrderingComposer,
          $$DailySettlementsTableAnnotationComposer,
          $$DailySettlementsTableCreateCompanionBuilder,
          $$DailySettlementsTableUpdateCompanionBuilder,
          (DailySettlement, $$DailySettlementsTableReferences),
          DailySettlement,
          PrefetchHooks Function({
            bool ownerId,
            bool batchId,
            bool settlementAdjustmentsRefs,
          })
        > {
  $$DailySettlementsTableTableManager(
    _$AppDatabase db,
    $DailySettlementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailySettlementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailySettlementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailySettlementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> batchId = const Value.absent(),
                Value<String> serviceDate = const Value.absent(),
                Value<int> ordersTotal = const Value.absent(),
                Value<int> ordersDelivered = const Value.absent(),
                Value<int> ordersFailed = const Value.absent(),
                Value<int> ordersPending = const Value.absent(),
                Value<Centimes> expectedCollection = const Value.absent(),
                Value<Centimes> actualCollection = const Value.absent(),
                Value<Centimes> companyAmount = const Value.absent(),
                Value<Centimes> driverGross = const Value.absent(),
                Value<Centimes> expensesAllocated = const Value.absent(),
                Value<Centimes> driverNet = const Value.absent(),
                Value<int> ruleVersion = const Value.absent(),
                Value<String> snapshot = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<DateTime> confirmedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailySettlementsCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                batchId: batchId,
                serviceDate: serviceDate,
                ordersTotal: ordersTotal,
                ordersDelivered: ordersDelivered,
                ordersFailed: ordersFailed,
                ordersPending: ordersPending,
                expectedCollection: expectedCollection,
                actualCollection: actualCollection,
                companyAmount: companyAmount,
                driverGross: driverGross,
                expensesAllocated: expensesAllocated,
                driverNet: driverNet,
                ruleVersion: ruleVersion,
                snapshot: snapshot,
                contentHash: contentHash,
                confirmedAt: confirmedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required DateTime createdAt,
                required String batchId,
                required String serviceDate,
                required int ordersTotal,
                required int ordersDelivered,
                required int ordersFailed,
                required int ordersPending,
                required Centimes expectedCollection,
                required Centimes actualCollection,
                required Centimes companyAmount,
                required Centimes driverGross,
                required Centimes expensesAllocated,
                required Centimes driverNet,
                required int ruleVersion,
                required String snapshot,
                required String contentHash,
                required DateTime confirmedAt,
                Value<int> rowid = const Value.absent(),
              }) => DailySettlementsCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                batchId: batchId,
                serviceDate: serviceDate,
                ordersTotal: ordersTotal,
                ordersDelivered: ordersDelivered,
                ordersFailed: ordersFailed,
                ordersPending: ordersPending,
                expectedCollection: expectedCollection,
                actualCollection: actualCollection,
                companyAmount: companyAmount,
                driverGross: driverGross,
                expensesAllocated: expensesAllocated,
                driverNet: driverNet,
                ruleVersion: ruleVersion,
                snapshot: snapshot,
                contentHash: contentHash,
                confirmedAt: confirmedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DailySettlementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ownerId = false,
                batchId = false,
                settlementAdjustmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (settlementAdjustmentsRefs) db.settlementAdjustments,
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
                                    referencedTable:
                                        $$DailySettlementsTableReferences
                                            ._ownerIdTable(db),
                                    referencedColumn:
                                        $$DailySettlementsTableReferences
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
                                    referencedTable:
                                        $$DailySettlementsTableReferences
                                            ._batchIdTable(db),
                                    referencedColumn:
                                        $$DailySettlementsTableReferences
                                            ._batchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (settlementAdjustmentsRefs)
                        await $_getPrefetchedData<
                          DailySettlement,
                          $DailySettlementsTable,
                          SettlementAdjustment
                        >(
                          currentTable: table,
                          referencedTable: $$DailySettlementsTableReferences
                              ._settlementAdjustmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DailySettlementsTableReferences(
                                db,
                                table,
                                p0,
                              ).settlementAdjustmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.settlementId == item.id,
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

typedef $$DailySettlementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailySettlementsTable,
      DailySettlement,
      $$DailySettlementsTableFilterComposer,
      $$DailySettlementsTableOrderingComposer,
      $$DailySettlementsTableAnnotationComposer,
      $$DailySettlementsTableCreateCompanionBuilder,
      $$DailySettlementsTableUpdateCompanionBuilder,
      (DailySettlement, $$DailySettlementsTableReferences),
      DailySettlement,
      PrefetchHooks Function({
        bool ownerId,
        bool batchId,
        bool settlementAdjustmentsRefs,
      })
    >;
typedef $$SettlementAdjustmentsTableCreateCompanionBuilder =
    SettlementAdjustmentsCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required String settlementId,
      required Centimes amount,
      required String reason,
      Value<int> rowid,
    });
typedef $$SettlementAdjustmentsTableUpdateCompanionBuilder =
    SettlementAdjustmentsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<String> settlementId,
      Value<Centimes> amount,
      Value<String> reason,
      Value<int> rowid,
    });

final class $$SettlementAdjustmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SettlementAdjustmentsTable,
          SettlementAdjustment
        > {
  $$SettlementAdjustmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('settlement_adjustments__owner_id__users__id');

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

  static $DailySettlementsTable _settlementIdTable(_$AppDatabase db) =>
      db.dailySettlements.createAlias(
        'settlement_adjustments__settlement_id__daily_settlements__id',
      );

  $$DailySettlementsTableProcessedTableManager get settlementId {
    final $_column = $_itemColumn<String>('settlement_id')!;

    final manager = $$DailySettlementsTableTableManager(
      $_db,
      $_db.dailySettlements,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_settlementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SettlementAdjustmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SettlementAdjustmentsTable> {
  $$SettlementAdjustmentsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<Centimes, Centimes, int> get amount =>
      $composableBuilder(
        column: $table.amount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
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

  $$DailySettlementsTableFilterComposer get settlementId {
    final $$DailySettlementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.settlementId,
      referencedTable: $db.dailySettlements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailySettlementsTableFilterComposer(
            $db: $db,
            $table: $db.dailySettlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SettlementAdjustmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettlementAdjustmentsTable> {
  $$SettlementAdjustmentsTableOrderingComposer({
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

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
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

  $$DailySettlementsTableOrderingComposer get settlementId {
    final $$DailySettlementsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.settlementId,
      referencedTable: $db.dailySettlements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailySettlementsTableOrderingComposer(
            $db: $db,
            $table: $db.dailySettlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SettlementAdjustmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettlementAdjustmentsTable> {
  $$SettlementAdjustmentsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<Centimes, int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

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

  $$DailySettlementsTableAnnotationComposer get settlementId {
    final $$DailySettlementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.settlementId,
      referencedTable: $db.dailySettlements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailySettlementsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailySettlements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SettlementAdjustmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettlementAdjustmentsTable,
          SettlementAdjustment,
          $$SettlementAdjustmentsTableFilterComposer,
          $$SettlementAdjustmentsTableOrderingComposer,
          $$SettlementAdjustmentsTableAnnotationComposer,
          $$SettlementAdjustmentsTableCreateCompanionBuilder,
          $$SettlementAdjustmentsTableUpdateCompanionBuilder,
          (SettlementAdjustment, $$SettlementAdjustmentsTableReferences),
          SettlementAdjustment,
          PrefetchHooks Function({bool ownerId, bool settlementId})
        > {
  $$SettlementAdjustmentsTableTableManager(
    _$AppDatabase db,
    $SettlementAdjustmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettlementAdjustmentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SettlementAdjustmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SettlementAdjustmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> settlementId = const Value.absent(),
                Value<Centimes> amount = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettlementAdjustmentsCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                settlementId: settlementId,
                amount: amount,
                reason: reason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required DateTime createdAt,
                required String settlementId,
                required Centimes amount,
                required String reason,
                Value<int> rowid = const Value.absent(),
              }) => SettlementAdjustmentsCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                settlementId: settlementId,
                amount: amount,
                reason: reason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SettlementAdjustmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ownerId = false, settlementId = false}) {
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
                                    $$SettlementAdjustmentsTableReferences
                                        ._ownerIdTable(db),
                                referencedColumn:
                                    $$SettlementAdjustmentsTableReferences
                                        ._ownerIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (settlementId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.settlementId,
                                referencedTable:
                                    $$SettlementAdjustmentsTableReferences
                                        ._settlementIdTable(db),
                                referencedColumn:
                                    $$SettlementAdjustmentsTableReferences
                                        ._settlementIdTable(db)
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

typedef $$SettlementAdjustmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettlementAdjustmentsTable,
      SettlementAdjustment,
      $$SettlementAdjustmentsTableFilterComposer,
      $$SettlementAdjustmentsTableOrderingComposer,
      $$SettlementAdjustmentsTableAnnotationComposer,
      $$SettlementAdjustmentsTableCreateCompanionBuilder,
      $$SettlementAdjustmentsTableUpdateCompanionBuilder,
      (SettlementAdjustment, $$SettlementAdjustmentsTableReferences),
      SettlementAdjustment,
      PrefetchHooks Function({bool ownerId, bool settlementId})
    >;
typedef $$RemittancesTableCreateCompanionBuilder =
    RemittancesCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required int version,
      required String companyId,
      required Centimes amount,
      required RemittanceMethod method,
      Value<String?> reference,
      Value<String?> receiptPath,
      Value<String?> coversFrom,
      Value<String?> coversTo,
      required DateTime remittedAt,
      Value<int> rowid,
    });
typedef $$RemittancesTableUpdateCompanionBuilder =
    RemittancesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String> companyId,
      Value<Centimes> amount,
      Value<RemittanceMethod> method,
      Value<String?> reference,
      Value<String?> receiptPath,
      Value<String?> coversFrom,
      Value<String?> coversTo,
      Value<DateTime> remittedAt,
      Value<int> rowid,
    });

final class $$RemittancesTableReferences
    extends BaseReferences<_$AppDatabase, $RemittancesTable, Remittance> {
  $$RemittancesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('remittances__owner_id__users__id');

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
      db.companies.createAlias('remittances__company_id__companies__id');

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

class $$RemittancesTableFilterComposer
    extends Composer<_$AppDatabase, $RemittancesTable> {
  $$RemittancesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<Centimes, Centimes, int> get amount =>
      $composableBuilder(
        column: $table.amount,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<RemittanceMethod, RemittanceMethod, String>
  get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coversFrom => $composableBuilder(
    column: $table.coversFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coversTo => $composableBuilder(
    column: $table.coversTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get remittedAt =>
      $composableBuilder(
        column: $table.remittedAt,
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
}

class $$RemittancesTableOrderingComposer
    extends Composer<_$AppDatabase, $RemittancesTable> {
  $$RemittancesTableOrderingComposer({
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

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coversFrom => $composableBuilder(
    column: $table.coversFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coversTo => $composableBuilder(
    column: $table.coversTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remittedAt => $composableBuilder(
    column: $table.remittedAt,
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

class $$RemittancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemittancesTable> {
  $$RemittancesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<Centimes, int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RemittanceMethod, String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coversFrom => $composableBuilder(
    column: $table.coversFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coversTo =>
      $composableBuilder(column: $table.coversTo, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get remittedAt =>
      $composableBuilder(
        column: $table.remittedAt,
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

class $$RemittancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemittancesTable,
          Remittance,
          $$RemittancesTableFilterComposer,
          $$RemittancesTableOrderingComposer,
          $$RemittancesTableAnnotationComposer,
          $$RemittancesTableCreateCompanionBuilder,
          $$RemittancesTableUpdateCompanionBuilder,
          (Remittance, $$RemittancesTableReferences),
          Remittance,
          PrefetchHooks Function({bool ownerId, bool companyId})
        > {
  $$RemittancesTableTableManager(_$AppDatabase db, $RemittancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemittancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemittancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemittancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<Centimes> amount = const Value.absent(),
                Value<RemittanceMethod> method = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<String?> coversFrom = const Value.absent(),
                Value<String?> coversTo = const Value.absent(),
                Value<DateTime> remittedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemittancesCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                companyId: companyId,
                amount: amount,
                method: method,
                reference: reference,
                receiptPath: receiptPath,
                coversFrom: coversFrom,
                coversTo: coversTo,
                remittedAt: remittedAt,
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
                required Centimes amount,
                required RemittanceMethod method,
                Value<String?> reference = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<String?> coversFrom = const Value.absent(),
                Value<String?> coversTo = const Value.absent(),
                required DateTime remittedAt,
                Value<int> rowid = const Value.absent(),
              }) => RemittancesCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                companyId: companyId,
                amount: amount,
                method: method,
                reference: reference,
                receiptPath: receiptPath,
                coversFrom: coversFrom,
                coversTo: coversTo,
                remittedAt: remittedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemittancesTableReferences(db, table, e),
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
                                referencedTable: $$RemittancesTableReferences
                                    ._ownerIdTable(db),
                                referencedColumn: $$RemittancesTableReferences
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
                                referencedTable: $$RemittancesTableReferences
                                    ._companyIdTable(db),
                                referencedColumn: $$RemittancesTableReferences
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

typedef $$RemittancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemittancesTable,
      Remittance,
      $$RemittancesTableFilterComposer,
      $$RemittancesTableOrderingComposer,
      $$RemittancesTableAnnotationComposer,
      $$RemittancesTableCreateCompanionBuilder,
      $$RemittancesTableUpdateCompanionBuilder,
      (Remittance, $$RemittancesTableReferences),
      Remittance,
      PrefetchHooks Function({bool ownerId, bool companyId})
    >;
typedef $$OutboxTableCreateCompanionBuilder =
    OutboxCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required OutboxOperation operation,
      required String payload,
      required String deviceId,
      required DateTime createdAt,
      Value<int> attempts,
      Value<String?> lastError,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$OutboxTableUpdateCompanionBuilder =
    OutboxCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<OutboxOperation> operation,
      Value<String> payload,
      Value<String> deviceId,
      Value<DateTime> createdAt,
      Value<int> attempts,
      Value<String?> lastError,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OutboxOperation, OutboxOperation, String>
  get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get syncedAt =>
      $composableBuilder(
        column: $table.syncedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OutboxOperation, String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxData,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
          OutboxData,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<OutboxOperation> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                deviceId: deviceId,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required OutboxOperation operation,
                required String payload,
                required String deviceId,
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                deviceId: deviceId,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxData,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
      OutboxData,
      PrefetchHooks Function()
    >;
typedef $$AuditLogsTableCreateCompanionBuilder =
    AuditLogsCompanion Function({
      required String id,
      required String ownerId,
      required DateTime createdAt,
      required String entityType,
      required String entityId,
      required String action,
      Value<String?> before,
      Value<String?> after,
      required DateTime occurredAt,
      Value<int> rowid,
    });
typedef $$AuditLogsTableUpdateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<DateTime> createdAt,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> action,
      Value<String?> before,
      Value<String?> after,
      Value<DateTime> occurredAt,
      Value<int> rowid,
    });

final class $$AuditLogsTableReferences
    extends BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog> {
  $$AuditLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _ownerIdTable(_$AppDatabase db) =>
      db.users.createAlias('audit_logs__owner_id__users__id');

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
}

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get before => $composableBuilder(
    column: $table.before,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get after => $composableBuilder(
    column: $table.after,
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
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get before => $composableBuilder(
    column: $table.before,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get after => $composableBuilder(
    column: $table.after,
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
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
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

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get before =>
      $composableBuilder(column: $table.before, builder: (column) => column);

  GeneratedColumn<String> get after =>
      $composableBuilder(column: $table.after, builder: (column) => column);

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
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, $$AuditLogsTableReferences),
          AuditLog,
          PrefetchHooks Function({bool ownerId})
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> before = const Value.absent(),
                Value<String?> after = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                entityType: entityType,
                entityId: entityId,
                action: action,
                before: before,
                after: after,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required DateTime createdAt,
                required String entityType,
                required String entityId,
                required String action,
                Value<String?> before = const Value.absent(),
                Value<String?> after = const Value.absent(),
                required DateTime occurredAt,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                ownerId: ownerId,
                createdAt: createdAt,
                entityType: entityType,
                entityId: entityId,
                action: action,
                before: before,
                after: after,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AuditLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ownerId = false}) {
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
                                referencedTable: $$AuditLogsTableReferences
                                    ._ownerIdTable(db),
                                referencedColumn: $$AuditLogsTableReferences
                                    ._ownerIdTable(db)
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

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, $$AuditLogsTableReferences),
      AuditLog,
      PrefetchHooks Function({bool ownerId})
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
  $$RoutesTableTableManager get routes =>
      $$RoutesTableTableManager(_db, _db.routes);
  $$RouteStopsTableTableManager get routeStops =>
      $$RouteStopsTableTableManager(_db, _db.routeStops);
  $$MatrixCacheTableTableManager get matrixCache =>
      $$MatrixCacheTableTableManager(_db, _db.matrixCache);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$DailySettlementsTableTableManager get dailySettlements =>
      $$DailySettlementsTableTableManager(_db, _db.dailySettlements);
  $$SettlementAdjustmentsTableTableManager get settlementAdjustments =>
      $$SettlementAdjustmentsTableTableManager(_db, _db.settlementAdjustments);
  $$RemittancesTableTableManager get remittances =>
      $$RemittancesTableTableManager(_db, _db.remittances);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
}
