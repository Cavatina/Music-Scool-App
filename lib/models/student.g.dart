// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) {
  return Student(
    json['schoolContact'] == null
        ? null
        : SchoolContact.fromJson(json['schoolContact'] as Map<String, dynamic>),
    json['nextLessonId'] as int,
  );
}

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'schoolContact': instance.schoolContact,
      'nextLessonId': instance.nextLessonId,
    };
