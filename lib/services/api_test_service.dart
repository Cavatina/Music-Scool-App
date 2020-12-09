/* My Music'Scool - Copyright (C) 2020  Music'Scool DK

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
import 'package:musicscool/services/api.dart';
import 'package:musicscool/models/student.dart';
import 'package:musicscool/models/lesson.dart';


class ApiTestService implements Api {
  @override
  Future<String> login({String username, String password}) async {
    Student s = await student;
    if (username == s.email && password == 'password') return 'dummy-token';
    throw Exception('Illegal login');
  }

  @override
  Future<Student> get student async {
    return Student.fromJson(json.decode(testStudent));
  }

  Future<List<Lesson>> allLessons() async {
    return _cachedLessons();
  }

  @override
  Future<List<Lesson>> getPrevLessons() async {
    return _cachedLessons().then((lessons) {
      int itemCount = min(_prevLessonIndex, pageSize);
      _prevLessonIndex -= itemCount;
      return lessons.sublist(_prevLessonIndex, _prevLessonIndex + itemCount);
    });
  }

  @override
  Future<List<Lesson>> getNextLessons() async {
    return _cachedLessons().then((lessons) {
      int start = _lessonIndex;
      _lessonIndex = min(_lessonIndex + pageSize, lessons.length);
      return lessons.sublist(start, _lessonIndex);
      });
  }

  // Future _readFixture(String baseName) {
  //   String path = join(dirname(Platform.script.toFilePath()), 'test', 'fixtures',
  //       baseName);
  //   return File(path).readAsString().then<String>((String value) => json.decode(value));
  // }

  Future<List<Lesson>> _cachedLessons() async {
    if (_lessonIndex == -1) {
      List<dynamic> js = json.decode(testLessons);
      _allLessons = js.map<Lesson>((jsObj) => Lesson.fromJson(jsObj)).toList();
      DateTime now = DateTime.now();
      Duration diff;
      if (_allLessons.isNotEmpty) {
        diff = now.difference(DateTime.parse('2020-11-23 22:46:00'));
      }
      _lessonIndex = _allLessons.length;
      for (int i = 0; i < _allLessons.length; ++i) {
        _allLessons[i] = _allLessons[i].copyWith(
            start: _allLessons[i].start.add(Duration(days:diff.inDays))
        );
        if (_allLessons[i].start.isAfter(now) && _lessonIndex == _allLessons.length) {
          _lessonIndex = _prevLessonIndex = i;
          _allLessons[i].isNext = true;
        }
      }
      return _allLessons;
    }
    return _allLessons;
  }

  List<Lesson> _allLessons;
  int _lessonIndex = -1;
  int _prevLessonIndex = -1;
  static const pageSize = 10;
}

String testStudent = '''
{
"name": "My Favourite Student",
"email": "someone@acme.com",
"nextLesson": "2020-11-28T15:00:00",
"lessonsOwed": 0,
"lessonsPresent": 49,
"nextInvoice": "2020-10-01"
}
''';

String testLessons = '''
[
{
  "start": "2020-08-29T15:00:00", "status": "Student cancelled too late", "catchUp": null
},
{
"start": "2020-09-05T12:30:00", "status": "Student present", "catchUp": null
},
{
"start": "2020-09-12T15:00:00", "status": "Student present", "catchUp": null,
"homework": [
{"description": "16th kick grooves",
"downloadTitle": "Grooves 16th Kick.pdf",
"downloadUrl": "https://www.musicscool.dk/my/public/homework/download/9"}
]
},
{
"start": "2020-09-19T15:00:00", "status": "Student present", "catchUp": null
},
{
"start": "2020-09-26T13:00:00", "status": "Student present", "catchUp": null,
"homework": [
{"description": "Øvelse til fills. Spil mønstrene med snare og ride bækken samtidligt henover stortromme på takt (hihat off beat)",
"downloadTitle": "LATI-050.pdf",
"downloadUrl": "https://www.musicscool.dk/my/public/homework/download/21",
"linkUrl": "https://www.youtube.com/embed/M0zfNytpoeQ"}
]
},
{
"start": "2020-10-03T15:00:00", "status": "Student cancelled", "catchUp": "2020-10-24T14:00:00"
},
{
"start": "2020-10-10T08:30:00", "status": "Student present", "catchUp": null
},
{
"start": "2020-10-24T14:00:00", "status": "Student present", "catchUp": "2020-10-03T15:00:00"
},
{
"start": "2020-10-24T14:30:00", "status": "Student present", "catchUp": null,
"homework": [
{"description": "Behind the Blood - Katatonia",
"downloadTitle": "Behind The Blood.pdf",
"downloadUrl": "https://www.musicscool.dk/my/public/homework/download/182",
"linkUrl": "https://www.youtube.com/embed/nQaN2elJ-dQ"}
]
},
{
"start": "2020-10-31T15:00:00", "status": "Student cancelled too late", "catchUp": "2020-10-03T15:00:00",
"homework": [
{"description": "Trommenoder forklaring",
"downloadTitle": "Trommenoder.pdf",
"downloadUrl": "https://www.musicscool.dk/my/public/homework/download/209"},
{"description": "Første 30 sekunder :)",
"downloadTitle": "Behind The Blood.pdf",
"downloadUrl": "https://www.musicscool.dk/my/public/homework/download/211"}
]
},
{
"start": "2020-11-07T15:00:00", "status": "Student present", "catchUp": null
},
{
"start": "2020-11-14T15:00:00", "status": "Student present", "catchUp": null,
"homework": [
{"description": "Update Behind the Blood",
"downloadTitle": "Behind The Blood.pdf",
"downloadUrl": "https://www.musicscool.dk/my/public/homework/download/261"}
]
},
{
"start": "2020-11-21T15:00:00", "status": "Student present", "catchUp": null,
"homework": [
{"description": "R L K grouping som fill in over 2 takter",
"downloadTitle": "RLK grouping.pdf",
"downloadUrl": "https://www.musicscool.dk/my/public/homework/download/284"}
]
},
{
"start": "2020-11-28T15:00:00", "status": "Awaiting status", "catchUp": null
},
{
"start": "2020-12-05T15:00:00", "status": "Awaiting status", "catchUp": null
},
{
"start": "2020-12-12T15:00:00", "status": "Awaiting status", "catchUp": null
},
{
"start": "2020-12-19T15:00:00", "status": "Awaiting status", "catchUp": null
},
{
"start": "2021-01-09T15:00:00", "status": "Awaiting status", "catchUp": null
},
{
"start": "2021-01-16T15:00:00", "status": "Awaiting status", "catchUp": null
},
{
"start": "2021-01-23T15:00:00", "status": "Awaiting status", "catchUp": null
},
{
"start": "2021-01-30T15:00:00", "status": "Awaiting status", "catchUp": null
},
{
"start": "2021-02-06T15:00:00", "status": "Awaiting status", "catchUp": null
},
{
"start": "2021-02-13T15:00:00", "status": "Awaiting status", "catchUp": null
},
{
"start": "2021-02-20T15:00:00", "status": "Awaiting status", "catchUp": null
},
{
"start": "2021-03-06T15:00:00", "status": "Awaiting status", "catchUp": null
}
]
''';
