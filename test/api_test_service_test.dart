import 'package:test/test.dart';
import 'package:musicscool/services/api_test_service.dart';

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
    var user = await api.user;
    expect(user, isNotNull);
    expect(user.email, isNotEmpty);
    expect(user.student, isNotNull);
    expect(user.student!.nextLesson, isNotNull);
    expect(user.student!.nextLesson!.from.isUtc, isTrue);
  });
/*
  test('lessons browse after/before works', () async {
    var api = ApiTestService();
    await api.login(username: 'someone@acme.com', password: 'password');
    DateTime now = DateTime.now();
    List<Lesson> lessons = await api.getLessons();
    expect(lessons.length, ApiTestService.pageSize);
    expect(lessons.last.from.isAfter(now), isTrue);
    print(json.encode(lessons[0].toJson()));
    List<Lesson> prevLessons = await api.getLessons(before:lessons.first.from);
    expect(prevLessons.length, lessThan(ApiTestService.pageSize));
    expect(prevLessons.first == lessons.first, isFalse);
    expect(prevLessons.first.from.isAfter(now), isFalse);

    lessons = await api.getLessons(after:lessons.last.from);
    expect(lessons.length, ApiTestService.pageSize);
    expect(lessons.first == prevLessons.first, isFalse);
    print('first.id=${lessons.first.id}, from=${lessons.first.from}');
    print('last.id=${lessons.last.id}, from=${lessons.last.from}');

    lessons = await api.getLessons(after:lessons.last.from);
    expect(lessons.length, lessThan(ApiTestService.pageSize));
  });
 */
}
