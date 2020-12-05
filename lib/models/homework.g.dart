// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Homework _$HomeworkFromJson(Map<String, dynamic> json) {
  return Homework(
    json['description'] as String,
    json['download'] as String,
    json['link'] as String,
  );
}

Map<String, dynamic> _$HomeworkToJson(Homework instance) => <String, dynamic>{
      'description': instance.description,
      'download': instance.download,
      'link': instance.link,
    };
