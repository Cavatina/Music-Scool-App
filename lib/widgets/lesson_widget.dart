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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:musicscool/models/lesson_cancel_info.dart';
import 'package:musicscool/viewmodels/auth.dart';
import 'package:provider/provider.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:musicscool/generated/l10n.dart';

class LessonWidget extends StatefulWidget {
  final Lesson lesson;
  LessonWidget({this.lesson});

  @override
  _LessonWidgetState createState() => _LessonWidgetState(lesson: lesson);
}

class _LessonWidgetState extends State<LessonWidget> {
  _LessonWidgetState({this.lesson});

  Lesson lesson;

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

  static String formattedDate(DateTime time) {
    return DateFormat.yMMMEd().format(time) + ' ' +
        DateFormat.Hm().format(time);
  }

  Widget header(BuildContext context, bool expand, {List<Widget> children}) {
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
    if (expand) {
      return ExpansionTile(
          title: Text(formattedDate(lesson.from)),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.white60),
          overflow: TextOverflow.ellipsis),
          children: children);
    }
    return(ListTile(
        title: Text(formattedDate(lesson.from)),
        subtitle: Text(subtitle)));
  }
  List<Widget> body(BuildContext context) {
    List<Widget> out = <Widget>[];
   if (lesson.cancelled == true) {
     out.add(ListTile(subtitle: Text(cancelledText(context, lesson.status))));
   }
    return out;
  }

  List<Widget> rows(BuildContext context) {
    List<Widget> out = <Widget>[];
    // if (lesson.isNext) {
    //   var devSize = MediaQuery.of(context).size;
    //   double boxWidth = min(devSize.width / 5.5, 100.0);
    //   out.add(Container(
    //     padding: EdgeInsets.symmetric(vertical: devSize.height / 6),
    //     child: Column(
    //       children: <Widget> [
    //         Text(S.of(context).aboutToRock),
    //         CountdownTimer(to: lesson.from, boxWidth: boxWidth)
    //       ]
    //     ),
    //   ));
    // }
    out.add(header(context, false));
    out.addAll(body(context));
    return out;
  }

  Future<bool> confirmCancel(BuildContext context) async {
    AuthModel auth = Provider.of<AuthModel>(context, listen: false);
    LessonCancelInfo cancelInfo = await auth.cancelLessonInfo(id: lesson.id);
    String textContent;
    print(jsonEncode(cancelInfo.toJson()));
    if (cancelInfo.canGetReplacement) {
      textContent = S.of(context).cancelLessonRefundable(
          cancelInfo.countCancelled+1,  // Total: include this cancellation.
          cancelInfo.allowCancelled);
    }
    else {
      textContent = S.of(context).cancelLessonNonRefundable;
    }
    return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.of(context).confirm),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.of(context).cancelLessonAt(formattedDate(lesson.from))),
              Text(''),
              Text(textContent),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(S.of(context).no),
              onPressed: () {
                Navigator.of(context).pop(false);
              }
            ),
            TextButton(
                child: Text(S.of(context).yes),
                onPressed: () {
                  auth.cancelLesson(id: lesson.id).then((Lesson l) {
                    setState(() {
                      lesson = l;
                    });
                    Navigator.of(context).pop(true);
                  });
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
    else { //if (lesson.isNext != true) {
      border = Border(right: BorderSide(width: 2.0, color: Colors.white));
    }
    // else {
    //   border = Border(right: BorderSide(width: 2.0, color: Colors.black));
    // }
    if (lesson.pending == true) {
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
    else {
      return Card(
        child: Container(
          decoration: BoxDecoration(
              border: border
          ),
          child: header(context, true,
            children: body(context)
          ),
        )
      );
    }
  }
}
