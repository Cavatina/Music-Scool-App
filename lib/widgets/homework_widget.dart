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
import 'package:musicscool/locale_strings.dart';
import 'package:musicscool/viewmodels/auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:musicscool/models/homework.dart';
import 'package:musicscool/generated/l10n.dart';
import 'package:musicscool/helpers.dart';
import 'package:open_file/open_file.dart';
import 'package:musicscool/service_locator.dart';

class HomeworkDownloadIcon extends StatefulWidget {
  final String url;
  final String fileName;

  HomeworkDownloadIcon({this.url, this.fileName});

  @override
  _HomeworkDownloadIconState createState() => _HomeworkDownloadIconState();
}

class _HomeworkDownloadIconState extends State<HomeworkDownloadIcon> {
  bool downloading = false;
  double progress = 0.0;
  String filePath;

  @override
  void initState() {
    super.initState();
    locator<AuthModel>().homeworkPath(
      url: widget.url,
      name: widget.fileName).then((String path) {
        print(path);
        setState(() {
          filePath = path;
        });
    });
  }

  void downloadAndLaunch(BuildContext context, String url, String fileName) {
    AuthModel auth = Provider.of<AuthModel>(context, listen: false);
    setState((){
      downloading = true;
    });
    auth.downloadHomework(url: url, name: fileName,
      onReceiveProgress: (int count, int total) {
        setState(() {
          progress = count / total;
        });
      }
    ).then((String path) {
      setState((){
        filePath = path;
        downloading = false;
      });
      OpenFile.open(path);
    }).catchError((e) {
      print('downloadAndLaunch(${url}) failed: ${e}');
      setState((){
        downloading = false;
      });
      showUnexpectedError(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (downloading) {
      return OutlinedButton(
        onPressed: null,
        child:
        LinearProgressIndicator(
          value: progress,
          minHeight:24
        )
      );
    }
    else if (filePath != null) {
      return OutlinedButton.icon(
      label: Text(S.of(context).view),
      onPressed: () {
        OpenFile.open(filePath);
      },
      icon: Icon(CupertinoIcons.cloud_download_fill)
    );
    }
    return OutlinedButton.icon(
      label: Text(S.of(context).download),
      onPressed: () {
        downloadAndLaunch(context, widget.url, widget.fileName);
      },
      icon: Icon(CupertinoIcons.cloud_download_fill) //download_outlined)
    );
  }
}

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
            child: HomeworkDownloadIcon(
              url: homework.fileUrl,
              fileName: homework.fileName,
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

  Widget header(BuildContext context, {List<Widget> children}) {
    String subtitle;
    if (widget.lesson.instrument != null && widget.lesson.teacher != null) {
      subtitle = S.of(context).instrumentWithTeacher(
          instrumentText(context, widget.lesson.instrument.name),
          widget.lesson.teacher.name);
    }
    else if (widget.lesson.teacher != null) {
      subtitle = S.of(context).withTeacher(widget.lesson.teacher.name);
    }
    else {
      subtitle = '';
    }

    if (widget.lesson.homework != null && widget.lesson.homework.isNotEmpty && expanded == false) {
        subtitle = widget.lesson.homework.first.message ?? '';
    }
    return ExpansionTile(
        title: Text(formattedDate(context, widget.lesson.from)),
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
                      Text(homework.message ?? ''),
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
