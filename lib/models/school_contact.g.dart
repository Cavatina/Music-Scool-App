// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolContact _$SchoolContactFromJson(Map<String, dynamic> json) {
  return SchoolContact(
    json['name'] as String,
    json['phone'] as String,
    json['email'] as String,
    (json['address'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$SchoolContactToJson(SchoolContact instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
    };
