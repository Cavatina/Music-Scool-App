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

import 'dart:async';
import 'dart:convert' show json;
import 'dart:math';
import 'package:musicscool/models/instrument.dart';
import 'package:musicscool/models/lesson_cancel_info.dart';
import 'package:musicscool/services/api.dart';
import 'package:musicscool/models/user.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:dio/dio.dart';

class ApiTestService implements Api {
  String _token = '';
  final Dio _dio = Dio();

  @override
  Dio get dio {
    return _dio;
  }

  @override
  Future<String> login({required String username, required String password}) async {
    User s = await user;
    if (username == s.email && password == 'password') {
      _token = 'dummy-token';
      return _token;
    }
    throw Exception('Illegal login');
  }

  @override
  Future<void> resetPassword({required String username}) async {
    throw Exception('Not implemented');
  }

  @override
  set token (String token) {
    _token = token;
  }

  @override
  Future<User> get user async {
    User u = User.fromJson(json.decode(testUser)['data']);
    if (u.student?.nextLesson != null) {
      u.student!.nextLesson!.from =
        u.student!.nextLesson!.from.add(fixtureTimeDelta);
    }
    return u;
  }

  Future<List<Lesson>> allLessons() async {
    return _cachedLessons();
  }

  @override
  Future<List<Lesson>> getUpcomingLessons({int page = 0, int perPage = 20, withCancelled = true}) async {
    DateTime now = DateTime.now();
    List<Lesson> lessons = await allLessons();
    int firstOffset = 0;
    for (; firstOffset < lessons.length; ++firstOffset) {
      if (lessons[firstOffset].from.isAfter(now)) break;
    }
    int start = min(lessons.length, firstOffset + page * perPage);
    print('upcomingStartIndex:${start}');
    int end = min(lessons.length, start+perPage);
    return lessons.sublist(start, end);
  }

  @override
  Future<List<Lesson>> getHomeworkLessons({page = 0, perPage = 20}) async {
    List<Lesson> lessons = await allLessons();
    int i = 0;
    int start = page * perPage;
    int end = start + perPage;
    if (start >= lessons.length) return <Lesson> [];
    return lessons.reversed.where((Lesson lesson) {
      if (lesson.homework != null) {
        if (i >= start && i < end) return true;
        ++i;
      }
      return false;
    }).toList();
    // List<Lesson> out = <Lesson>[];
    // for (int i = 0; i < _allLessons.length; ++i) {
    //   if (_allLessons[i].homework != null) {
    //     out.add(_allLessons[i]);
    //   }
    // }
    // return List<Lesson>(out.reversed);
  }

  @override
  Future<LessonCancelInfo> cancelLessonInfo({required int id}) async {
    List<Lesson> lessons = await allLessons();
    for (int i=0; i<lessons.length; ++i) {
      if (lessons[i].id == id) {
        return LessonCancelInfo(id, lessons[i].from, true, 0, 3);
      }
    }
    throw ServerError();
  }

  @override
  Future<Lesson> cancelLesson({required int id}) async {
    List<Lesson> lessons = await allLessons();
    for (int i=0; i<lessons.length; ++i) {
      if (lessons[i].id == id) {
        lessons[i] = lessons[i].copyWith(cancelled: true, status: 'STUDENT_CANCELLED');
        return lessons[i];
      }
    }
    throw ServerError();
  }

  @override
  Future<String> downloadHomework({required String url, required String filename,
                                   required void Function(int, int) onReceiveProgress}) async {
    return '';
  }

  // @override
  // Future<List<Lesson>> getLessons({DateTime before, DateTime after}) async {
  //   return _cachedLessons().then((lessons) {
  //     if (before != null) {
  //       for (int i = _allLessons.length - 1; i > 0; --i) {
  //         if (_allLessons[i].from.isBefore(before)) {
  //           return _allLessons.sublist(max(0, i-pageSize+1), i+1);
  //         }
  //       }
  //     }
  //     // Default: 8 Weeks before now
  //     after ??= DateTime.now().subtract(Duration(days: 7*8));
  //     for (int i = 0; i < _allLessons.length; ++i) {
  //       if (_allLessons[i].from.isAfter(after)) {
  //         return _allLessons.sublist(i, min(i+pageSize, _allLessons.length));
  //       }
  //     }
  //     return [];
  //     });
  // }

