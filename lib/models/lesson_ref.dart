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

part 'lesson_ref.g.dart';

@JsonSerializable()
class LessonRef {
  final int id;
  final DateTime from;

  LessonRef(this.id, this.from);

  factory LessonRef.fromJson(Map<String, dynamic> json) => _$LessonRefFromJson(json);

  Map<String, dynamic> toJson() => _$LessonRefToJson(this);
}
