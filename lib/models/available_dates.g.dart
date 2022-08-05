// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_dates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableDates _$AvailableDatesFromJson(Map<String, dynamic> json) {
  return AvailableDates(
    DateTime.parse(json['date'] as String),
    Teacher.fromJson(json['teacher'] as Map<String, dynamic>),
    Location.fromJson(json['location'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AvailableDatesToJson(AvailableDates instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'teacher': instance.teacher,
      'location': instance.location,
    };
