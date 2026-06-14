// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserPreferencesIsarCollection on Isar {
  IsarCollection<UserPreferencesIsar> get userPreferencesIsars =>
      this.collection();
}

const UserPreferencesIsarSchema = CollectionSchema(
  name: r'UserPreferencesIsar',
  id: -2918659535799530546,
  properties: {
    r'buddyPersonality': PropertySchema(
      id: 0,
      name: r'buddyPersonality',
      type: IsarType.string,
    ),
    r'isDarkMode': PropertySchema(
      id: 1,
      name: r'isDarkMode',
      type: IsarType.bool,
    ),
    r'onboardingCompleted': PropertySchema(
      id: 2,
      name: r'onboardingCompleted',
      type: IsarType.bool,
    ),
    r'onboardingCompletedAt': PropertySchema(
      id: 3,
      name: r'onboardingCompletedAt',
      type: IsarType.dateTime,
    ),
    r'primaryColor': PropertySchema(
      id: 4,
      name: r'primaryColor',
      type: IsarType.string,
    ),
    r'secondaryColor': PropertySchema(
      id: 5,
      name: r'secondaryColor',
      type: IsarType.string,
    ),
    r'userName': PropertySchema(
      id: 6,
      name: r'userName',
      type: IsarType.string,
    )
  },
  estimateSize: _userPreferencesIsarEstimateSize,
  serialize: _userPreferencesIsarSerialize,
  deserialize: _userPreferencesIsarDeserialize,
  deserializeProp: _userPreferencesIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userPreferencesIsarGetId,
  getLinks: _userPreferencesIsarGetLinks,
  attach: _userPreferencesIsarAttach,
  version: '3.1.0+1',
);

int _userPreferencesIsarEstimateSize(
  UserPreferencesIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.buddyPersonality.length * 3;
  {
    final value = object.primaryColor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.secondaryColor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.userName.length * 3;
  return bytesCount;
}

void _userPreferencesIsarSerialize(
  UserPreferencesIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.buddyPersonality);
  writer.writeBool(offsets[1], object.isDarkMode);
  writer.writeBool(offsets[2], object.onboardingCompleted);
  writer.writeDateTime(offsets[3], object.onboardingCompletedAt);
  writer.writeString(offsets[4], object.primaryColor);
  writer.writeString(offsets[5], object.secondaryColor);
  writer.writeString(offsets[6], object.userName);
}

UserPreferencesIsar _userPreferencesIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserPreferencesIsar();
  object.buddyPersonality = reader.readString(offsets[0]);
  object.id = id;
  object.isDarkMode = reader.readBool(offsets[1]);
  object.onboardingCompleted = reader.readBool(offsets[2]);
  object.onboardingCompletedAt = reader.readDateTimeOrNull(offsets[3]);
  object.primaryColor = reader.readStringOrNull(offsets[4]);
  object.secondaryColor = reader.readStringOrNull(offsets[5]);
  object.userName = reader.readString(offsets[6]);
  return object;
}

P _userPreferencesIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userPreferencesIsarGetId(UserPreferencesIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userPreferencesIsarGetLinks(
    UserPreferencesIsar object) {
  return [];
}

void _userPreferencesIsarAttach(
    IsarCollection<dynamic> col, Id id, UserPreferencesIsar object) {
  object.id = id;
}

extension UserPreferencesIsarQueryWhereSort
    on QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QWhere> {
  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserPreferencesIsarQueryWhere
    on QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QWhereClause> {
  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserPreferencesIsarQueryFilter on QueryBuilder<UserPreferencesIsar,
    UserPreferencesIsar, QFilterCondition> {
  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      buddyPersonalityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'buddyPersonality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      buddyPersonalityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'buddyPersonality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      buddyPersonalityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'buddyPersonality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      buddyPersonalityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'buddyPersonality',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      buddyPersonalityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'buddyPersonality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      buddyPersonalityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'buddyPersonality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      buddyPersonalityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'buddyPersonality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      buddyPersonalityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'buddyPersonality',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      buddyPersonalityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'buddyPersonality',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      buddyPersonalityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'buddyPersonality',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      isDarkModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDarkMode',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      onboardingCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onboardingCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      onboardingCompletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'onboardingCompletedAt',
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      onboardingCompletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'onboardingCompletedAt',
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      onboardingCompletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onboardingCompletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      onboardingCompletedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'onboardingCompletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      onboardingCompletedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'onboardingCompletedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      onboardingCompletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'onboardingCompletedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      primaryColorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'primaryColor',
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      primaryColorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'primaryColor',
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      primaryColorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      primaryColorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'primaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      primaryColorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'primaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      primaryColorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'primaryColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      primaryColorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'primaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      primaryColorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'primaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      primaryColorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'primaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      primaryColorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'primaryColor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      primaryColorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryColor',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      primaryColorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'primaryColor',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      secondaryColorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'secondaryColor',
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      secondaryColorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'secondaryColor',
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      secondaryColorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'secondaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      secondaryColorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'secondaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      secondaryColorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'secondaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      secondaryColorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'secondaryColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      secondaryColorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'secondaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      secondaryColorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'secondaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      secondaryColorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'secondaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      secondaryColorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'secondaryColor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      secondaryColorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'secondaryColor',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      secondaryColorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'secondaryColor',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      userNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      userNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      userNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      userNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      userNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      userNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      userNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      userNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      userNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterFilterCondition>
      userNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userName',
        value: '',
      ));
    });
  }
}

