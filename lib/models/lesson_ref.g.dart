// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonRef _$LessonRefFromJson(Map<String, dynamic> json) {
  return LessonRef(
    json['id'] as int,
    json['from'] == null ? null : DateTime.parse(json['from'] as String),
  );
}

Map<String, dynamic> _$LessonRefToJson(LessonRef instance) => <String, dynamic>{
      'id': instance.id,
      'from': instance.from?.toIso8601String(),
    };
