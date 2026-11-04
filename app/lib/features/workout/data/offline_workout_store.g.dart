// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_workout_store.dart';

// ignore_for_file: type=lint
class $OfflineSetProjectionsTable extends OfflineSetProjections
    with TableInfo<$OfflineSetProjectionsTable, OfflineSetProjection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineSetProjectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadCipherVersionMeta =
      const VerificationMeta('payloadCipherVersion');
  @override
  late final GeneratedColumn<int> payloadCipherVersion = GeneratedColumn<int>(
    'payload_cipher_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadKeyVersionMeta = const VerificationMeta(
    'payloadKeyVersion',
  );
  @override
  late final GeneratedColumn<int> payloadKeyVersion = GeneratedColumn<int>(
    'payload_key_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadNonceMeta = const VerificationMeta(
    'payloadNonce',
  );
  @override
  late final GeneratedColumn<Uint8List> payloadNonce =
      GeneratedColumn<Uint8List>(
        'payload_nonce',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _payloadCiphertextMeta = const VerificationMeta(
    'payloadCiphertext',
  );
  @override
  late final GeneratedColumn<Uint8List> payloadCiphertext =
      GeneratedColumn<Uint8List>(
        'payload_ciphertext',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    ownerId,
    workoutId,
    payloadJson,
    payloadCipherVersion,
    payloadKeyVersion,
    payloadNonce,
    payloadCiphertext,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_set_projections';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfflineSetProjection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('payload_cipher_version')) {
      context.handle(
        _payloadCipherVersionMeta,
        payloadCipherVersion.isAcceptableOrUnknown(
          data['payload_cipher_version']!,
          _payloadCipherVersionMeta,
        ),
      );
    }
    if (data.containsKey('payload_key_version')) {
      context.handle(
        _payloadKeyVersionMeta,
        payloadKeyVersion.isAcceptableOrUnknown(
          data['payload_key_version']!,
          _payloadKeyVersionMeta,
        ),
      );
    }
    if (data.containsKey('payload_nonce')) {
      context.handle(
        _payloadNonceMeta,
        payloadNonce.isAcceptableOrUnknown(
          data['payload_nonce']!,
          _payloadNonceMeta,
        ),
      );
    }
    if (data.containsKey('payload_ciphertext')) {
      context.handle(
        _payloadCiphertextMeta,
        payloadCiphertext.isAcceptableOrUnknown(
          data['payload_ciphertext']!,
          _payloadCiphertextMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  OfflineSetProjection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineSetProjection(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
      payloadCipherVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_cipher_version'],
      ),
      payloadKeyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_key_version'],
      ),
      payloadNonce: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}payload_nonce'],
      ),
      payloadCiphertext: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}payload_ciphertext'],
      ),
    );
  }

  @override
  $OfflineSetProjectionsTable createAlias(String alias) {
    return $OfflineSetProjectionsTable(attachedDatabase, alias);
  }
}