  static Duration _fixtureTimeDelta() {
    DateTime now = DateTime.now();
    return Duration(days: now.difference(DateTime.parse('2020-11-23 22:46:00')).inDays);
  }

  @override
  Future<List<Instrument>> getInstruments() async {
    List<dynamic> js = json.decode(testInstruments)['data'];
    return js.map<Instrument>((jsObj) => Instrument.fromJson(jsObj)).toList();
  }

  Future<List<Lesson>> _cachedLessons() async {
    if (_lessonIndex == -1) {
      List<dynamic> js = json.decode(testLessons)['data'];
      _allLessons = js.map<Lesson>((jsObj) => Lesson.fromJson(jsObj)).toList();
      User u = await user;

      _lessonIndex = _allLessons.length;
      for (int i = 0; i < _allLessons.length; ++i) {
        _allLessons[i] = _allLessons[i].copyWith(
            from: _allLessons[i].from.add(fixtureTimeDelta),
            until: _allLessons[i].until.add(fixtureTimeDelta)
        );
        if (u.student?.nextLesson?.id == _allLessons[i].id) {
          _allLessons[i].isNext = true;
        }
      }
      return _allLessons;
    }
    return _allLessons;
  }

  late List<Lesson> _allLessons;
  int _lessonIndex = -1;
  static const pageSize = 25;
  static final fixtureTimeDelta = _fixtureTimeDelta();
}

String testUser = '''
{"data":{"name":"Mrs. Pixie","firstName":"Mrs.","email":"someone@acme.com","schoolContact":{"name":"Roan Segers","phone":"+4512345678","email":"info@musicschooI.dk", "address": ["123 some street", "4000 Roskilde"]},"student":{"nextLesson":{"id":1138, "from":"2020-11-28T14:00:00.000000Z"}}}}
''';

