import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget
{
  const CountdownTimer({this.to, this.boxWidth});

  final DateTime to;
  final double boxWidth;

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class DurationStrings
{
  String days = '00';
  String hours = '00';
  String minutes = '00';
  String seconds = '00';

  DurationStrings(Duration duration) {
    days = duration.inDays.toString();
    hours = (duration.inHours % Duration.hoursPerDay).toString().padLeft(2, '0');
    minutes = (duration.inMinutes % Duration.minutesPerHour).toString().padLeft(2, '0');
    seconds = (duration.inSeconds % Duration.secondsPerMinute).toString().padLeft(2, '0');
  }
}

class _CountdownTimerState extends State<CountdownTimer>
{
  DurationStrings remaining = DurationStrings(Duration());
  Timer _timer;

  _CountdownTimerState() {
    _timer = Timer.periodic(Duration(milliseconds:250),
        (Timer t) {
          DateTime now = DateTime.now();
          setState(() {
            remaining = DurationStrings(widget.to.difference(now));
          });
        }
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  Widget clockBox(double width, String value, String header) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(width*0.2),
      child: Container(
        height: width,
        width: width,
        color: Colors.black, // Color.fromRGBO(48, 48, 48, 1), //Colors.black,
        child: Column(
          children: <Widget> [
            Text(value, style: TextStyle(fontSize: width*0.7, fontWeight: FontWeight.w900)),
            Text(header, style: TextStyle(fontSize: width*0.1))
          ]
        )
      )
    );
  }

  Widget clockDiv(double width) {
    return Text(':', style: TextStyle(fontSize: width*0.7));
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        clockBox(widget.boxWidth, remaining.days, 'days'),
        clockDiv(widget.boxWidth),
        clockBox(widget.boxWidth, remaining.hours, 'hours'),
        clockDiv(widget.boxWidth),
        clockBox(widget.boxWidth, remaining.minutes, 'minutes'),
        clockDiv(widget.boxWidth),
        clockBox(widget.boxWidth, remaining.seconds, 'seconds'),
      ]
    );
  }
}