class OfflineSetProjection extends DataClass
    implements Insertable<OfflineSetProjection> {
  final String operationId;
  final String ownerId;
  final String workoutId;
  final String? payloadJson;
  final int? payloadCipherVersion;
  final int? payloadKeyVersion;
  final Uint8List? payloadNonce;
  final Uint8List? payloadCiphertext;
  const OfflineSetProjection({
    required this.operationId,
    required this.ownerId,
    required this.workoutId,
    this.payloadJson,
    this.payloadCipherVersion,
    this.payloadKeyVersion,
    this.payloadNonce,
    this.payloadCiphertext,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['owner_id'] = Variable<String>(ownerId);
    map['workout_id'] = Variable<String>(workoutId);
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    if (!nullToAbsent || payloadCipherVersion != null) {
      map['payload_cipher_version'] = Variable<int>(payloadCipherVersion);
    }
    if (!nullToAbsent || payloadKeyVersion != null) {
      map['payload_key_version'] = Variable<int>(payloadKeyVersion);
    }
    if (!nullToAbsent || payloadNonce != null) {
      map['payload_nonce'] = Variable<Uint8List>(payloadNonce);
    }
    if (!nullToAbsent || payloadCiphertext != null) {
      map['payload_ciphertext'] = Variable<Uint8List>(payloadCiphertext);
    }
    return map;
  }

  OfflineSetProjectionsCompanion toCompanion(bool nullToAbsent) {
    return OfflineSetProjectionsCompanion(
      operationId: Value(operationId),
      ownerId: Value(ownerId),
      workoutId: Value(workoutId),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      payloadCipherVersion: payloadCipherVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadCipherVersion),
      payloadKeyVersion: payloadKeyVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadKeyVersion),
      payloadNonce: payloadNonce == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadNonce),
      payloadCiphertext: payloadCiphertext == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadCiphertext),
    );
  }

  factory OfflineSetProjection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineSetProjection(
      operationId: serializer.fromJson<String>(json['operationId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      workoutId: serializer.fromJson<String>(json['workoutId']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      payloadCipherVersion: serializer.fromJson<int?>(
        json['payloadCipherVersion'],
      ),
      payloadKeyVersion: serializer.fromJson<int?>(json['payloadKeyVersion']),
      payloadNonce: serializer.fromJson<Uint8List?>(json['payloadNonce']),
      payloadCiphertext: serializer.fromJson<Uint8List?>(
        json['payloadCiphertext'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'ownerId': serializer.toJson<String>(ownerId),
      'workoutId': serializer.toJson<String>(workoutId),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'payloadCipherVersion': serializer.toJson<int?>(payloadCipherVersion),
      'payloadKeyVersion': serializer.toJson<int?>(payloadKeyVersion),
      'payloadNonce': serializer.toJson<Uint8List?>(payloadNonce),
      'payloadCiphertext': serializer.toJson<Uint8List?>(payloadCiphertext),
    };
  }

  OfflineSetProjection copyWith({
    String? operationId,
    String? ownerId,
    String? workoutId,
    Value<String?> payloadJson = const Value.absent(),
    Value<int?> payloadCipherVersion = const Value.absent(),
    Value<int?> payloadKeyVersion = const Value.absent(),
    Value<Uint8List?> payloadNonce = const Value.absent(),
    Value<Uint8List?> payloadCiphertext = const Value.absent(),
  }) => OfflineSetProjection(
    operationId: operationId ?? this.operationId,
    ownerId: ownerId ?? this.ownerId,
    workoutId: workoutId ?? this.workoutId,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
    payloadCipherVersion: payloadCipherVersion.present
        ? payloadCipherVersion.value
        : this.payloadCipherVersion,
    payloadKeyVersion: payloadKeyVersion.present
        ? payloadKeyVersion.value
        : this.payloadKeyVersion,
    payloadNonce: payloadNonce.present ? payloadNonce.value : this.payloadNonce,
    payloadCiphertext: payloadCiphertext.present
        ? payloadCiphertext.value
        : this.payloadCiphertext,
  );
  OfflineSetProjection copyWithCompanion(OfflineSetProjectionsCompanion data) {
    return OfflineSetProjection(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      payloadCipherVersion: data.payloadCipherVersion.present
          ? data.payloadCipherVersion.value
          : this.payloadCipherVersion,
      payloadKeyVersion: data.payloadKeyVersion.present
          ? data.payloadKeyVersion.value
          : this.payloadKeyVersion,
      payloadNonce: data.payloadNonce.present
          ? data.payloadNonce.value
          : this.payloadNonce,
      payloadCiphertext: data.payloadCiphertext.present
          ? data.payloadCiphertext.value
          : this.payloadCiphertext,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineSetProjection(')
          ..write('operationId: $operationId, ')
          ..write('ownerId: $ownerId, ')
          ..write('workoutId: $workoutId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('payloadCipherVersion: $payloadCipherVersion, ')
          ..write('payloadKeyVersion: $payloadKeyVersion, ')
          ..write('payloadNonce: $payloadNonce, ')
          ..write('payloadCiphertext: $payloadCiphertext')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    operationId,
    ownerId,
    workoutId,
    payloadJson,
    payloadCipherVersion,
    payloadKeyVersion,
    $driftBlobEquality.hash(payloadNonce),
    $driftBlobEquality.hash(payloadCiphertext),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineSetProjection &&
          other.operationId == this.operationId &&
          other.ownerId == this.ownerId &&
          other.workoutId == this.workoutId &&
          other.payloadJson == this.payloadJson &&
          other.payloadCipherVersion == this.payloadCipherVersion &&
          other.payloadKeyVersion == this.payloadKeyVersion &&
          $driftBlobEquality.equals(other.payloadNonce, this.payloadNonce) &&
          $driftBlobEquality.equals(
            other.payloadCiphertext,
            this.payloadCiphertext,
          ));
}

class OfflineSetProjectionsCompanion
    extends UpdateCompanion<OfflineSetProjection> {
  final Value<String> operationId;
  final Value<String> ownerId;
  final Value<String> workoutId;
  final Value<String?> payloadJson;
  final Value<int?> payloadCipherVersion;
  final Value<int?> payloadKeyVersion;
  final Value<Uint8List?> payloadNonce;
  final Value<Uint8List?> payloadCiphertext;
  final Value<int> rowid;
  const OfflineSetProjectionsCompanion({
    this.operationId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.payloadCipherVersion = const Value.absent(),
    this.payloadKeyVersion = const Value.absent(),
    this.payloadNonce = const Value.absent(),
    this.payloadCiphertext = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineSetProjectionsCompanion.insert({
    required String operationId,
    required String ownerId,
    required String workoutId,
    this.payloadJson = const Value.absent(),
    this.payloadCipherVersion = const Value.absent(),
    this.payloadKeyVersion = const Value.absent(),
    this.payloadNonce = const Value.absent(),
    this.payloadCiphertext = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       ownerId = Value(ownerId),
       workoutId = Value(workoutId);
  static Insertable<OfflineSetProjection> custom({
    Expression<String>? operationId,
    Expression<String>? ownerId,
    Expression<String>? workoutId,
    Expression<String>? payloadJson,
    Expression<int>? payloadCipherVersion,
    Expression<int>? payloadKeyVersion,
    Expression<Uint8List>? payloadNonce,
    Expression<Uint8List>? payloadCiphertext,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (ownerId != null) 'owner_id': ownerId,
      if (workoutId != null) 'workout_id': workoutId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (payloadCipherVersion != null)
        'payload_cipher_version': payloadCipherVersion,
      if (payloadKeyVersion != null) 'payload_key_version': payloadKeyVersion,
      if (payloadNonce != null) 'payload_nonce': payloadNonce,
      if (payloadCiphertext != null) 'payload_ciphertext': payloadCiphertext,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineSetProjectionsCompanion copyWith({
    Value<String>? operationId,
    Value<String>? ownerId,
    Value<String>? workoutId,
    Value<String?>? payloadJson,
    Value<int?>? payloadCipherVersion,
    Value<int?>? payloadKeyVersion,
    Value<Uint8List?>? payloadNonce,
    Value<Uint8List?>? payloadCiphertext,
    Value<int>? rowid,
  }) {
    return OfflineSetProjectionsCompanion(
      operationId: operationId ?? this.operationId,
      ownerId: ownerId ?? this.ownerId,
      workoutId: workoutId ?? this.workoutId,
      payloadJson: payloadJson ?? this.payloadJson,
      payloadCipherVersion: payloadCipherVersion ?? this.payloadCipherVersion,
      payloadKeyVersion: payloadKeyVersion ?? this.payloadKeyVersion,
      payloadNonce: payloadNonce ?? this.payloadNonce,
      payloadCiphertext: payloadCiphertext ?? this.payloadCiphertext,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (payloadCipherVersion.present) {
      map['payload_cipher_version'] = Variable<int>(payloadCipherVersion.value);
    }
    if (payloadKeyVersion.present) {
      map['payload_key_version'] = Variable<int>(payloadKeyVersion.value);
    }
    if (payloadNonce.present) {
      map['payload_nonce'] = Variable<Uint8List>(payloadNonce.value);
    }
    if (payloadCiphertext.present) {
      map['payload_ciphertext'] = Variable<Uint8List>(payloadCiphertext.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineSetProjectionsCompanion(')
          ..write('operationId: $operationId, ')
          ..write('ownerId: $ownerId, ')
          ..write('workoutId: $workoutId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('payloadCipherVersion: $payloadCipherVersion, ')
          ..write('payloadKeyVersion: $payloadKeyVersion, ')
          ..write('payloadNonce: $payloadNonce, ')
          ..write('payloadCiphertext: $payloadCiphertext, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineWriteIntentsTable extends OfflineWriteIntents
    with TableInfo<$OfflineWriteIntentsTable, OfflineWriteIntent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineWriteIntentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  );
  static const VerificationMeta _contractVersionMeta = const VerificationMeta(
    'contractVersion',
  );
  @override
  late final GeneratedColumn<int> contractVersion = GeneratedColumn<int>(
    'contract_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mutationKindMeta = const VerificationMeta(
    'mutationKind',
  );
  @override
  late final GeneratedColumn<String> mutationKind = GeneratedColumn<String>(
    'mutation_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadCipherVersionMeta =
      const VerificationMeta('payloadCipherVersion');
  @override
  late final GeneratedColumn<int> payloadCipherVersion = GeneratedColumn<int>(
    'payload_cipher_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadKeyVersionMeta = const VerificationMeta(
    'payloadKeyVersion',
  );
  @override
  late final GeneratedColumn<int> payloadKeyVersion = GeneratedColumn<int>(
    'payload_key_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadNonceMeta = const VerificationMeta(
    'payloadNonce',
  );
  @override
  late final GeneratedColumn<Uint8List> payloadNonce =
      GeneratedColumn<Uint8List>(
        'payload_nonce',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _payloadCiphertextMeta = const VerificationMeta(
    'payloadCiphertext',
  );
  @override
  late final GeneratedColumn<Uint8List> payloadCiphertext =
      GeneratedColumn<Uint8List>(
        'payload_ciphertext',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _payloadFingerprintMeta =
      const VerificationMeta('payloadFingerprint');
  @override
  late final GeneratedColumn<String> payloadFingerprint =
      GeneratedColumn<String>(
        'payload_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
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
  static const VerificationMeta _nextAttemptAtUtcMillisMeta =
      const VerificationMeta('nextAttemptAtUtcMillis');
  @override
  late final GeneratedColumn<int> nextAttemptAtUtcMillis = GeneratedColumn<int>(
    'next_attempt_at_utc_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMillisMeta =
      const VerificationMeta('createdAtUtcMillis');
  @override
  late final GeneratedColumn<int> createdAtUtcMillis = GeneratedColumn<int>(
    'created_at_utc_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    ownerId,
    workoutId,
    contractVersion,
    mutationKind,
    payloadJson,
    payloadCipherVersion,
    payloadKeyVersion,
    payloadNonce,
    payloadCiphertext,
    payloadFingerprint,
    state,
    attemptCount,
    nextAttemptAtUtcMillis,
    createdAtUtcMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_write_intents';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfflineWriteIntent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('contract_version')) {
      context.handle(
        _contractVersionMeta,
        contractVersion.isAcceptableOrUnknown(
          data['contract_version']!,
          _contractVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contractVersionMeta);
    }
    if (data.containsKey('mutation_kind')) {
      context.handle(
        _mutationKindMeta,
        mutationKind.isAcceptableOrUnknown(
          data['mutation_kind']!,
          _mutationKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mutationKindMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('payload_cipher_version')) {
      context.handle(
        _payloadCipherVersionMeta,
        payloadCipherVersion.isAcceptableOrUnknown(
          data['payload_cipher_version']!,
          _payloadCipherVersionMeta,
        ),
      );
    }
    if (data.containsKey('payload_key_version')) {
      context.handle(
        _payloadKeyVersionMeta,
        payloadKeyVersion.isAcceptableOrUnknown(
          data['payload_key_version']!,
          _payloadKeyVersionMeta,
        ),
      );
    }
    if (data.containsKey('payload_nonce')) {
      context.handle(
        _payloadNonceMeta,
        payloadNonce.isAcceptableOrUnknown(
          data['payload_nonce']!,
          _payloadNonceMeta,
        ),
      );
    }
    if (data.containsKey('payload_ciphertext')) {
      context.handle(
        _payloadCiphertextMeta,
        payloadCiphertext.isAcceptableOrUnknown(
          data['payload_ciphertext']!,
          _payloadCiphertextMeta,
        ),
      );
    }
    if (data.containsKey('payload_fingerprint')) {
      context.handle(
        _payloadFingerprintMeta,
        payloadFingerprint.isAcceptableOrUnknown(
          data['payload_fingerprint']!,
          _payloadFingerprintMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
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
    if (data.containsKey('next_attempt_at_utc_millis')) {
      context.handle(
        _nextAttemptAtUtcMillisMeta,
        nextAttemptAtUtcMillis.isAcceptableOrUnknown(
          data['next_attempt_at_utc_millis']!,
          _nextAttemptAtUtcMillisMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc_millis')) {
      context.handle(
        _createdAtUtcMillisMeta,
        createdAtUtcMillis.isAcceptableOrUnknown(
          data['created_at_utc_millis']!,
          _createdAtUtcMillisMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  OfflineWriteIntent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineWriteIntent(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_id'],
      )!,
      contractVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contract_version'],
      )!,
      mutationKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_kind'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
      payloadCipherVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_cipher_version'],
      ),
      payloadKeyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_key_version'],
      ),
      payloadNonce: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}payload_nonce'],
      ),
      payloadCiphertext: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}payload_ciphertext'],
      ),
      payloadFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_fingerprint'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      nextAttemptAtUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_attempt_at_utc_millis'],
      ),
      createdAtUtcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_utc_millis'],
      )!,
    );
  }

  @override
  $OfflineWriteIntentsTable createAlias(String alias) {
    return $OfflineWriteIntentsTable(attachedDatabase, alias);
  }
}

class OfflineWriteIntent extends DataClass
    implements Insertable<OfflineWriteIntent> {
  final String operationId;
  final String ownerId;
  final String workoutId;
  final int contractVersion;
  final String mutationKind;
  final String? payloadJson;
  final int? payloadCipherVersion;
  final int? payloadKeyVersion;
  final Uint8List? payloadNonce;
  final Uint8List? payloadCiphertext;
  final String payloadFingerprint;
  final String state;
  final int attemptCount;
  final int? nextAttemptAtUtcMillis;
  final int createdAtUtcMillis;
  const OfflineWriteIntent({
    required this.operationId,
    required this.ownerId,
    required this.workoutId,
    required this.contractVersion,
    required this.mutationKind,
    this.payloadJson,
    this.payloadCipherVersion,
    this.payloadKeyVersion,
    this.payloadNonce,
    this.payloadCiphertext,
    required this.payloadFingerprint,
    required this.state,
    required this.attemptCount,
    this.nextAttemptAtUtcMillis,
    required this.createdAtUtcMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['owner_id'] = Variable<String>(ownerId);
    map['workout_id'] = Variable<String>(workoutId);
    map['contract_version'] = Variable<int>(contractVersion);
    map['mutation_kind'] = Variable<String>(mutationKind);
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    if (!nullToAbsent || payloadCipherVersion != null) {
      map['payload_cipher_version'] = Variable<int>(payloadCipherVersion);
    }
    if (!nullToAbsent || payloadKeyVersion != null) {
      map['payload_key_version'] = Variable<int>(payloadKeyVersion);
    }
    if (!nullToAbsent || payloadNonce != null) {
      map['payload_nonce'] = Variable<Uint8List>(payloadNonce);
    }
    if (!nullToAbsent || payloadCiphertext != null) {
      map['payload_ciphertext'] = Variable<Uint8List>(payloadCiphertext);
    }
    map['payload_fingerprint'] = Variable<String>(payloadFingerprint);
    map['state'] = Variable<String>(state);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || nextAttemptAtUtcMillis != null) {
      map['next_attempt_at_utc_millis'] = Variable<int>(nextAttemptAtUtcMillis);
    }
    map['created_at_utc_millis'] = Variable<int>(createdAtUtcMillis);
    return map;
  }

  OfflineWriteIntentsCompanion toCompanion(bool nullToAbsent) {
    return OfflineWriteIntentsCompanion(
      operationId: Value(operationId),
      ownerId: Value(ownerId),
      workoutId: Value(workoutId),
      contractVersion: Value(contractVersion),
      mutationKind: Value(mutationKind),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      payloadCipherVersion: payloadCipherVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadCipherVersion),
      payloadKeyVersion: payloadKeyVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadKeyVersion),
      payloadNonce: payloadNonce == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadNonce),
      payloadCiphertext: payloadCiphertext == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadCiphertext),
      payloadFingerprint: Value(payloadFingerprint),
      state: Value(state),
      attemptCount: Value(attemptCount),
      nextAttemptAtUtcMillis: nextAttemptAtUtcMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAtUtcMillis),
      createdAtUtcMillis: Value(createdAtUtcMillis),
    );
  }

  factory OfflineWriteIntent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineWriteIntent(
      operationId: serializer.fromJson<String>(json['operationId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      workoutId: serializer.fromJson<String>(json['workoutId']),
      contractVersion: serializer.fromJson<int>(json['contractVersion']),
      mutationKind: serializer.fromJson<String>(json['mutationKind']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      payloadCipherVersion: serializer.fromJson<int?>(
        json['payloadCipherVersion'],
      ),
      payloadKeyVersion: serializer.fromJson<int?>(json['payloadKeyVersion']),
      payloadNonce: serializer.fromJson<Uint8List?>(json['payloadNonce']),
      payloadCiphertext: serializer.fromJson<Uint8List?>(
        json['payloadCiphertext'],
      ),
      payloadFingerprint: serializer.fromJson<String>(
        json['payloadFingerprint'],
      ),
      state: serializer.fromJson<String>(json['state']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      nextAttemptAtUtcMillis: serializer.fromJson<int?>(
        json['nextAttemptAtUtcMillis'],
      ),
      createdAtUtcMillis: serializer.fromJson<int>(json['createdAtUtcMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'ownerId': serializer.toJson<String>(ownerId),
      'workoutId': serializer.toJson<String>(workoutId),
      'contractVersion': serializer.toJson<int>(contractVersion),
      'mutationKind': serializer.toJson<String>(mutationKind),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'payloadCipherVersion': serializer.toJson<int?>(payloadCipherVersion),
      'payloadKeyVersion': serializer.toJson<int?>(payloadKeyVersion),
      'payloadNonce': serializer.toJson<Uint8List?>(payloadNonce),
      'payloadCiphertext': serializer.toJson<Uint8List?>(payloadCiphertext),
      'payloadFingerprint': serializer.toJson<String>(payloadFingerprint),
      'state': serializer.toJson<String>(state),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'nextAttemptAtUtcMillis': serializer.toJson<int?>(nextAttemptAtUtcMillis),
      'createdAtUtcMillis': serializer.toJson<int>(createdAtUtcMillis),
    };
  }

  OfflineWriteIntent copyWith({
    String? operationId,
    String? ownerId,
    String? workoutId,
    int? contractVersion,
    String? mutationKind,
    Value<String?> payloadJson = const Value.absent(),
    Value<int?> payloadCipherVersion = const Value.absent(),
    Value<int?> payloadKeyVersion = const Value.absent(),
    Value<Uint8List?> payloadNonce = const Value.absent(),
    Value<Uint8List?> payloadCiphertext = const Value.absent(),
    String? payloadFingerprint,
    String? state,
    int? attemptCount,
    Value<int?> nextAttemptAtUtcMillis = const Value.absent(),
    int? createdAtUtcMillis,
  }) => OfflineWriteIntent(
    operationId: operationId ?? this.operationId,
    ownerId: ownerId ?? this.ownerId,
    workoutId: workoutId ?? this.workoutId,
    contractVersion: contractVersion ?? this.contractVersion,
    mutationKind: mutationKind ?? this.mutationKind,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
    payloadCipherVersion: payloadCipherVersion.present
        ? payloadCipherVersion.value
        : this.payloadCipherVersion,
    payloadKeyVersion: payloadKeyVersion.present
        ? payloadKeyVersion.value
        : this.payloadKeyVersion,
    payloadNonce: payloadNonce.present ? payloadNonce.value : this.payloadNonce,
    payloadCiphertext: payloadCiphertext.present
        ? payloadCiphertext.value
        : this.payloadCiphertext,
    payloadFingerprint: payloadFingerprint ?? this.payloadFingerprint,
    state: state ?? this.state,
    attemptCount: attemptCount ?? this.attemptCount,
    nextAttemptAtUtcMillis: nextAttemptAtUtcMillis.present
        ? nextAttemptAtUtcMillis.value
        : this.nextAttemptAtUtcMillis,
    createdAtUtcMillis: createdAtUtcMillis ?? this.createdAtUtcMillis,
  );
  OfflineWriteIntent copyWithCompanion(OfflineWriteIntentsCompanion data) {
    return OfflineWriteIntent(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      contractVersion: data.contractVersion.present
          ? data.contractVersion.value
          : this.contractVersion,
      mutationKind: data.mutationKind.present
          ? data.mutationKind.value
          : this.mutationKind,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      payloadCipherVersion: data.payloadCipherVersion.present
          ? data.payloadCipherVersion.value
          : this.payloadCipherVersion,
      payloadKeyVersion: data.payloadKeyVersion.present
          ? data.payloadKeyVersion.value
          : this.payloadKeyVersion,
      payloadNonce: data.payloadNonce.present
          ? data.payloadNonce.value
          : this.payloadNonce,
      payloadCiphertext: data.payloadCiphertext.present
          ? data.payloadCiphertext.value
          : this.payloadCiphertext,
      payloadFingerprint: data.payloadFingerprint.present
          ? data.payloadFingerprint.value
          : this.payloadFingerprint,
      state: data.state.present ? data.state.value : this.state,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextAttemptAtUtcMillis: data.nextAttemptAtUtcMillis.present
          ? data.nextAttemptAtUtcMillis.value
          : this.nextAttemptAtUtcMillis,
      createdAtUtcMillis: data.createdAtUtcMillis.present
          ? data.createdAtUtcMillis.value
          : this.createdAtUtcMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineWriteIntent(')
          ..write('operationId: $operationId, ')
          ..write('ownerId: $ownerId, ')
          ..write('workoutId: $workoutId, ')
          ..write('contractVersion: $contractVersion, ')
          ..write('mutationKind: $mutationKind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('payloadCipherVersion: $payloadCipherVersion, ')
          ..write('payloadKeyVersion: $payloadKeyVersion, ')
          ..write('payloadNonce: $payloadNonce, ')
          ..write('payloadCiphertext: $payloadCiphertext, ')
          ..write('payloadFingerprint: $payloadFingerprint, ')
          ..write('state: $state, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAtUtcMillis: $nextAttemptAtUtcMillis, ')
          ..write('createdAtUtcMillis: $createdAtUtcMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    operationId,
    ownerId,
    workoutId,
    contractVersion,
    mutationKind,
    payloadJson,
    payloadCipherVersion,
    payloadKeyVersion,
    $driftBlobEquality.hash(payloadNonce),
    $driftBlobEquality.hash(payloadCiphertext),
    payloadFingerprint,
    state,
    attemptCount,
    nextAttemptAtUtcMillis,
    createdAtUtcMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineWriteIntent &&
          other.operationId == this.operationId &&
          other.ownerId == this.ownerId &&
          other.workoutId == this.workoutId &&
          other.contractVersion == this.contractVersion &&
          other.mutationKind == this.mutationKind &&
          other.payloadJson == this.payloadJson &&
          other.payloadCipherVersion == this.payloadCipherVersion &&
          other.payloadKeyVersion == this.payloadKeyVersion &&
          $driftBlobEquality.equals(other.payloadNonce, this.payloadNonce) &&
          $driftBlobEquality.equals(
            other.payloadCiphertext,
            this.payloadCiphertext,
          ) &&
          other.payloadFingerprint == this.payloadFingerprint &&
          other.state == this.state &&
          other.attemptCount == this.attemptCount &&
          other.nextAttemptAtUtcMillis == this.nextAttemptAtUtcMillis &&
          other.createdAtUtcMillis == this.createdAtUtcMillis);
}

class OfflineWriteIntentsCompanion extends UpdateCompanion<OfflineWriteIntent> {
  final Value<String> operationId;
  final Value<String> ownerId;
  final Value<String> workoutId;
  final Value<int> contractVersion;
  final Value<String> mutationKind;
  final Value<String?> payloadJson;
  final Value<int?> payloadCipherVersion;
  final Value<int?> payloadKeyVersion;
  final Value<Uint8List?> payloadNonce;
  final Value<Uint8List?> payloadCiphertext;
  final Value<String> payloadFingerprint;
  final Value<String> state;
  final Value<int> attemptCount;
  final Value<int?> nextAttemptAtUtcMillis;
  final Value<int> createdAtUtcMillis;
  final Value<int> rowid;
  const OfflineWriteIntentsCompanion({
    this.operationId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.contractVersion = const Value.absent(),
    this.mutationKind = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.payloadCipherVersion = const Value.absent(),
    this.payloadKeyVersion = const Value.absent(),
    this.payloadNonce = const Value.absent(),
    this.payloadCiphertext = const Value.absent(),
    this.payloadFingerprint = const Value.absent(),
    this.state = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAtUtcMillis = const Value.absent(),
    this.createdAtUtcMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineWriteIntentsCompanion.insert({
    required String operationId,
    required String ownerId,
    required String workoutId,
    required int contractVersion,
    required String mutationKind,
    this.payloadJson = const Value.absent(),
    this.payloadCipherVersion = const Value.absent(),
    this.payloadKeyVersion = const Value.absent(),
    this.payloadNonce = const Value.absent(),
    this.payloadCiphertext = const Value.absent(),
    this.payloadFingerprint = const Value.absent(),
    this.state = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAtUtcMillis = const Value.absent(),
    this.createdAtUtcMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       ownerId = Value(ownerId),
       workoutId = Value(workoutId),
       contractVersion = Value(contractVersion),
       mutationKind = Value(mutationKind);
  static Insertable<OfflineWriteIntent> custom({
    Expression<String>? operationId,
    Expression<String>? ownerId,
    Expression<String>? workoutId,
    Expression<int>? contractVersion,
    Expression<String>? mutationKind,
    Expression<String>? payloadJson,
    Expression<int>? payloadCipherVersion,
    Expression<int>? payloadKeyVersion,
    Expression<Uint8List>? payloadNonce,
    Expression<Uint8List>? payloadCiphertext,
    Expression<String>? payloadFingerprint,
    Expression<String>? state,
    Expression<int>? attemptCount,
    Expression<int>? nextAttemptAtUtcMillis,
    Expression<int>? createdAtUtcMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (ownerId != null) 'owner_id': ownerId,
      if (workoutId != null) 'workout_id': workoutId,
      if (contractVersion != null) 'contract_version': contractVersion,
      if (mutationKind != null) 'mutation_kind': mutationKind,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (payloadCipherVersion != null)
        'payload_cipher_version': payloadCipherVersion,
      if (payloadKeyVersion != null) 'payload_key_version': payloadKeyVersion,
      if (payloadNonce != null) 'payload_nonce': payloadNonce,
      if (payloadCiphertext != null) 'payload_ciphertext': payloadCiphertext,
      if (payloadFingerprint != null) 'payload_fingerprint': payloadFingerprint,
      if (state != null) 'state': state,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextAttemptAtUtcMillis != null)
        'next_attempt_at_utc_millis': nextAttemptAtUtcMillis,
      if (createdAtUtcMillis != null)
        'created_at_utc_millis': createdAtUtcMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineWriteIntentsCompanion copyWith({
    Value<String>? operationId,
    Value<String>? ownerId,
    Value<String>? workoutId,
    Value<int>? contractVersion,
    Value<String>? mutationKind,
    Value<String?>? payloadJson,
    Value<int?>? payloadCipherVersion,
    Value<int?>? payloadKeyVersion,
    Value<Uint8List?>? payloadNonce,
    Value<Uint8List?>? payloadCiphertext,
    Value<String>? payloadFingerprint,
    Value<String>? state,
    Value<int>? attemptCount,
    Value<int?>? nextAttemptAtUtcMillis,
    Value<int>? createdAtUtcMillis,
    Value<int>? rowid,
  }) {
    return OfflineWriteIntentsCompanion(
      operationId: operationId ?? this.operationId,
      ownerId: ownerId ?? this.ownerId,
      workoutId: workoutId ?? this.workoutId,
      contractVersion: contractVersion ?? this.contractVersion,
      mutationKind: mutationKind ?? this.mutationKind,
      payloadJson: payloadJson ?? this.payloadJson,
      payloadCipherVersion: payloadCipherVersion ?? this.payloadCipherVersion,
      payloadKeyVersion: payloadKeyVersion ?? this.payloadKeyVersion,
      payloadNonce: payloadNonce ?? this.payloadNonce,
      payloadCiphertext: payloadCiphertext ?? this.payloadCiphertext,
      payloadFingerprint: payloadFingerprint ?? this.payloadFingerprint,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAtUtcMillis:
          nextAttemptAtUtcMillis ?? this.nextAttemptAtUtcMillis,
      createdAtUtcMillis: createdAtUtcMillis ?? this.createdAtUtcMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (contractVersion.present) {
      map['contract_version'] = Variable<int>(contractVersion.value);
    }
    if (mutationKind.present) {
      map['mutation_kind'] = Variable<String>(mutationKind.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (payloadCipherVersion.present) {
      map['payload_cipher_version'] = Variable<int>(payloadCipherVersion.value);
    }
    if (payloadKeyVersion.present) {
      map['payload_key_version'] = Variable<int>(payloadKeyVersion.value);
    }
    if (payloadNonce.present) {
      map['payload_nonce'] = Variable<Uint8List>(payloadNonce.value);
    }
    if (payloadCiphertext.present) {
      map['payload_ciphertext'] = Variable<Uint8List>(payloadCiphertext.value);
    }
    if (payloadFingerprint.present) {
      map['payload_fingerprint'] = Variable<String>(payloadFingerprint.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextAttemptAtUtcMillis.present) {
      map['next_attempt_at_utc_millis'] = Variable<int>(
        nextAttemptAtUtcMillis.value,
      );
    }
    if (createdAtUtcMillis.present) {
      map['created_at_utc_millis'] = Variable<int>(createdAtUtcMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineWriteIntentsCompanion(')
          ..write('operationId: $operationId, ')
          ..write('ownerId: $ownerId, ')
          ..write('workoutId: $workoutId, ')
          ..write('contractVersion: $contractVersion, ')
          ..write('mutationKind: $mutationKind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('payloadCipherVersion: $payloadCipherVersion, ')
          ..write('payloadKeyVersion: $payloadKeyVersion, ')
          ..write('payloadNonce: $payloadNonce, ')
          ..write('payloadCiphertext: $payloadCiphertext, ')
          ..write('payloadFingerprint: $payloadFingerprint, ')
          ..write('state: $state, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAtUtcMillis: $nextAttemptAtUtcMillis, ')
          ..write('createdAtUtcMillis: $createdAtUtcMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$OfflineWorkoutStore extends GeneratedDatabase {
  _$OfflineWorkoutStore(QueryExecutor e) : super(e);
  $OfflineWorkoutStoreManager get managers => $OfflineWorkoutStoreManager(this);
  late final $OfflineSetProjectionsTable offlineSetProjections =
      $OfflineSetProjectionsTable(this);
  late final $OfflineWriteIntentsTable offlineWriteIntents =
      $OfflineWriteIntentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    offlineSetProjections,
    offlineWriteIntents,
  ];
}

typedef $$OfflineSetProjectionsTableCreateCompanionBuilder =
    OfflineSetProjectionsCompanion Function({
      required String operationId,
      required String ownerId,
      required String workoutId,
      Value<String?> payloadJson,
      Value<int?> payloadCipherVersion,
      Value<int?> payloadKeyVersion,
      Value<Uint8List?> payloadNonce,
      Value<Uint8List?> payloadCiphertext,
      Value<int> rowid,
    });
typedef $$OfflineSetProjectionsTableUpdateCompanionBuilder =
    OfflineSetProjectionsCompanion Function({
      Value<String> operationId,
      Value<String> ownerId,
      Value<String> workoutId,
      Value<String?> payloadJson,
      Value<int?> payloadCipherVersion,
      Value<int?> payloadKeyVersion,
      Value<Uint8List?> payloadNonce,
      Value<Uint8List?> payloadCiphertext,
      Value<int> rowid,
    });

class $$OfflineSetProjectionsTableFilterComposer
    extends Composer<_$OfflineWorkoutStore, $OfflineSetProjectionsTable> {
  $$OfflineSetProjectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workoutId => $composableBuilder(
    column: $table.workoutId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadCipherVersion => $composableBuilder(
    column: $table.payloadCipherVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadKeyVersion => $composableBuilder(
    column: $table.payloadKeyVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get payloadNonce => $composableBuilder(
    column: $table.payloadNonce,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get payloadCiphertext => $composableBuilder(
    column: $table.payloadCiphertext,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfflineSetProjectionsTableOrderingComposer
    extends Composer<_$OfflineWorkoutStore, $OfflineSetProjectionsTable> {
  $$OfflineSetProjectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workoutId => $composableBuilder(
    column: $table.workoutId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadCipherVersion => $composableBuilder(
    column: $table.payloadCipherVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadKeyVersion => $composableBuilder(
    column: $table.payloadKeyVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get payloadNonce => $composableBuilder(
    column: $table.payloadNonce,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get payloadCiphertext => $composableBuilder(
    column: $table.payloadCiphertext,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfflineSetProjectionsTableAnnotationComposer
    extends Composer<_$OfflineWorkoutStore, $OfflineSetProjectionsTable> {
  $$OfflineSetProjectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get workoutId =>
      $composableBuilder(column: $table.workoutId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get payloadCipherVersion => $composableBuilder(
    column: $table.payloadCipherVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get payloadKeyVersion => $composableBuilder(
    column: $table.payloadKeyVersion,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get payloadNonce => $composableBuilder(
    column: $table.payloadNonce,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get payloadCiphertext => $composableBuilder(
    column: $table.payloadCiphertext,
    builder: (column) => column,
  );
}

class $$OfflineSetProjectionsTableTableManager
    extends
        RootTableManager<
          _$OfflineWorkoutStore,
          $OfflineSetProjectionsTable,
          OfflineSetProjection,
          $$OfflineSetProjectionsTableFilterComposer,
          $$OfflineSetProjectionsTableOrderingComposer,
          $$OfflineSetProjectionsTableAnnotationComposer,
          $$OfflineSetProjectionsTableCreateCompanionBuilder,
          $$OfflineSetProjectionsTableUpdateCompanionBuilder,
          (
            OfflineSetProjection,
            BaseReferences<
              _$OfflineWorkoutStore,
              $OfflineSetProjectionsTable,
              OfflineSetProjection
            >,
          ),
          OfflineSetProjection,
          PrefetchHooks Function()
        > {
  $$OfflineSetProjectionsTableTableManager(
    _$OfflineWorkoutStore db,
    $OfflineSetProjectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineSetProjectionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$OfflineSetProjectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OfflineSetProjectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> workoutId = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<int?> payloadCipherVersion = const Value.absent(),
                Value<int?> payloadKeyVersion = const Value.absent(),
                Value<Uint8List?> payloadNonce = const Value.absent(),
                Value<Uint8List?> payloadCiphertext = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfflineSetProjectionsCompanion(
                operationId: operationId,
                ownerId: ownerId,
                workoutId: workoutId,
                payloadJson: payloadJson,
                payloadCipherVersion: payloadCipherVersion,
                payloadKeyVersion: payloadKeyVersion,
                payloadNonce: payloadNonce,
                payloadCiphertext: payloadCiphertext,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String ownerId,
                required String workoutId,
                Value<String?> payloadJson = const Value.absent(),
                Value<int?> payloadCipherVersion = const Value.absent(),
                Value<int?> payloadKeyVersion = const Value.absent(),
                Value<Uint8List?> payloadNonce = const Value.absent(),
                Value<Uint8List?> payloadCiphertext = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfflineSetProjectionsCompanion.insert(
                operationId: operationId,
                ownerId: ownerId,
                workoutId: workoutId,
                payloadJson: payloadJson,
                payloadCipherVersion: payloadCipherVersion,
                payloadKeyVersion: payloadKeyVersion,
                payloadNonce: payloadNonce,
                payloadCiphertext: payloadCiphertext,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfflineSetProjectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineWorkoutStore,
      $OfflineSetProjectionsTable,
      OfflineSetProjection,
      $$OfflineSetProjectionsTableFilterComposer,
      $$OfflineSetProjectionsTableOrderingComposer,
      $$OfflineSetProjectionsTableAnnotationComposer,
      $$OfflineSetProjectionsTableCreateCompanionBuilder,
      $$OfflineSetProjectionsTableUpdateCompanionBuilder,
      (
        OfflineSetProjection,
        BaseReferences<
          _$OfflineWorkoutStore,
          $OfflineSetProjectionsTable,
          OfflineSetProjection
        >,
      ),
      OfflineSetProjection,
      PrefetchHooks Function()
    >;
typedef $$OfflineWriteIntentsTableCreateCompanionBuilder =
    OfflineWriteIntentsCompanion Function({
      required String operationId,
      required String ownerId,
      required String workoutId,
      required int contractVersion,
      required String mutationKind,
      Value<String?> payloadJson,
      Value<int?> payloadCipherVersion,
      Value<int?> payloadKeyVersion,
      Value<Uint8List?> payloadNonce,
      Value<Uint8List?> payloadCiphertext,
      Value<String> payloadFingerprint,
      Value<String> state,
      Value<int> attemptCount,
      Value<int?> nextAttemptAtUtcMillis,
      Value<int> createdAtUtcMillis,
      Value<int> rowid,
    });
typedef $$OfflineWriteIntentsTableUpdateCompanionBuilder =
    OfflineWriteIntentsCompanion Function({
      Value<String> operationId,
      Value<String> ownerId,
      Value<String> workoutId,
      Value<int> contractVersion,
      Value<String> mutationKind,
      Value<String?> payloadJson,
      Value<int?> payloadCipherVersion,
      Value<int?> payloadKeyVersion,
      Value<Uint8List?> payloadNonce,
      Value<Uint8List?> payloadCiphertext,
      Value<String> payloadFingerprint,
      Value<String> state,
      Value<int> attemptCount,
      Value<int?> nextAttemptAtUtcMillis,
      Value<int> createdAtUtcMillis,
      Value<int> rowid,
    });

class $$OfflineWriteIntentsTableFilterComposer
    extends Composer<_$OfflineWorkoutStore, $OfflineWriteIntentsTable> {
  $$OfflineWriteIntentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workoutId => $composableBuilder(
    column: $table.workoutId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contractVersion => $composableBuilder(
    column: $table.contractVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationKind => $composableBuilder(
    column: $table.mutationKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadCipherVersion => $composableBuilder(
    column: $table.payloadCipherVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadKeyVersion => $composableBuilder(
    column: $table.payloadKeyVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get payloadNonce => $composableBuilder(
    column: $table.payloadNonce,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get payloadCiphertext => $composableBuilder(
    column: $table.payloadCiphertext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadFingerprint => $composableBuilder(
    column: $table.payloadFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextAttemptAtUtcMillis => $composableBuilder(
    column: $table.nextAttemptAtUtcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtUtcMillis => $composableBuilder(
    column: $table.createdAtUtcMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfflineWriteIntentsTableOrderingComposer
    extends Composer<_$OfflineWorkoutStore, $OfflineWriteIntentsTable> {
  $$OfflineWriteIntentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workoutId => $composableBuilder(
    column: $table.workoutId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contractVersion => $composableBuilder(
    column: $table.contractVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationKind => $composableBuilder(
    column: $table.mutationKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadCipherVersion => $composableBuilder(
    column: $table.payloadCipherVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadKeyVersion => $composableBuilder(
    column: $table.payloadKeyVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get payloadNonce => $composableBuilder(
    column: $table.payloadNonce,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get payloadCiphertext => $composableBuilder(
    column: $table.payloadCiphertext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadFingerprint => $composableBuilder(
    column: $table.payloadFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextAttemptAtUtcMillis => $composableBuilder(
    column: $table.nextAttemptAtUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtUtcMillis => $composableBuilder(
    column: $table.createdAtUtcMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfflineWriteIntentsTableAnnotationComposer
    extends Composer<_$OfflineWorkoutStore, $OfflineWriteIntentsTable> {
  $$OfflineWriteIntentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get workoutId =>
      $composableBuilder(column: $table.workoutId, builder: (column) => column);

  GeneratedColumn<int> get contractVersion => $composableBuilder(
    column: $table.contractVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mutationKind => $composableBuilder(
    column: $table.mutationKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get payloadCipherVersion => $composableBuilder(
    column: $table.payloadCipherVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get payloadKeyVersion => $composableBuilder(
    column: $table.payloadKeyVersion,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get payloadNonce => $composableBuilder(
    column: $table.payloadNonce,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get payloadCiphertext => $composableBuilder(
    column: $table.payloadCiphertext,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadFingerprint => $composableBuilder(
    column: $table.payloadFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextAttemptAtUtcMillis => $composableBuilder(
    column: $table.nextAttemptAtUtcMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtUtcMillis => $composableBuilder(
    column: $table.createdAtUtcMillis,
    builder: (column) => column,
  );
}

class $$OfflineWriteIntentsTableTableManager
    extends
        RootTableManager<
          _$OfflineWorkoutStore,
          $OfflineWriteIntentsTable,
          OfflineWriteIntent,
          $$OfflineWriteIntentsTableFilterComposer,
          $$OfflineWriteIntentsTableOrderingComposer,
          $$OfflineWriteIntentsTableAnnotationComposer,
          $$OfflineWriteIntentsTableCreateCompanionBuilder,
          $$OfflineWriteIntentsTableUpdateCompanionBuilder,
          (
            OfflineWriteIntent,
            BaseReferences<
              _$OfflineWorkoutStore,
              $OfflineWriteIntentsTable,
              OfflineWriteIntent
            >,
          ),
          OfflineWriteIntent,
          PrefetchHooks Function()
        > {
  $$OfflineWriteIntentsTableTableManager(
    _$OfflineWorkoutStore db,
    $OfflineWriteIntentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineWriteIntentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineWriteIntentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OfflineWriteIntentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> workoutId = const Value.absent(),
                Value<int> contractVersion = const Value.absent(),
                Value<String> mutationKind = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<int?> payloadCipherVersion = const Value.absent(),
                Value<int?> payloadKeyVersion = const Value.absent(),
                Value<Uint8List?> payloadNonce = const Value.absent(),
                Value<Uint8List?> payloadCiphertext = const Value.absent(),
                Value<String> payloadFingerprint = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int?> nextAttemptAtUtcMillis = const Value.absent(),
                Value<int> createdAtUtcMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfflineWriteIntentsCompanion(
                operationId: operationId,
                ownerId: ownerId,
                workoutId: workoutId,
                contractVersion: contractVersion,
                mutationKind: mutationKind,
                payloadJson: payloadJson,
                payloadCipherVersion: payloadCipherVersion,
                payloadKeyVersion: payloadKeyVersion,
                payloadNonce: payloadNonce,
                payloadCiphertext: payloadCiphertext,
                payloadFingerprint: payloadFingerprint,
                state: state,
                attemptCount: attemptCount,
                nextAttemptAtUtcMillis: nextAttemptAtUtcMillis,
                createdAtUtcMillis: createdAtUtcMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String ownerId,
                required String workoutId,
                required int contractVersion,
                required String mutationKind,
                Value<String?> payloadJson = const Value.absent(),
                Value<int?> payloadCipherVersion = const Value.absent(),
                Value<int?> payloadKeyVersion = const Value.absent(),
                Value<Uint8List?> payloadNonce = const Value.absent(),
                Value<Uint8List?> payloadCiphertext = const Value.absent(),
                Value<String> payloadFingerprint = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int?> nextAttemptAtUtcMillis = const Value.absent(),
                Value<int> createdAtUtcMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfflineWriteIntentsCompanion.insert(
                operationId: operationId,
                ownerId: ownerId,
                workoutId: workoutId,
                contractVersion: contractVersion,
                mutationKind: mutationKind,
                payloadJson: payloadJson,
                payloadCipherVersion: payloadCipherVersion,
                payloadKeyVersion: payloadKeyVersion,
                payloadNonce: payloadNonce,
                payloadCiphertext: payloadCiphertext,
                payloadFingerprint: payloadFingerprint,
                state: state,
                attemptCount: attemptCount,
                nextAttemptAtUtcMillis: nextAttemptAtUtcMillis,
                createdAtUtcMillis: createdAtUtcMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfflineWriteIntentsTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineWorkoutStore,
      $OfflineWriteIntentsTable,
      OfflineWriteIntent,
      $$OfflineWriteIntentsTableFilterComposer,
      $$OfflineWriteIntentsTableOrderingComposer,
      $$OfflineWriteIntentsTableAnnotationComposer,
      $$OfflineWriteIntentsTableCreateCompanionBuilder,
      $$OfflineWriteIntentsTableUpdateCompanionBuilder,
      (
        OfflineWriteIntent,
        BaseReferences<
          _$OfflineWorkoutStore,
          $OfflineWriteIntentsTable,
          OfflineWriteIntent
        >,
      ),
      OfflineWriteIntent,
      PrefetchHooks Function()
    >;

class $OfflineWorkoutStoreManager {
  final _$OfflineWorkoutStore _db;
  $OfflineWorkoutStoreManager(this._db);
  $$OfflineSetProjectionsTableTableManager get offlineSetProjections =>
      $$OfflineSetProjectionsTableTableManager(_db, _db.offlineSetProjections);
  $$OfflineWriteIntentsTableTableManager get offlineWriteIntents =>
      $$OfflineWriteIntentsTableTableManager(_db, _db.offlineWriteIntents);
}
