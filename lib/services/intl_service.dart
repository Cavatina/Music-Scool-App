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

import 'package:intl/date_symbol_data_local.dart'; //for date locale
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class IntlService {
  Location currentLocation;
  Future<IntlService> init() async {
    await initializeDateFormatting();
    tz.initializeTimeZones();
    String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    currentLocation = getLocation(currentTimeZone);
    return this;
  }
}