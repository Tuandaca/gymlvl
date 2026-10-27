// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Exercise {
  String get id;
  String get name;
  String get category;
  String get equipment;
  @JsonKey(name: 'force_type')
  String? get forceType;
  String? get mechanic;
  List<String> get instructions;
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @JsonKey(name: 'slug')
  String? get slug;
  @JsonKey(name: 'name_vi')
  String get nameVi;
  @JsonKey(name: 'name_en')
  String get nameEn;
  @JsonKey(name: 'movement_pattern')
  String? get movementPattern;
  @JsonKey(name: 'secondary_muscles')
  List<String> get secondaryMuscles;
  String? get difficulty;
  @JsonKey(name: 'form_cues')
  List<String> get formCues;
  @JsonKey(name: 'common_mistakes')
  List<String> get commonMistakes;
  @JsonKey(name: 'alternative_exercise_slugs')
  List<String> get alternativeExerciseSlugs;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExerciseCopyWith<Exercise> get copyWith =>
      _$ExerciseCopyWithImpl<Exercise>(this as Exercise, _$identity);

  /// Serializes this Exercise to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Exercise &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.equipment, equipment) ||
                other.equipment == equipment) &&
            (identical(other.forceType, forceType) ||
                other.forceType == forceType) &&
            (identical(other.mechanic, mechanic) ||
                other.mechanic == mechanic) &&
            const DeepCollectionEquality().equals(
              other.instructions,
              instructions,
            ) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.nameVi, nameVi) || other.nameVi == nameVi) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.movementPattern, movementPattern) ||
                other.movementPattern == movementPattern) &&
            const DeepCollectionEquality().equals(
              other.secondaryMuscles,
              secondaryMuscles,
            ) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality().equals(other.formCues, formCues) &&
            const DeepCollectionEquality().equals(
              other.commonMistakes,
              commonMistakes,
            ) &&
            const DeepCollectionEquality().equals(
              other.alternativeExerciseSlugs,
              alternativeExerciseSlugs,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    category,
    equipment,
    forceType,
    mechanic,
    const DeepCollectionEquality().hash(instructions),
    imageUrl,
    slug,
    nameVi,
    nameEn,
    movementPattern,
    const DeepCollectionEquality().hash(secondaryMuscles),
    difficulty,
    const DeepCollectionEquality().hash(formCues),
    const DeepCollectionEquality().hash(commonMistakes),
    const DeepCollectionEquality().hash(alternativeExerciseSlugs),
    createdAt,
    updatedAt,
  );

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, category: $category, equipment: $equipment, forceType: $forceType, mechanic: $mechanic, instructions: $instructions, imageUrl: $imageUrl, slug: $slug, nameVi: $nameVi, nameEn: $nameEn, movementPattern: $movementPattern, secondaryMuscles: $secondaryMuscles, difficulty: $difficulty, formCues: $formCues, commonMistakes: $commonMistakes, alternativeExerciseSlugs: $alternativeExerciseSlugs, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $ExerciseCopyWith<$Res> {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) _then) =
      _$ExerciseCopyWithImpl;
  @useResult
  $Res call({
    String id,
    String name,
    String category,
    String equipment,
    @JsonKey(name: 'force_type') String? forceType,
    String? mechanic,
    List<String> instructions,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'slug') String? slug,
    @JsonKey(name: 'name_vi') String nameVi,
    @JsonKey(name: 'name_en') String nameEn,
    @JsonKey(name: 'movement_pattern') String? movementPattern,
    @JsonKey(name: 'secondary_muscles') List<String> secondaryMuscles,
    String? difficulty,
    @JsonKey(name: 'form_cues') List<String> formCues,
    @JsonKey(name: 'common_mistakes') List<String> commonMistakes,
    @JsonKey(name: 'alternative_exercise_slugs')
    List<String> alternativeExerciseSlugs,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$ExerciseCopyWithImpl<$Res> implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._self, this._then);

  final Exercise _self;
  final $Res Function(Exercise) _then;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? equipment = null,
    Object? forceType = freezed,
    Object? mechanic = freezed,
    Object? instructions = null,
    Object? imageUrl = freezed,
    Object? slug = freezed,
    Object? nameVi = null,
    Object? nameEn = null,
    Object? movementPattern = freezed,
    Object? secondaryMuscles = null,
    Object? difficulty = freezed,
    Object? formCues = null,
    Object? commonMistakes = null,
    Object? alternativeExerciseSlugs = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id ? _self.id : id as String,
        name: null == name ? _self.name : name as String,
        category: null == category ? _self.category : category as String,
        equipment: null == equipment ? _self.equipment : equipment as String,
        forceType: freezed == forceType ? _self.forceType : forceType as String?,
        mechanic: freezed == mechanic ? _self.mechanic : mechanic as String?,
        instructions: null == instructions
            ? _self.instructions
            : instructions as List<String>,
        imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl as String?,
        slug: freezed == slug ? _self.slug : slug as String?,
        nameVi: null == nameVi ? _self.nameVi : nameVi as String,
        nameEn: null == nameEn ? _self.nameEn : nameEn as String,
        movementPattern: freezed == movementPattern
            ? _self.movementPattern
            : movementPattern as String?,
        secondaryMuscles: null == secondaryMuscles
            ? _self.secondaryMuscles
            : secondaryMuscles as List<String>,
        difficulty: freezed == difficulty
            ? _self.difficulty
            : difficulty as String?,
        formCues: null == formCues ? _self.formCues : formCues as List<String>,
        commonMistakes: null == commonMistakes
            ? _self.commonMistakes
            : commonMistakes as List<String>,
        alternativeExerciseSlugs: null == alternativeExerciseSlugs
            ? _self.alternativeExerciseSlugs
            : alternativeExerciseSlugs as List<String>,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt as DateTime?,
        updatedAt: freezed == updatedAt
            ? _self.updatedAt
            : updatedAt as DateTime?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [Exercise].
