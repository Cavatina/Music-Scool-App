import 'dart:convert';

import 'package:my_musicscool_app/models/lesson.dart';
import 'package:test/test.dart';
import 'package:my_musicscool_app/services/api_test_service.dart';

void main() {
  test('login returns token', () async {
    var api = ApiTestService();
    expect(api.login(username: 'someone@acme.com', password: '123'),
        throwsException);
    expect(await api.login(username: 'someone@acme.com', password: 'password'),
        isNotEmpty);
  });

  test('student returned from logged in api', () async {
    var api = ApiTestService();
    await api.login(username: 'someone@acme.com', password: 'password');
    expect(await api.student, isNotNull);
    expect((await api.student).email, isNotEmpty);
  });

  test('lessons with pagination works', () async {
    var api = ApiTestService();
    await api.login(username: 'someone@acme.com', password: 'password');
    DateTime now = DateTime.parse('2020-11-23 22:46:00');
    List<Lesson> lessons = await api.getNextLessons();
    expect(lessons.length, ApiTestService.pageSize);
    expect(lessons[0].start.isAfter(now), isTrue);
    print(json.encode(lessons[0].toJson()));
    List<Lesson> prevLessons = await api.getPrevLessons();
    expect(prevLessons.length, ApiTestService.pageSize);
    expect(prevLessons[0] == lessons[0], isFalse);
    expect(prevLessons[0].start.isAfter(now), isFalse);

    lessons = await api.getNextLessons();
    expect(lessons.length, lessThan(ApiTestService.pageSize));
    expect(lessons.length, isNot(0));
    expect(lessons[0] == prevLessons[0], isFalse);

    lessons = await api.getNextLessons();
    expect(lessons.length, equals(0));
  });
}