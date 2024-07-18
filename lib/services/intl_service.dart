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

import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:flutter_timezone/flutter_timezone.dart';

class IntlService {
  late Location currentLocation;
  Future<IntlService> init() async {
    // MaterialLocalizations call initializeDateFormattingCustom,
    // which is incompatible with this function:
    //    await initializeDateFormatting();
    tz.initializeTimeZones();
    String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    currentLocation = getLocation(currentTimeZone);
    return this;
  }

  TZDateTime localDateTime(DateTime when) {
    return TZDateTime.from(when, currentLocation);
  }
}
