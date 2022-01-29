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

import 'package:musicscool/models/homework.dart';
import 'package:musicscool/models/instrument.dart';
import 'package:musicscool/models/teacher.dart';
import 'package:musicscool/models/lesson_ref.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lesson.g.dart';

@JsonSerializable()
class Lesson {
  final int id;
  final DateTime from;
  final DateTime until;
  final String status;
  final Teacher? teacher;
  final Instrument? instrument;
  final bool? pending;
  final bool? cancelled;
  final bool? relocated;
  final bool? requested;
  final LessonRef? replacesLesson;
  final LessonRef? replacementLesson;
  final List<Homework>? homework;

  @JsonKey(ignore: true)
  bool isNext = false;

  Lesson(this.id, this.from, this.until, this.status,
      this.teacher, this.instrument,
      this.pending, this.cancelled, this.relocated, this.requested,
      this.replacesLesson, this.replacementLesson, this.homework);
  Lesson copyWith({DateTime? from, DateTime? until, String? status,
    bool? pending, bool? cancelled, bool? relocated, bool? requested}) {
    return Lesson(
        id,
        from ?? this.from,
        until ?? this.until,
        status ?? this.status,
        teacher,
        instrument,
        pending ?? this.pending,
        cancelled ?? this.cancelled,
        relocated ?? this.relocated,
        requested ?? this.requested,
        replacesLesson,
        replacementLesson,
        homework
    );
  }

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);

  Map<String, dynamic> toJson() => _$LessonToJson(this);
}
