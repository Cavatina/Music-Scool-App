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
    json['nextLesson'] == null
        ? null
        : LessonRef.fromJson(json['nextLesson'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'schoolContact': instance.schoolContact,
      'nextLesson': instance.nextLesson,
    };
