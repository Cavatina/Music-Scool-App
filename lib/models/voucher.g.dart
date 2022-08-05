// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Voucher _$VoucherFromJson(Map<String, dynamic> json) {
  return Voucher(
    json['id'] as int,
    json['active'] as bool,
    DateTime.parse(json['activeFrom'] as String),
    DateTime.parse(json['expiryDate'] as String),
    json['lessonsGranted'] as int,
    json['lessonsRemaining'] as int,
  );
}

Map<String, dynamic> _$VoucherToJson(Voucher instance) => <String, dynamic>{
      'id': instance.id,
      'active': instance.active,
      'activeFrom': instance.activeFrom.toIso8601String(),
      'expiryDate': instance.expiryDate.toIso8601String(),
      'lessonsGranted': instance.lessonsGranted,
      'lessonsRemaining': instance.lessonsRemaining,
    };
