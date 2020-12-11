// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lesson _$LessonFromJson(Map<String, dynamic> json) {
  return Lesson(
    json['id'] as int,
    json['from'] == null ? null : DateTime.parse(json['from'] as String),
    json['until'] == null ? null : DateTime.parse(json['until'] as String),
    json['status'] as String,
    json['teacher'] == null
        ? null
        : Teacher.fromJson(json['teacher'] as Map<String, dynamic>),
    json['pending'] as bool,
    json['cancelled'] as bool,
    json['relocated'] as bool,
    json['requested'] as bool,
    json['replacesLesson'] == null
        ? null
        : LessonRef.fromJson(json['replacesLesson'] as Map<String, dynamic>),
    json['replacementLesson'] == null
        ? null
        : LessonRef.fromJson(json['replacementLesson'] as Map<String, dynamic>),
    (json['homework'] as List)
        ?.map((e) =>
            e == null ? null : Homework.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
      'id': instance.id,
      'from': instance.from?.toIso8601String(),
      'until': instance.until?.toIso8601String(),
      'status': instance.status,
      'teacher': instance.teacher,
      'pending': instance.pending,
      'cancelled': instance.cancelled,
      'relocated': instance.relocated,
      'requested': instance.requested,
      'replacesLesson': instance.replacesLesson,
      'replacementLesson': instance.replacementLesson,
      'homework': instance.homework,
    };
