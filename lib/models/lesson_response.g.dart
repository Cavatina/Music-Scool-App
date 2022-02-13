// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonResponse _$LessonResponseFromJson(Map<String, dynamic> json) {
  return LessonResponse(
    (json['data'] as List<dynamic>)
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList(),
    PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    PaginationLinks.fromJson(json['links'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LessonResponseToJson(LessonResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
      'links': instance.links,
    };
