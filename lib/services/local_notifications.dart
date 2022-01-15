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

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:musicscool/generated/l10n.dart';

class LocalNotifications {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<LocalNotifications> init() async {
    const initAndroid = AndroidInitializationSettings('app_notification_icon');
    final initIOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: null);
    final initMacOS = MacOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);
    await _flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(
            android: initAndroid,
            iOS: initIOS,
            macOS: initMacOS), onSelectNotification: (String payload) async {
      print('onSelectNotification:${payload}');
      return true;
    });
    return this;
  }

  Future<void> scheduleNotification(Lesson lesson, Location timeZoneLocation) async {
    TZDateTime now = TZDateTime.now(timeZoneLocation);
    TZDateTime localTime = TZDateTime.from(lesson.from, timeZoneLocation);
    TZDateTime startOfDay = localTime
        .subtract(Duration(hours: localTime.hour, minutes: localTime.minute))
        .add(Duration(hours: 8));
    if (now.isAfter(startOfDay)) {
      startOfDay = now.add(Duration(seconds:1));
    }
    TZDateTime oneHourBefore = localTime.subtract(Duration(hours: 1));
    String localHourMinute = DateFormat.Hm().format(localTime);
    if (oneHourBefore.isAfter(startOfDay)) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
          lesson.id,
          S.current.notificationDayReminderTitle,
          S.current.notificationDayReminderBody(localHourMinute),
          startOfDay,
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  'dk.musicscool.test2-lesson-day-reminder',
                  'lesson reminder',
                  channelDescription: "Music'scool lesson reminder (morning)")),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
      print('Scheduled notification at ${startOfDay}');
    }
    if (oneHourBefore.isAfter(now)) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
          -lesson.id,
          S.current.notificationHourReminderTitle,
          S.current.notificationHourReminderBody(localHourMinute),
          oneHourBefore,
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  'dk.musicscool.test2-lesson-hour-reminder',
                  'lesson reminder',
                  channelDescription: "Music'scool lesson reminder (morning)")),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
      print('Scheduled reminder notification at ${oneHourBefore}');
    }
  }

  Future<void> scheduleNotifications(
      List<Lesson> lessons, Location timeZoneLocation) async {
    await cancelNotifications();
    for (var lesson in lessons) {
      await scheduleNotification(lesson, timeZoneLocation);
    }
  }

  Future<void> cancelNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    print('Cancelled all notifications');
  }
}
