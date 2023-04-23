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

import 'package:musicscool/models/available_dates.dart';
import 'package:musicscool/models/instrument.dart';
import 'package:musicscool/models/lesson_cancel_info.dart';
import 'package:musicscool/models/teacher.dart';
import 'package:musicscool/models/time_slot.dart';
import 'package:musicscool/models/user.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:musicscool/models/voucher.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:musicscool/widgets/duration_select.dart';

class ApiError implements Exception {}

// Generic server related errors.
class ServerError implements ApiError {}

// Method specific errors. Usually a problem of invalid input.
class AuthenticationFailed implements ApiError {}
class ResetPasswordFailed implements ApiError {}

abstract class Api {
  Dio get dio;

  Future<String> login({required String username, required String password});
  Future<void> resetPassword({required String username});

  set token (String token);
  Future<User> get user;
  Future<List<Lesson>> getHomeworkLessons({int page = 0, int perPage = 20});
  Future<List<Lesson>> getUpcomingLessons({int page = 0, int perPage = 20, bool withCancelled = true});

  Future<LessonCancelInfo> cancelLessonInfo({required int id});
  Future<Lesson?> cancelLesson({required int id});

  Future<String> downloadHomework({required String url, required String filename, required void Function(int, int) onReceiveProgress});

  Future<List<Voucher>> getVouchers();

  Future<List<Instrument>> getInstruments();

  Future<List<AvailableDates>> getAvailableDates({required Instrument instrument});
  Future<List<TimeSlot>> getTimeSlots({required Teacher teacher, required DateTime date, required LessonDuration duration});
  Future<void> createLessonRequest({
    required Voucher voucher,
    required AvailableDates date,
    required Instrument instrument,
    required TimeSlot time,
    required LessonDuration duration});

  Future<void> registerDevice({required String deviceToken, required String locale});
  Future<void> removeDevice({required String deviceToken});
}
