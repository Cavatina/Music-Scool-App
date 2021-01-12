// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    json['name'] as String,
    json['firstName'] as String,
    json['email'] as String,
    json['schoolContact'] == null
        ? null
        : SchoolContact.fromJson(json['schoolContact'] as Map<String, dynamic>),
    json['student'] == null
        ? null
        : Student.fromJson(json['student'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'firstName': instance.firstName,
      'email': instance.email,
      'schoolContact': instance.schoolContact,
      'student': instance.student,
    };
