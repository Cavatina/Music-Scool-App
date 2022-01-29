// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Homework _$HomeworkFromJson(Map<String, dynamic> json) {
  return Homework(
    json['message'] as String,
    json['fileName'] as String?,
    json['fileUrl'] as String,
    json['linkUrl'] as String,
  );
}

Map<String, dynamic> _$HomeworkToJson(Homework instance) => <String, dynamic>{
      'message': instance.message,
      'fileName': instance.fileName,
      'fileUrl': instance.fileUrl,
      'linkUrl': instance.linkUrl,
    };
