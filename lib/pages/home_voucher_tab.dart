
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicscool/helpers.dart';
import 'package:musicscool/models/instrument.dart';
import 'package:musicscool/models/user.dart';
import 'package:musicscool/service_locator.dart';
import 'package:musicscool/services/api.dart';
import 'package:musicscool/viewmodels/auth.dart';
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
          instrument = newVal;
        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ListTile(
          title: Row(children: [
            Expanded(
              flex: 5,
              child: Text(S.of(context).requestLesson)
            ),
            Expanded(
              flex: 5,
              child: instrumentsDropdown(context, instrument, _instruments)
            )],
          ),
          leading: Icon(CupertinoIcons.question_circle),
        ),
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

