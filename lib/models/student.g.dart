// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) {
  return Student(
    LessonRef.fromJson(json['nextLesson'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'nextLesson': instance.nextLesson,
    };
