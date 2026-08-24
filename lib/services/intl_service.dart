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

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

class IntlService {
  static const _timezoneAliases = <String, String>{
    'Europe/Kiev': 'Europe/Kyiv',
    'Asia/Calcutta': 'Asia/Kolkata',
    'Asia/Saigon': 'Asia/Ho_Chi_Minh',
    'America/Buenos_Aires': 'America/Argentina/Buenos_Aires',
    'GMT': 'UTC',
  };

  late Location currentLocation;
  bool _useDeviceLocalTime = false;

  Future<IntlService> init() async {
    // MaterialLocalizations call initializeDateFormattingCustom,
    // which is incompatible with this function:
    //    await initializeDateFormatting();
    tz.initializeTimeZones();
    try {
      final identifier = (await FlutterTimezone.getLocalTimezone()).identifier;
      final location = _locationForIdentifier(identifier);
      if (location != null) {
        currentLocation = location;
        return this;
      }
      await _recordTimezoneFallback(
        'Could not resolve timezone identifier: $identifier',
      );
    } catch (e, stack) {
      await _recordTimezoneFallback(
        'Failed to read device timezone',
        e,
        stack,
      );
    }
    _useDeviceLocalTime = true;
    currentLocation = UTC;
    return this;
  }

  Location? _locationForIdentifier(String identifier) {
    final candidates = <String>{
      identifier,
      if (_timezoneAliases.containsKey(identifier)) _timezoneAliases[identifier]!,
    };
    for (final candidate in candidates) {
      try {
        return getLocation(candidate);
      } catch (_) {}
    }
    return null;
  }

  Future<void> _recordTimezoneFallback(
    String message, [
    Object? error,
    StackTrace? stack,
  ]) async {
    await FirebaseCrashlytics.instance.recordError(
      error ?? Exception(message),
      stack ?? StackTrace.current,
      reason: message,
    );
  }

  DateTime localDateTime(DateTime when) {
    if (_useDeviceLocalTime) {
      return when.toLocal();
    }
    return TZDateTime.from(when, currentLocation);
  }

  String formatCalendarDate(DateTime when) {
    return DateFormat('yyyy-MM-dd').format(localDateTime(when));
  }
}
