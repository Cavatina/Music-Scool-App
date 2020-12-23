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

import 'package:musicscool/models/lesson_cancel_info.dart';
import 'package:musicscool/models/user.dart';
import 'package:musicscool/models/lesson.dart';
import 'dart:async';

class ApiError implements Exception {}

// Generic server related errors.
class ServerError implements ApiError {}

// Method specific errors. Usually a problem of invalid input.
class AuthenticationFailed implements ApiError {}
class ResetPasswordFailed implements ApiError {}

abstract class Api {
  Future<String> login({String username, String password});
  Future<void> resetPassword({String username});

  set token (String token);
  Future<User> get user;
  Future<List<Lesson>> getHomeworkLessons({page = 0, perPage = 20});
  Future<List<Lesson>> getUpcomingLessons({page = 0, perPage = 20});

  Future<LessonCancelInfo> cancelLessonInfo({int id});
  Future<Lesson> cancelLesson({int id});

  Future<String> downloadHomework({String url, String filename});
}
