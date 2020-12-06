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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_musicscool_app/models/lesson.dart';
import 'package:my_musicscool_app/models/homework.dart';

class LessonWidget extends StatelessWidget {
  LessonWidget({this.lesson}) : super(key: Key(lesson.start.toIso8601String()));

  final Lesson lesson;

  List<Widget> rows() {
    List<Widget> out = <Widget>[];
    out.add(ListTile(
              title: Text(lesson.start.toString()),
              subtitle: Text(lesson.status)));
    if (lesson.homework != null) {
      lesson.homework.forEach((Homework homework) =>
          out.add(ListTile(
            leading: homework.downloadUrl != null && homework.downloadUrl.isNotEmpty ? Icon(Icons.download_outlined) : null,
              title:Text(homework.description),
          trailing: homework.linkUrl != null && homework.linkUrl.isNotEmpty ? Icon(Icons.ondemand_video_outlined) : null)));
    }
    return out;
  }

  Future<bool> confirmCancel(BuildContext context) async {
    return await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          content: Text('Cancel lesson?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              }
            ),
            CupertinoDialogAction(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                }
            )
          ]
        )) ?? false;
  }

  Future<bool> confirmDismiss(BuildContext context, DismissDirection direction) async {
    if (direction == DismissDirection.endToStart) {
      await confirmCancel(context);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Dismissible(
        key: Key(lesson.start.toString()),
        child: Column(
          children: rows()
        ),
        confirmDismiss: (dir) => confirmDismiss(context, dir),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 20),
          alignment: AlignmentDirectional.centerEnd,
          child: FlatButton.icon(
                  onPressed: null,
                  icon: Text('Cancel'),
                  label: Icon(Icons.delete, color: Colors.white))
        )
      )
    );
  }
}
