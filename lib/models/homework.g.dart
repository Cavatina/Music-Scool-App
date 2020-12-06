// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Homework _$HomeworkFromJson(Map<String, dynamic> json) {
  return Homework(
    json['description'] as String,
    json['downloadTitle'] as String,
    json['downloadUrl'] as String,
    json['linkUrl'] as String,
  );
}

Map<String, dynamic> _$HomeworkToJson(Homework instance) => <String, dynamic>{
      'description': instance.description,
      'downloadTitle': instance.downloadTitle,
      'downloadUrl': instance.downloadUrl,
      'linkUrl': instance.linkUrl,
    };