extension ExercisePatterns on Exercise {
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String id,
      String name,
      String category,
      String equipment,
      @JsonKey(name: 'force_type') String? forceType,
      String? mechanic,
      List<String> instructions,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'slug') String? slug,
      @JsonKey(name: 'name_vi') String nameVi,
      @JsonKey(name: 'name_en') String nameEn,
      @JsonKey(name: 'movement_pattern') String? movementPattern,
      @JsonKey(name: 'secondary_muscles') List<String> secondaryMuscles,
      String? difficulty,
      @JsonKey(name: 'form_cues') List<String> formCues,
      @JsonKey(name: 'common_mistakes') List<String> commonMistakes,
      @JsonKey(name: 'alternative_exercise_slugs')
      List<String> alternativeExerciseSlugs,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Exercise() when $default != null:
        return $default(
          _that.id,
          _that.name,
          _that.category,
          _that.equipment,
          _that.forceType,
          _that.mechanic,
          _that.instructions,
          _that.imageUrl,
          _that.slug,
          _that.nameVi,
          _that.nameEn,
          _that.movementPattern,
          _that.secondaryMuscles,
          _that.difficulty,
          _that.formCues,
          _that.commonMistakes,
          _that.alternativeExerciseSlugs,
          _that.createdAt,
          _that.updatedAt,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Exercise extends Exercise {
  const _Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.equipment,
    @JsonKey(name: 'force_type') this.forceType,
    this.mechanic,
    final List<String> instructions = const [],
    @JsonKey(name: 'image_url') this.imageUrl,
    @JsonKey(name: 'slug') this.slug,
    @JsonKey(name: 'name_vi') this.nameVi = '',
    @JsonKey(name: 'name_en') this.nameEn = '',
    @JsonKey(name: 'movement_pattern') this.movementPattern,
    final List<String> secondaryMuscles = const [],
    this.difficulty,
    final List<String> formCues = const [],
    final List<String> commonMistakes = const [],
    final List<String> alternativeExerciseSlugs = const [],
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : _instructions = instructions,
       _secondaryMuscles = secondaryMuscles,
       _formCues = formCues,
       _commonMistakes = commonMistakes,
       _alternativeExerciseSlugs = alternativeExerciseSlugs,
       super._();

  factory _Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String category;
  @override
  final String equipment;
  @override
  @JsonKey(name: 'force_type')
  final String? forceType;
  @override
  final String? mechanic;
  final List<String> _instructions;
  @override
  @JsonKey()
  List<String> get instructions {
    if (_instructions is EqualUnmodifiableListView) return _instructions;
    return EqualUnmodifiableListView(_instructions);
  }

  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'slug')
  final String? slug;
  @override
  @JsonKey(name: 'name_vi')
  final String nameVi;
  @override
  @JsonKey(name: 'name_en')
  final String nameEn;
  @override
  @JsonKey(name: 'movement_pattern')
  final String? movementPattern;
  final List<String> _secondaryMuscles;
  @override
  @JsonKey(name: 'secondary_muscles')
  List<String> get secondaryMuscles {
    if (_secondaryMuscles is EqualUnmodifiableListView) return _secondaryMuscles;
    return EqualUnmodifiableListView(_secondaryMuscles);
  }

  @override
  final String? difficulty;
  final List<String> _formCues;
  @override
  @JsonKey(name: 'form_cues')
  List<String> get formCues {
    if (_formCues is EqualUnmodifiableListView) return _formCues;
    return EqualUnmodifiableListView(_formCues);
  }

  final List<String> _commonMistakes;
  @override
  @JsonKey(name: 'common_mistakes')
  List<String> get commonMistakes {
    if (_commonMistakes is EqualUnmodifiableListView) return _commonMistakes;
    return EqualUnmodifiableListView(_commonMistakes);
  }

  final List<String> _alternativeExerciseSlugs;
  @override
  @JsonKey(name: 'alternative_exercise_slugs')
  List<String> get alternativeExerciseSlugs {
    if (_alternativeExerciseSlugs is EqualUnmodifiableListView) {
      return _alternativeExerciseSlugs;
    }
    return EqualUnmodifiableListView(_alternativeExerciseSlugs);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExerciseCopyWith<_Exercise> get copyWith =>
      __$ExerciseCopyWithImpl<_Exercise>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExerciseToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Exercise &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.equipment, equipment) ||
                other.equipment == equipment) &&
            (identical(other.forceType, forceType) ||
                other.forceType == forceType) &&
            (identical(other.mechanic, mechanic) ||
                other.mechanic == mechanic) &&
            const DeepCollectionEquality().equals(
              other._instructions,
              _instructions,
            ) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.nameVi, nameVi) || other.nameVi == nameVi) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.movementPattern, movementPattern) ||
                other.movementPattern == movementPattern) &&
            const DeepCollectionEquality().equals(
              other._secondaryMuscles,
              _secondaryMuscles,
            ) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality().equals(other._formCues, _formCues) &&
            const DeepCollectionEquality().equals(
              other._commonMistakes,
              _commonMistakes,
            ) &&
            const DeepCollectionEquality().equals(
              other._alternativeExerciseSlugs,
              _alternativeExerciseSlugs,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    category,
    equipment,
    forceType,
    mechanic,
    const DeepCollectionEquality().hash(_instructions),
    imageUrl,
    slug,
    nameVi,
    nameEn,
    movementPattern,
    const DeepCollectionEquality().hash(_secondaryMuscles),
    difficulty,
    const DeepCollectionEquality().hash(_formCues),
    const DeepCollectionEquality().hash(_commonMistakes),
    const DeepCollectionEquality().hash(_alternativeExerciseSlugs),
    createdAt,
    updatedAt,
  );

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, category: $category, equipment: $equipment, forceType: $forceType, mechanic: $mechanic, instructions: $instructions, imageUrl: $imageUrl, slug: $slug, nameVi: $nameVi, nameEn: $nameEn, movementPattern: $movementPattern, secondaryMuscles: $secondaryMuscles, difficulty: $difficulty, formCues: $formCues, commonMistakes: $commonMistakes, alternativeExerciseSlugs: $alternativeExerciseSlugs, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$ExerciseCopyWith<$Res>
    implements $ExerciseCopyWith<$Res> {
  factory _$ExerciseCopyWith(
    _Exercise value,
    $Res Function(_Exercise) _then,
  ) = __$ExerciseCopyWithImpl;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String category,
    String equipment,
    @JsonKey(name: 'force_type') String? forceType,
    String? mechanic,
    List<String> instructions,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'slug') String? slug,
    @JsonKey(name: 'name_vi') String nameVi,
    @JsonKey(name: 'name_en') String nameEn,
    @JsonKey(name: 'movement_pattern') String? movementPattern,
    @JsonKey(name: 'secondary_muscles') List<String> secondaryMuscles,
    String? difficulty,
    @JsonKey(name: 'form_cues') List<String> formCues,
    @JsonKey(name: 'common_mistakes') List<String> commonMistakes,
    @JsonKey(name: 'alternative_exercise_slugs')
    List<String> alternativeExerciseSlugs,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$ExerciseCopyWithImpl<$Res> implements _$ExerciseCopyWith<$Res> {
  __$ExerciseCopyWithImpl(this._self, this._then);

  final _Exercise _self;
  final $Res Function(_Exercise) _then;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? equipment = null,
    Object? forceType = freezed,
    Object? mechanic = freezed,
    Object? instructions = null,
    Object? imageUrl = freezed,
    Object? slug = freezed,
    Object? nameVi = null,
    Object? nameEn = null,
    Object? movementPattern = freezed,
    Object? secondaryMuscles = null,
    Object? difficulty = freezed,
    Object? formCues = null,
    Object? commonMistakes = null,
    Object? alternativeExerciseSlugs = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _Exercise(
        id: null == id ? _self.id : id as String,
        name: null == name ? _self.name : name as String,
        category: null == category ? _self.category : category as String,
        equipment: null == equipment ? _self.equipment : equipment as String,
        forceType: freezed == forceType ? _self.forceType : forceType as String?,
        mechanic: freezed == mechanic ? _self.mechanic : mechanic as String?,
        instructions: null == instructions
            ? _self._instructions
            : instructions as List<String>,
        imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl as String?,
        slug: freezed == slug ? _self.slug : slug as String?,
        nameVi: null == nameVi ? _self.nameVi : nameVi as String,
        nameEn: null == nameEn ? _self.nameEn : nameEn as String,
        movementPattern: freezed == movementPattern
            ? _self.movementPattern
            : movementPattern as String?,
        secondaryMuscles: null == secondaryMuscles
            ? _self._secondaryMuscles
            : secondaryMuscles as List<String>,
        difficulty: freezed == difficulty
            ? _self.difficulty
            : difficulty as String?,
        formCues: null == formCues ? _self._formCues : formCues as List<String>,
        commonMistakes: null == commonMistakes
            ? _self._commonMistakes
            : commonMistakes as List<String>,
        alternativeExerciseSlugs: null == alternativeExerciseSlugs
            ? _self._alternativeExerciseSlugs
            : alternativeExerciseSlugs as List<String>,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt as DateTime?,
        updatedAt: freezed == updatedAt
            ? _self.updatedAt
            : updatedAt as DateTime?,
      ),
    );
  }
}

// dart format on
