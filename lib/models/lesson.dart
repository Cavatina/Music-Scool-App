/* My Music'Scool - Copyright (C) 2020  Music'Scool DK

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

import 'package:musicscool/models/homework.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lesson.g.dart';

@JsonSerializable()
class Lesson {
  final DateTime start;
  final String status;
  final DateTime catchUp;
  final List<Homework> homework;

  @JsonKey(ignore: true)
  bool isNext = false;

  Lesson(this.start, this.status, this.catchUp, this.homework);
  Lesson copyWith({DateTime start, String status, DateTime catchUp, List<Homework> homework}) {
    return Lesson(
      start ?? this.start,
      status ?? this.status,
      catchUp ?? this.catchUp,
      homework ?? this.homework
    );
  }

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);

  Map<String, dynamic> toJson() => _$LessonToJson(this);
}
