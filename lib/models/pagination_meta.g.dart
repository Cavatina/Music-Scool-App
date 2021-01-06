// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) {
  return PaginationMeta(
    json['current_page'] as int,
    json['from'] as int,
    json['path'] as String,
    json['to'] as int,
  );
}

Map<String, dynamic> _$PaginationMetaToJson(PaginationMeta instance) =>
    <String, dynamic>{
      'current_page': instance.current_page,
      'from': instance.from,
      'path': instance.path,
      'to': instance.to,
    };
