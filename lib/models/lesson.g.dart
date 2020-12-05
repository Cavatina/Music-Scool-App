// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lesson _$LessonFromJson(Map<String, dynamic> json) {
  return Lesson(
    json['start'] == null ? null : DateTime.parse(json['start'] as String),
    json['status'] as String,
    json['catchUp'] == null ? null : DateTime.parse(json['catchUp'] as String),
    (json['homework'] as List)
        ?.map((e) =>
            e == null ? null : Homework.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
      'start': instance.start?.toIso8601String(),
      'status': instance.status,
      'catchUp': instance.catchUp?.toIso8601String(),
      'homework': instance.homework,
    };
