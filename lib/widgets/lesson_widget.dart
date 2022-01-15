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
import 'package:flutter/cupertino.dart';
import 'package:musicscool/locale_strings.dart';
import 'package:musicscool/models/lesson_cancel_info.dart';
import 'package:musicscool/viewmodels/auth.dart';
import 'package:provider/provider.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:musicscool/helpers.dart';
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

  Widget header(BuildContext context, {List<Widget> children}) {
    String subtitle;
    if (lesson.instrument != null && lesson.teacher != null) {
      subtitle = S.of(context).instrumentWithTeacher(
          instrumentText(context, lesson.instrument.name),
          lesson.teacher.name);
    }
    else if (lesson.teacher != null) {
      subtitle = S.of(context).withTeacher(lesson.teacher.name);
    }
    else {
      subtitle = '';
    }
    if (children.isNotEmpty) {
      return ExpansionTile(
          title: Text(formattedDateTime(context, lesson.from)),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.white60),
          overflow: TextOverflow.ellipsis),
          children: children);
    }
    return(ListTile(
        title: Text(formattedDateTime(context, lesson.from)),
        subtitle: Text(subtitle)));
  }

  List<Widget> body(BuildContext context) {
    List<Widget> out = <Widget>[];
    if (lesson.cancelled == true) {
      out.add(ListTile(subtitle: Text(cancelledText(context, lesson.status))));
    }
    if (lesson.replacesLesson != null) {
      out.add(ListTile(subtitle: Text(S.of(context).replacementForLesson(
        formattedDate(context, lesson.replacesLesson.from)))));
    }
    return out;
  }

  Future<bool> confirmCancel(BuildContext context) async {
    AuthModel auth = Provider.of<AuthModel>(context, listen: false);
    LessonCancelInfo cancelInfo;
    try {
      cancelInfo = await auth.cancelLessonInfo(id: lesson.id);
    }
    catch (e) {
      showUnexpectedError(context);
      print(e);
      return false;
    }
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
    return await showCupertinoDialog<bool>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: Text(S.of(context).confirm),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.of(context).cancelLessonAt(formattedDateTime(context, lesson.from))),
              Text(''),
              Text(textContent),
            ],
          ),
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
                  auth.cancelLesson(id: lesson.id).then((Lesson l) {
                    setState(() {
                      lesson = l;
                    });
                    Navigator.of(dialogContext).pop(true);
                  }).catchError((e) {
                    showUnexpectedError(context);
                    Navigator.of(dialogContext).pop(true);
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
          ),
          child: child,
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
    else if (lesson.replacesLesson != null) {
      border = Border(right: BorderSide(width: 2.0, color: Colors.white),
                      left: BorderSide(width: 2.0, color: Colors.green[900]));
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
                child: header(context,
                    children: body(context)
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
          child: header(context,
            children: body(context)
          ),
        )
      );
    }
  }
}
