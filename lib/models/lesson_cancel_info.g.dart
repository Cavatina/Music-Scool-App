// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_cancel_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonCancelInfo _$LessonCancelInfoFromJson(Map<String, dynamic> json) {
  return LessonCancelInfo(
    json['id'] as int,
    DateTime.parse(json['from'] as String),
    json['canGetReplacement'] as bool,
    json['countCancelled'] as int,
    json['allowCancelled'] as int,
  );
}

Map<String, dynamic> _$LessonCancelInfoToJson(LessonCancelInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'from': instance.from.toIso8601String(),
      'canGetReplacement': instance.canGetReplacement,
      'countCancelled': instance.countCancelled,
      'allowCancelled': instance.allowCancelled,
    };
