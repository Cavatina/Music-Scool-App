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
//import 'package:musicscool/widgets/countdown_timer_widget.dart';
import 'package:musicscool/generated/l10n.dart';

class HomeworkWidget extends StatefulWidget {
  final Lesson lesson;
  final bool expanded;

  HomeworkWidget({this.lesson, this.expanded});

  @override
  _HomeworkWidgetState createState() => _HomeworkWidgetState(expanded: expanded);
}

class _HomeworkWidgetState extends State<HomeworkWidget> {
  bool expanded;

  _HomeworkWidgetState({this.expanded});
//  _HomeworkWidgetState({this.lesson, this.index}) : super(key: Key(lesson.from.toIso8601String()));

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
                icon: Icon(CupertinoIcons.cloud_download_fill) //download_outlined)
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
              icon: Icon(CupertinoIcons.tv_music_note_fill)//ondemand_video_outlined)
          ),
        )
      );
    }
    return Wrap(direction: Axis.horizontal, spacing: 16.0, children: icons);
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

  Widget header(BuildContext context, {List<Widget> children}) {
    String start = DateFormat.yMMMEd().format(widget.lesson.from) + ' ' +
        DateFormat.Hm().format(widget.lesson.from);
    String subtitle;
    if (widget.lesson.instrument != null && widget.lesson.teacher != null) {
      subtitle = S.of(context).instrumentWithTeacher(widget.lesson.instrument.name,
          widget.lesson.teacher.name);
    }
    else if (widget.lesson.teacher != null) {
      subtitle = S.of(context).withTeacher(widget.lesson.teacher.name);
    }
    else {
      subtitle = '';
    }

    if (widget.lesson.homework != null && widget.lesson.homework.isNotEmpty && expanded == false) {
        subtitle = widget.lesson.homework.first.message;
    }
    return ExpansionTile(
        title: Text(start),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white60),
        overflow: TextOverflow.ellipsis),
        initiallyExpanded: widget.expanded,
          onExpansionChanged: (bool state) {
            setState(() {
              expanded = state;
            });
          },
          children: children);
  }

  List<Widget> body(BuildContext context) {
    List<Widget> out = <Widget>[];
    if (widget.lesson.homework != null) {
//      out.add(ListTile(subtitle: Text('Homework')/*, tileColor: Color.fromRGBO(64, 64, 64, 0.5)*/));
      widget.lesson.homework.forEach((Homework homework) =>
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

  @override
  Widget build(BuildContext context) {
      return Card(key: Key(widget.lesson.from.toIso8601String()),
        child: header(context,
          children: body(context)
        )
      );
    }
}