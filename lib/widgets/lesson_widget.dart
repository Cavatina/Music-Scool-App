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

  Widget homeworkIcons(BuildContext context, Homework homework) {
    List<Widget> icons = <Widget>[];
    var devSize = MediaQuery.of(context).size;
    double boxWidth = min(devSize.width / 2.6, 300.0);

    if (homework.fileUrl != null) {
      icons.add(
          SizedBox(
            width: boxWidth,
            child: OutlinedButton.icon(
                label: Text(S.of(context).download),
                onPressed: () {
                  launch(homework.fileUrl);
                },
                icon: Icon(Icons.download_outlined)
            ),
          )
          );
    }
    if (homework.linkUrl != null) {
      icons.add(
        SizedBox(
          width: boxWidth,
          child: OutlinedButton.icon(
            label: Text(S.of(context).view),
            onPressed: () {
              launch(homework.linkUrl);
            },
              icon: Icon(Icons.ondemand_video_outlined)
          ),
        )
      );
    }
    return Wrap(direction: Axis.horizontal, spacing: 16.0, children: icons);
  }

  String cancelledText(BuildContext context, String statusKey) {
    switch(statusKey) {
      case 'STUDENT_CANCELLED': return S.of(context).statusStudentCancelled; break;
      case 'STUDENT_CANCELLED_LATE': return S.of(context).statusStudentCancelledLate; break;
      case 'TEACHER_CANCELLED': return S.of(context).statusTeacherCancelled; break;
      case 'STUDENT_ABSENT': return S.of(context).statusStudentAbsent; break;
      default:
        return '';
    }
  }

  String instrumentText(BuildContext context, String instrumentKey) {
    switch (instrumentKey) {
      case 'Bass guitar': return S.of(context).bassGuitar; break;
      case 'Guitar': return S.of(context).guitar; break;
      case 'Piano': return S.of(context).piano; break;
      case 'Vocal': return S.of(context).vocals; break;
      case 'Vocals': return S.of(context).vocals; break;
      case 'Drums': return S.of(context).drums; break;
      case 'Songwriting': return S.of(context).songwriting; break;
      case 'EDM': return S.of(context).EDM; break;
      default:
        return instrumentKey;
    }
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
    }
    String start = DateFormat.yMMMEd().format(lesson.from) + ' ' +
        DateFormat.Hm().format(lesson.from);
    String subtitle;
    if (lesson.instrument != null && lesson.teacher != null) {
      subtitle = S.of(context).instrumentWithTeacher(lesson.instrument.name,
          lesson.teacher.name);
    }
    else if (lesson.teacher != null) {
      subtitle = S.of(context).withTeacher(lesson.teacher.name);
    }
    else {
      subtitle = '';
    }
    out.add(ListTile(
              title: Text(start),
              subtitle: Text(subtitle)));
    if (lesson.cancelled == true) {
      out.add(ListTile(subtitle: Text(cancelledText(context, lesson.status))));
    }
    if (lesson.homework != null) {
//      out.add(ListTile(subtitle: Text('Homework')/*, tileColor: Color.fromRGBO(64, 64, 64, 0.5)*/));
      lesson.homework.forEach((Homework homework) =>
          out.add(
              Container(
                color: Color.fromRGBO(64, 64, 64, 0.3),
//                margin: EdgeInsets.symmetric(vertical: 16.0),
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(homework.message),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
                    homeworkIcons(context, homework),
//                    Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
                  ]
                ),
              )
          )
      );
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
              child: Text(S.of(context).no),
              onPressed: () {
                Navigator.of(context).pop(false);
              }
            ),
            CupertinoDialogAction(
                child: Text(S.of(context).yes),
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
                  icon: Text(S.of(context).cancel),
                  label: Icon(Icons.delete, color: Colors.white))
          )
      );
    }
    return child;
  }
  @override
  Widget build(BuildContext context) {
    Border border;
    if (lesson.cancelled == true) {
      border = Border(left: BorderSide(width: 2.0, color: Colors.red[900]));
    }
    else if (lesson.pending != true) {
      border = Border(left: BorderSide(width: 2.0, color: Theme.of(context).primaryColor));
    }
    else if (lesson.isNext != true) {
      border = Border(right: BorderSide(width: 2.0, color: Colors.white));
    }
    else {
      border = Border(right: BorderSide(width: 2.0, color: Colors.black));
    }
    return Card(
      child: cancellableIfPending(context,
          Container(
            decoration: BoxDecoration(
              border: border
            ),
            child: Column(
              children: rows(context)
            ),
          )
      )
    );
  }
}
