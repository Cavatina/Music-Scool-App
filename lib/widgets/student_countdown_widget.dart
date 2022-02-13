import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:musicscool/generated/l10n.dart';
import 'package:musicscool/locale_strings.dart';
import 'package:musicscool/models/user.dart';

import 'countdown_timer_widget.dart';

class StudentCountdown extends StatefulWidget
{
  const StudentCountdown({required this.user});

  final User user;

  @override
  _StudentCountdownState createState() => _StudentCountdownState();
}

class _StudentCountdownState extends State<StudentCountdown>
{
  Timer? _timer;
  bool _lessonIsNow = false;

  bool lessonIsNow() => widget.user.student?.nextLesson != null
                         && !DateTime.now().isBefore(widget.user.student!.nextLesson!.from);

  @override
  void initState() {
    _timer = Timer.periodic(Duration(milliseconds:250),
      (Timer t) {
        setState(() => {_lessonIsNow = lessonIsNow()});
      }
    );
    _lessonIsNow = lessonIsNow();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.student?.nextLesson == null) {
      return buildNoLesson(context);
    }
    else if (_lessonIsNow == true) {
      return buildLessonIsNow(context);
    }
    else {
      return buildCountdown(context);
    }
  }

  Widget buildNoLesson(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:<Widget> [
          Text(S.of(context).youHaveNoUpcomingLessons)
        ]
    );
  }

  Widget buildLessonIsNow(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget> [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget> [
            Text(S.of(context).youAreRockingRightNow,
                textScaleFactor: 1.25, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(''),
          ],
        )
      ]
    );
  }

  Widget buildCountdown(context) {
    var devSize = MediaQuery.of(context).size;
    double boxWidth = min(devSize.width / 5.5, 100.0);
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget> [
              Text(S.of(context).heyUser(widget.user.firstName),
                  textScaleFactor: 1.25),
              Text(S.of(context).aboutToRock,
                  textScaleFactor: 1.25),
              Text(''),
            ],
          ),
          Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.secondary, width:2.0),
                  borderRadius: BorderRadius.circular(12)
              ),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                  children: <Widget>[
                    CountdownTimer(to: widget.user.student!.nextLesson!.from, boxWidth: boxWidth),
                    Text(''),
                    Text(formattedDateTime(context, widget.user.student!.nextLesson!.from), textScaleFactor: 1.25)
                  ]
              )
          ),
          Text('', textScaleFactor: 1.25,
              style: TextStyle(height: 4.0)),
        ]
    );
  }
}