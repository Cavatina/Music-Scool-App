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

import 'package:my_musicscool_app/models/homework.dart';

class Lesson {
  final DateTime start;
  final String status;
  final DateTime catchUp;
  final List<Homework> homework;

  Lesson(this.start, this.status, this.catchUp, this.homework);

  Lesson.fromJson(Map<String, dynamic> json) :
      start = DateTime.parse(json['start']),
      status = json['status'],
      catchUp = json['catchUp'].toString().isNotEmpty
          ? DateTime.parse(json['catchUp']) : null,
      homework = (json['homework'] as List)
          ?.map((e) =>
                  e == null ? null : Homework.fromJson(e as Map<String, dynamic>))
                ?.toList();
//      json.containsKey('homework') ? json['homework'].map<Homework>(
//              (Map<String, dynamic> obj) => Homework.fromJson(obj)).toList() : <Homework>[];

  Map<String, dynamic> toJson() =>
      <String, dynamic> {
        'start': start?.toIso8601String(),
        'status': status,
        'catchUp': catchUp?.toIso8601String(),
        'homework': homework?.map((o) => o.toJson())?.toList()
      };
}
