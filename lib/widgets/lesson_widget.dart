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

import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:musicscool/models/homework.dart';
import 'package:musicscool/widgets/countdown_timer_widget.dart';
import 'package:musicscool/generated/l10n.dart';

class LessonWidget extends StatelessWidget {
  LessonWidget({this.lesson}) : super(key: Key(lesson.from.toIso8601String()));

  final Lesson lesson;

  Widget homeworkIcons(Homework homework) {
    List<Widget> icons = <Widget>[];
    if (homework.fileUrl != null) {
      icons.add(GestureDetector(
          onTap: () {

          },
          child: Icon(Icons.download_outlined)
      ));
    }
    if (homework.linkUrl != null) {
      icons.add(
          GestureDetector(
            onTap: () {
              launch(homework.linkUrl);
            },
            child: Icon(Icons.ondemand_video_outlined)
      ));
    }
    return Wrap(direction: Axis.vertical, children: icons);
  }

  List<Widget> rows(BuildContext context) {
    List<Widget> out = <Widget>[];
    if (lesson.isNext) {
      var devSize = MediaQuery.of(context).size;
      double boxWidth = min(devSize.width / 5.5, 100.0);
      out.add(Container(
        padding: EdgeInsets.symmetric(vertical: devSize.height / 6),
        child: Column(
          children: <Widget> [
            Text(S.of(context).aboutToRock),
            CountdownTimer(to: lesson.from, boxWidth: boxWidth)
          ]
        ),
      ));
      //out.add(ListTile(title: CountdownTimer(to:lesson.start)));
    }
    String start = DateFormat.yMMMEd().format(lesson.from);
    out.add(ListTile(
              title: Text(start),
              subtitle: Text(lesson.status)));
    if (lesson.homework != null) {
      lesson.homework.forEach((Homework homework) =>
          out.add(ListTile(
            leading: homeworkIcons(homework),
              title: Text(homework.message))));
    }
    return out;
  }

  Future<bool> confirmCancel(BuildContext context) async {
    return await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          content: Text(S.of(context).cancelLesson),
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

  Widget cancellableIfPending(BuildContext context, Widget child) {
    if (lesson.pending == true) {
      return Dismissible(
          key: Key(lesson.id.toString()),
          child: child,
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
      );
    }
    return child;
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      child: cancellableIfPending(context,
          Column(
            children: rows(context)
        )
      )
    );
  }
}
