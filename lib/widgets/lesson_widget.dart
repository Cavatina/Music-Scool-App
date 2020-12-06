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

import 'package:flutter/material.dart';
import 'package:my_musicscool_app/models/lesson.dart';

class LessonWidget extends StatelessWidget {
  LessonWidget({this.lesson}) : super(key: Key(lesson.start.toIso8601String()));

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(lesson.start.toString()),
        subtitle: Text(lesson.status),
        trailing: Text(lesson.homework != null ? lesson.homework.length.toString() : '')
      )
    );
  }
}
