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
import 'package:flutter/material.dart';
import 'package:musicscool/helpers.dart';
import 'package:musicscool/locale_strings.dart';
import 'package:musicscool/models/available_dates.dart';
import 'package:musicscool/models/instrument.dart';
import 'package:musicscool/service_locator.dart';
import 'package:musicscool/viewmodels/auth.dart';
import 'package:musicscool/generated/l10n.dart';

import 'duration_select.dart';

typedef AvailableDateSelect = void Function(AvailableDates? selected);

class AvailableDatePicker extends StatefulWidget {
  AvailableDatePicker({
    required this.date,
    required this.instrument,
    required this.duration,
    required this.onSelect
  });

  final AvailableDates? date;
  final Instrument instrument;
  final LessonDuration duration;
  final AvailableDateSelect onSelect;

  @override
  _AvailableDatePickerState createState() => _AvailableDatePickerState(instrument: instrument);
}

class _AvailableDatePickerState extends State<AvailableDatePicker> {
  _AvailableDatePickerState({required this.instrument});

  final Instrument instrument;
  Future<List<AvailableDates>>? future_dates;

  @override
  void initState() {
    super.initState();
    future_dates = locator<AuthModel>().api.getAvailableDates(instrument: instrument);
  }

  Widget availableDates(BuildContext context, List<AvailableDates> dates) {
    if (dates.isEmpty) {
      return Text(S.of(context).noAvailableDates);
    }

    return DropdownButton<AvailableDates>(
      hint: Text(S.of(context).date),
      style: TextStyle(fontSize: 12),
      isExpanded: true,
      value: widget.date,
      items: dates.map((date) {
        return DropdownMenuItem<AvailableDates>(
          value: date,
          child: Text('${formattedDate(context, date.date)} - ${date.teacher.name}'),
        );
        }).toList(),
      onChanged: (newVal) {
        widget.onSelect(newVal);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AvailableDates>>(
        future: future_dates,
        builder: (context, AsyncSnapshot<List<AvailableDates>> snapshot) {
          if (snapshot.hasData) {
            return availableDates(context, snapshot.data!);
          }
          else {
            return waitingSmall();
          }
        }
    );
 }
}
