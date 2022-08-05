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
import 'package:musicscool/models/available_dates.dart';
import 'package:musicscool/models/time_slot.dart';
import 'package:musicscool/service_locator.dart';
import 'package:musicscool/viewmodels/auth.dart';
import 'package:musicscool/generated/l10n.dart';

import 'duration_select.dart';

typedef TimeSlotSelect = void Function(TimeSlot? selected);

class TimeSlotPicker extends StatefulWidget {
  TimeSlotPicker({
    required this.slot,
    required this.date,
    required this.duration,
    required this.onSelect
  });

  final TimeSlot? slot;
  final AvailableDates date;
  final LessonDuration duration;
  final TimeSlotSelect onSelect;

  @override
  _TimeSlotPickerState createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  _TimeSlotPickerState();

  Future<List<TimeSlot>>? future_slots;

  @override
  void initState() {
    super.initState();
    future_slots = locator<AuthModel>().api.getTimeSlots(
      teacher: widget.date.teacher,
      date: widget.date.date,
      duration: widget.duration
    );
  }

  Widget timeSlots(BuildContext context, List<TimeSlot> slots) {
    if (slots.isEmpty) {
      return Text(S.of(context).noLessonsFound);
    }

    return DropdownButton<TimeSlot>(
      hint: Text(S.of(context).time),
      isExpanded: true,
      value: widget.slot,
      items: slots.map((slot) {
        return DropdownMenuItem<TimeSlot>(
          value: slot,
          child: Text('${slot.time}'),
        );
        }).toList(),
      onChanged: (newVal) {
        widget.onSelect(newVal);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TimeSlot>>(
        future: future_slots,
        builder: (context, AsyncSnapshot<List<TimeSlot>> snapshot) {
          if (snapshot.hasData) {
            return timeSlots(context, snapshot.data!);
          }
          else {
            return waitingSmall();
          }
        }
    );
 }
}
