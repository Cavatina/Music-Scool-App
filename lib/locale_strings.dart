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

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'package:musicscool/service_locator.dart';
import 'package:musicscool/services/intl_service.dart';

import 'generated/l10n.dart';

String cancelledText(BuildContext context, String statusKey) {
  switch(statusKey) {
    case 'STUDENT_CANCELLED': return S.of(context).statusStudentCancelled;
    case 'STUDENT_CANCELLED_LATE': return S.of(context).statusStudentCancelledLate;
    case 'TEACHER_CANCELLED': return S.of(context).statusTeacherCancelled;
    case 'STUDENT_ABSENT': return S.of(context).statusStudentAbsent;
    default:
      return '';
  }
}

String instrumentText(BuildContext context, String instrumentKey) {
  switch (instrumentKey) {
    case 'Bass guitar': return S.of(context).bassGuitar;
    case 'Guitar': return S.of(context).guitar;
    case 'Rhythm Class': return S.of(context).rhythmClass;
    case 'Piano': return S.of(context).piano;
    case 'Vocal': return S.of(context).vocals;
    case 'Vocals': return S.of(context).vocals;
    case 'Drums': return S.of(context).drums;
    case 'Songwriting': return S.of(context).songwriting;
    case 'EDM': return S.of(context).EDM;
    default:
      return instrumentKey;
  }
}

String formattedDate(BuildContext context, DateTime time) {
    TZDateTime local = locator<IntlService>().localDateTime(time);
    return DateFormat.yMMMEd().format(local);
}

String formattedDateTime(BuildContext context, DateTime time) {
    TZDateTime local = locator<IntlService>().localDateTime(time);
    return S.of(context).dateAtTime(DateFormat.yMMMEd().format(local),
      DateFormat.jm().format(local));
}
