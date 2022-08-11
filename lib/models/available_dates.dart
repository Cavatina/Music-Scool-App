/* Music'scool App - Copyright (C) 2020  Music'scool DK

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>. */

import 'package:json_annotation/json_annotation.dart';
import 'package:musicscool/models/teacher.dart';
import 'package:musicscool/models/location.dart';

part 'available_dates.g.dart';

@JsonSerializable()
class AvailableDates {
  final DateTime date;
  final Teacher teacher;
  final Location location;

  AvailableDates(this.date, this.teacher, this.location);
  factory AvailableDates.fromJson(Map<String, dynamic> json) => _$AvailableDatesFromJson(json);

  @override
  String toString() {
    return 'AvailableDates(${date},teacher=${teacher.id},location=${location.id}))';
  }

  Map<String, dynamic> toJson() => _$AvailableDatesToJson(this);
}