extension UserPreferencesIsarQueryObject on QueryBuilder<UserPreferencesIsar,
    UserPreferencesIsar, QFilterCondition> {}

extension UserPreferencesIsarQueryLinks on QueryBuilder<UserPreferencesIsar,
    UserPreferencesIsar, QFilterCondition> {}

extension UserPreferencesIsarQuerySortBy
    on QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QSortBy> {
  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      sortByBuddyPersonality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buddyPersonality', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      sortByBuddyPersonalityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buddyPersonality', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      sortByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      sortByIsDarkModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      sortByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      sortByOnboardingCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      sortByOnboardingCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompletedAt', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      sortByOnboardingCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompletedAt', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      sortByPrimaryColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryColor', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      sortByPrimaryColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryColor', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      sortBySecondaryColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryColor', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      sortBySecondaryColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryColor', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      sortByUserName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      sortByUserNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.desc);
    });
  }
}

extension UserPreferencesIsarQuerySortThenBy
    on QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QSortThenBy> {
  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenByBuddyPersonality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buddyPersonality', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenByBuddyPersonalityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'buddyPersonality', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenByIsDarkModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenByOnboardingCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenByOnboardingCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompletedAt', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenByOnboardingCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompletedAt', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenByPrimaryColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryColor', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenByPrimaryColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryColor', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenBySecondaryColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryColor', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenBySecondaryColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryColor', Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenByUserName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.asc);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QAfterSortBy>
      thenByUserNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.desc);
    });
  }
}

extension UserPreferencesIsarQueryWhereDistinct
    on QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QDistinct> {
  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QDistinct>
      distinctByBuddyPersonality({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'buddyPersonality',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QDistinct>
      distinctByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDarkMode');
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QDistinct>
      distinctByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onboardingCompleted');
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QDistinct>
      distinctByOnboardingCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onboardingCompletedAt');
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QDistinct>
      distinctByPrimaryColor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'primaryColor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QDistinct>
      distinctBySecondaryColor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'secondaryColor',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QDistinct>
      distinctByUserName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userName', caseSensitive: caseSensitive);
    });
  }
}

extension UserPreferencesIsarQueryProperty
    on QueryBuilder<UserPreferencesIsar, UserPreferencesIsar, QQueryProperty> {
  QueryBuilder<UserPreferencesIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserPreferencesIsar, String, QQueryOperations>
      buddyPersonalityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'buddyPersonality');
    });
  }

  QueryBuilder<UserPreferencesIsar, bool, QQueryOperations>
      isDarkModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDarkMode');
    });
  }

  QueryBuilder<UserPreferencesIsar, bool, QQueryOperations>
      onboardingCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onboardingCompleted');
    });
  }

  QueryBuilder<UserPreferencesIsar, DateTime?, QQueryOperations>
      onboardingCompletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onboardingCompletedAt');
    });
  }

  QueryBuilder<UserPreferencesIsar, String?, QQueryOperations>
      primaryColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'primaryColor');
    });
  }

  QueryBuilder<UserPreferencesIsar, String?, QQueryOperations>
      secondaryColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'secondaryColor');
    });
  }

  QueryBuilder<UserPreferencesIsar, String, QQueryOperations>
      userNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userName');
    });
  }
}
