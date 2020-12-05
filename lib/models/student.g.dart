// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) {
  return Student(
    json['name'] as String,
    json['email'] as String,
    json['nextLesson'] == null
        ? null
        : DateTime.parse(json['nextLesson'] as String),
    json['lessonsOwed'] as int,
    json['lessonsPresent'] as int,
    json['nextInvoice'] == null
        ? null
        : DateTime.parse(json['nextInvoice'] as String),
  );
}

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'nextLesson': instance.nextLesson?.toIso8601String(),
      'lessonsOwed': instance.lessonsOwed,
      'lessonsPresent': instance.lessonsPresent,
      'nextInvoice': instance.nextInvoice?.toIso8601String(),
    };
