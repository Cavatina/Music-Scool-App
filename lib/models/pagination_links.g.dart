// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_links.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginationLinks _$PaginationLinksFromJson(Map<String, dynamic> json) {
  return PaginationLinks(
    json['first'] as String?,
    json['last'] as String?,
    json['prev'] as String?,
    json['next'] as String?,
  );
}

Map<String, dynamic> _$PaginationLinksToJson(PaginationLinks instance) =>
    <String, dynamic>{
      'first': instance.first,
      'last': instance.last,
      'prev': instance.prev,
      'next': instance.next,
    };
