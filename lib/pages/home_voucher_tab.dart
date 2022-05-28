
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicscool/helpers.dart';
import 'package:musicscool/models/available_dates.dart';
import 'package:musicscool/models/instrument.dart';
import 'package:musicscool/models/time_slot.dart';
import 'package:musicscool/models/user.dart';
import 'package:musicscool/service_locator.dart';
import 'package:musicscool/services/api.dart';
import 'package:musicscool/viewmodels/auth.dart';
import 'package:musicscool/widgets/available_date_picker.dart';
import 'package:musicscool/widgets/duration_select.dart';
import 'package:musicscool/widgets/time_slot_picker.dart';
import 'package:provider/provider.dart';
import 'package:musicscool/generated/l10n.dart';

class RequestLesson extends StatefulWidget {
  const RequestLesson({required this.user});

  final User user;

  @override
  _RequestLessonState createState() => _RequestLessonState();
}

class _RequestLessonState extends State<RequestLesson> {
  List<Instrument>? _instruments;
  Instrument? instrument;
  AvailableDates? date;
  LessonDuration duration = LessonDuration.HalfHour;
  TimeSlot? slot;

  @override
  void initState() {
    super.initState();
    locator<AuthModel>().getInstruments().then((List<Instrument> instruments) {
      setState(() {
        _instruments = instruments;
      });
    });
  }

  Widget instrumentsDropdown(BuildContext context, Instrument? selected, List<Instrument>? instruments) {
    return DropdownButton<Instrument>(
      hint: Text(S.of(context).instrument),
      isExpanded: true,
      value: selected,
      items: instruments?.map((instrument) {
        return DropdownMenuItem<Instrument>(
          value: instrument,
          child: Text(instrument.name),
        );
        }).toList(),
      onChanged: (newVal) {
        setState(() {
          if (instrument != newVal) {
            instrument = newVal;
            date = null;
            slot = null;
          }
        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      children: <Widget>[
        ListTile(
          title: instrumentsDropdown(context, instrument, _instruments),
          subtitle: Text(''),
          leading: Icon(CupertinoIcons.music_note),
        ),
        ListTile(
          key: Key(instrument.toString()),
          title: instrument == null ? Container() : AvailableDatePicker(
            date: date,
            instrument: instrument!,
            duration: duration,
            onSelect: (selected) {
              setState(() {
                date = selected;
              });
            }
          ),
          subtitle: Text(''),
          leading: Icon(CupertinoIcons.calendar),
        ),
        ListTile(
          title: DurationSelect(
            selected: duration,
            onSelect: (selected) {
              if (duration != selected) {
                setState(() {
                  duration = selected;
                  slot = null;
                });
              }
            },
          ),
          subtitle: Text(''),
          leading: Icon(CupertinoIcons.timer),
        ),
        ListTile(
          key: Key(date.toString()+duration.toString()),
          title: date == null ? Container() : TimeSlotPicker(
            slot: slot,
            date: date!,
            duration: duration,
            onSelect: (selected) {
              if (slot != selected) {
                setState(() {
                  slot = selected;
                });
              }
            },
          ),
          subtitle: Text(''),
          leading: Icon(CupertinoIcons.clock)
        ),
        ListTile(
          title: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: date == null ? Theme.of(context).disabledColor : Theme.of(context).colorScheme.secondary,
              primary: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.all(12.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
              ),
              minimumSize: Size(84, 64)
            ),
            onPressed: (date == null) ? null : () {

            },
            child: Text(S.of(context).requestLesson)
          )
        )
      ]
    );
  }
}

Widget voucherView(BuildContext context) {
  return Consumer<AuthModel>(
      builder: (context, model, child) {
        return FutureBuilder<User>(
          future: model.user,
          builder: (context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data?.student != null) {
                return RequestLesson(user: snapshot.data!);
              }
              else {
                return Column(
                  children: <Widget> [
                    Text(S.of(context).youHaveNoActiveVouchers)
                  ]
                );
              }
            }
            else if (snapshot.hasError) {
              if (!(snapshot.error is AuthenticationFailed)) {
                showUnexpectedError(context);
              }
              return Container();
            }
            else {
              return waiting();
            }
          }
        );
    }
  );
}