String testLessons = '''
{"data":[{"id":1116,"from":"2020-05-02T13:00:00.000000Z","until":"2020-05-02T13:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"}},{"id":1117,"from":"2020-05-09T13:00:00.000000Z","until":"2020-05-09T13:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"}},{"id":1118,"from":"2020-05-16T13:00:00.000000Z","until":"2020-05-16T13:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"}},{"id":1119,"from":"2020-05-23T13:00:00.000000Z","until":"2020-05-23T13:30:00.000000Z","status":"STUDENT_CANCELLED_LATE","teacher":{"id":1,"name":"Roan Segers"},"cancelled":true},{"id":1120,"from":"2020-06-06T13:00:00.000000Z","until":"2020-06-06T13:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"}},{"id":1121,"from":"2020-06-13T13:00:00.000000Z","until":"2020-06-13T13:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"}},{"id":1397,"from":"2020-06-13T13:30:00.000000Z","until":"2020-06-13T14:00:00.000000Z","status":"STUDENT_CANCELLED_LATE","teacher":{"id":1,"name":"Roan Segers"},"cancelled":true,"replacesLesson":{"id":1104,"from":"2020-01-25T14:00:00.000000Z"}},{"id":1122,"from":"2020-06-20T13:00:00.000000Z","until":"2020-06-20T13:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"}},{"id":1123,"from":"2020-06-27T13:00:00.000000Z","until":"2020-06-27T13:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"}},{"id":3071,"from":"2020-08-15T12:30:00.000000Z","until":"2020-08-15T13:00:00.000000Z","status":"STUDENT_ABSENT","teacher":{"id":1,"name":"Roan Segers"},"cancelled":true,"replacesLesson":{"id":1091,"from":"2019-11-16T14:00:00.000000Z"}},{"id":1124,"from":"2020-08-15T13:00:00.000000Z","until":"2020-08-15T13:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"}},{"id":1125,"from":"2020-08-22T13:00:00.000000Z","until":"2020-08-22T13:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"}},{"id":1126,"from":"2020-08-29T13:00:00.000000Z","until":"2020-08-29T13:30:00.000000Z","status":"STUDENT_CANCELLED_LATE","teacher":{"id":1,"name":"Roan Segers"},"cancelled":true},{"id":1127,"from":"2020-09-05T10:30:00.000000Z","until":"2020-09-05T11:00:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"},"relocated":true},{"id":1128,"from":"2020-09-12T13:00:00.000000Z","until":"2020-09-12T13:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"},"homework":[{"message":"16th kick grooves","fileName":"homework\/Grooves 16th Kick.pdf","fileUrl":"http:\/\/localhost:8000\/api\/v1\/homework\/9"}]},{"id":1129,"from":"2020-09-19T13:00:00.000000Z","until":"2020-09-19T13:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"}},{"id":1130,"from":"2020-09-26T11:00:00.000000Z","until":"2020-09-26T11:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"},"relocated":true,"homework":[{"message":"\u00d8velse til fills. Spil m\u00f8nstrene med snare og ride b\u00e6kken samtidligt henover stortromme p\u00e5 takt (hihat off beat)","fileName":"homework\/LATI-050.pdf","fileUrl":"http:\/\/localhost:8000\/api\/v1\/homework\/21","linkUrl":"https:\/\/www.youtube.com\/embed\/M0zfNytpoeQ"}]},{"id":1131,"from":"2020-10-03T13:00:00.000000Z","until":"2020-10-03T13:30:00.000000Z","status":"STUDENT_CANCELLED","teacher":{"id":1,"name":"Roan Segers"},"cancelled":true,"replacementLesson":{"id":3946,"from":"2020-10-24T12:00:00.000000Z"}},{"id":1132,"from":"2020-10-10T06:30:00.000000Z","until":"2020-10-10T07:00:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"},"relocated":true},{"id":3946,"from":"2020-10-24T12:00:00.000000Z","until":"2020-10-24T12:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"},"replacesLesson":{"id":1131,"from":"2020-10-03T13:00:00.000000Z"}},{"id":1133,"from":"2020-10-24T12:30:00.000000Z","until":"2020-10-24T13:00:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"},"relocated":true,"homework":[{"message":"Behind the Blood - Katatonia","fileName":"homework\/Behind The Blood.pdf","fileUrl":"http:\/\/localhost:8000\/api\/v1\/homework\/182","linkUrl":"https:\/\/www.youtube.com\/embed\/nQaN2elJ-dQ"}]},{"id":1134,"from":"2020-10-31T14:00:00.000000Z","until":"2020-10-31T14:30:00.000000Z","status":"STUDENT_CANCELLED_LATE","teacher":{"id":1,"name":"Roan Segers"},"cancelled":true,"homework":[{"message":"Trommenoder forklaring","fileName":"homework\/Trommenoder.pdf","fileUrl":"http:\/\/localhost:8000\/api\/v1\/homework\/209"},{"message":"F\u00f8rste 30 sekunder :)","fileName":"homework\/Behind The Blood.pdf","fileUrl":"http:\/\/localhost:8000\/api\/v1\/homework\/211"}]},{"id":1135,"from":"2020-11-07T14:00:00.000000Z","until":"2020-11-07T14:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"}},{"id":1136,"from":"2020-11-14T14:00:00.000000Z","until":"2020-11-14T14:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"},"homework":[{"message":"Update Behind the Blood","fileName":"homework\/Behind The Blood.pdf","fileUrl":"http:\/\/localhost:8000\/api\/v1\/homework\/261"}]},{"id":1137,"from":"2020-11-21T14:00:00.000000Z","until":"2020-11-21T14:30:00.000000Z","status":"STUDENT_PRESENT","teacher":{"id":1,"name":"Roan Segers"},"homework":[{"message":"R L K grouping som fill in over 2 takter","fileName":"homework\/RLK grouping.pdf","fileUrl":"http:\/\/localhost:8000\/api\/v1\/homework\/284"}]},{"id":1138,"from":"2020-11-28T14:00:00.000000Z","until":"2020-11-28T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"instrument":{"id":10, "name":"Drums"},"pending":true},{"id":1139,"from":"2020-12-05T14:00:00.000000Z","until":"2020-12-05T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":1140,"from":"2020-12-12T14:00:00.000000Z","until":"2020-12-12T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":1141,"from":"2020-12-19T14:00:00.000000Z","until":"2020-12-19T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4573,"from":"2021-01-09T14:00:00.000000Z","until":"2021-01-09T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4574,"from":"2021-01-16T14:00:00.000000Z","until":"2021-01-16T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4575,"from":"2021-01-23T14:00:00.000000Z","until":"2021-01-23T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4576,"from":"2021-01-30T14:00:00.000000Z","until":"2021-01-30T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4577,"from":"2021-02-06T14:00:00.000000Z","until":"2021-02-06T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4578,"from":"2021-02-13T14:00:00.000000Z","until":"2021-02-13T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4579,"from":"2021-02-20T14:00:00.000000Z","until":"2021-02-20T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4580,"from":"2021-03-06T14:00:00.000000Z","until":"2021-03-06T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4581,"from":"2021-03-13T14:00:00.000000Z","until":"2021-03-13T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4582,"from":"2021-03-20T14:00:00.000000Z","until":"2021-03-20T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4583,"from":"2021-03-27T14:00:00.000000Z","until":"2021-03-27T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4584,"from":"2021-04-10T13:00:00.000000Z","until":"2021-04-10T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4585,"from":"2021-04-17T13:00:00.000000Z","until":"2021-04-17T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4586,"from":"2021-04-24T13:00:00.000000Z","until":"2021-04-24T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4587,"from":"2021-05-01T13:00:00.000000Z","until":"2021-05-01T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4588,"from":"2021-05-08T13:00:00.000000Z","until":"2021-05-08T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4589,"from":"2021-05-15T13:00:00.000000Z","until":"2021-05-15T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4590,"from":"2021-05-29T13:00:00.000000Z","until":"2021-05-29T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4591,"from":"2021-06-05T13:00:00.000000Z","until":"2021-06-05T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4592,"from":"2021-06-12T13:00:00.000000Z","until":"2021-06-12T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4593,"from":"2021-06-19T13:00:00.000000Z","until":"2021-06-19T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4594,"from":"2021-06-26T13:00:00.000000Z","until":"2021-06-26T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4595,"from":"2021-08-14T13:00:00.000000Z","until":"2021-08-14T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4596,"from":"2021-08-21T13:00:00.000000Z","until":"2021-08-21T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4597,"from":"2021-08-28T13:00:00.000000Z","until":"2021-08-28T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4598,"from":"2021-09-04T13:00:00.000000Z","until":"2021-09-04T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4599,"from":"2021-09-11T13:00:00.000000Z","until":"2021-09-11T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4600,"from":"2021-09-18T13:00:00.000000Z","until":"2021-09-18T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4601,"from":"2021-09-25T13:00:00.000000Z","until":"2021-09-25T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4602,"from":"2021-10-02T13:00:00.000000Z","until":"2021-10-02T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4603,"from":"2021-10-09T13:00:00.000000Z","until":"2021-10-09T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4604,"from":"2021-10-16T13:00:00.000000Z","until":"2021-10-16T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4605,"from":"2021-10-30T13:00:00.000000Z","until":"2021-10-30T13:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4606,"from":"2021-11-06T14:00:00.000000Z","until":"2021-11-06T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4607,"from":"2021-11-13T14:00:00.000000Z","until":"2021-11-13T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4608,"from":"2021-11-20T14:00:00.000000Z","until":"2021-11-20T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4609,"from":"2021-11-27T14:00:00.000000Z","until":"2021-11-27T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4610,"from":"2021-12-04T14:00:00.000000Z","until":"2021-12-04T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4611,"from":"2021-12-11T14:00:00.000000Z","until":"2021-12-11T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true},{"id":4612,"from":"2021-12-18T14:00:00.000000Z","until":"2021-12-18T14:30:00.000000Z","status":"PENDING","teacher":{"id":1,"name":"Roan Segers"},"pending":true}]}
''';

String testInstruments =
'''{"data":[{"id":5,"name":"Bass guitar"},{"id":6,"name":"Guitar"},{"id":7,"name":"Piano"},{"id":9,"name":"Vocal"},{"id":10,"name":"Drums"},{"id":11,"name":"Songwriting"},{"id":13,"name":"Rhythm Class"}]}
''';
