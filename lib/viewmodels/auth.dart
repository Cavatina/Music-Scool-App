import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:musicscool/models/lesson_cancel_info.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:musicscool/models/user.dart';
import 'package:musicscool/services/api.dart';
import 'package:musicscool/service_locator.dart';
import 'package:musicscool/services/local_notifications.dart';
import 'package:musicscool/services/intl_service.dart';
import 'dart:async';

class AuthModel extends ChangeNotifier {
  final Api api;
  final storage = FlutterSecureStorage();

  bool isLoggedIn = false;
  String _token;
  DateTime _nextLesson;

  AuthModel(this.api);

  Future<AuthModel> init() async {
    String value = await token;
    if (value?.isNotEmpty == true) {
      print('reading token from storage:${value}');
      isLoggedIn = true;
    } else {
      print('token empty!');
    }
    notifyListeners();
    return this;
  }

  Future<String> get token async {
    _token ??= await storage.read(key: 'token');
    return _token;
  }

  Future<void> login({
    @required String username,
    @required String password}) async {

    _token = await api.login(username: username, password: password);
    if (_token?.isNotEmpty == true) {
      api.token = _token;
      await storage.write(key: 'token', value: _token);
      await storage.write(key: 'lastUsername', value: username);
    }
    isLoggedIn = true;
    notifyListeners();
  }

  Future<void> resetPassword({@required String username}) async {
    return await api.resetPassword(username: username);
  }

  void logout() {
    isLoggedIn = false;
    _token = '';
    _nextLesson = null;
    storage.write(key: 'token', value: '').then((value) {});
    notifyListeners();
  }

  Future<User> get user async {
    try {
      api.token = await token;
      User user = await api.user;
      if (user.student?.nextLesson?.from != _nextLesson) {
        List<Lesson> nextLessons = await api.getUpcomingLessons(
            page: 1, perPage: 1, withCancelled: false);
        locator<LocalNotifications>().scheduleNotifications(
            nextLessons, locator<IntlService>().currentLocation);
      }
      return user;
    } on AuthenticationFailed catch (_) {
      print('AuthenticationFailed');
      logout();
      rethrow;
    }
    catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<String> get lastUsername async {
    return await storage.read(key: 'lastUsername');
  }

  Future<List<Lesson>> getUpcomingLessons({int page, int perPage}) async {
    api.token = await token;
    return await api.getUpcomingLessons(page: page, perPage: perPage);
  }

  Future<List<Lesson>> getHomeworkLessons({int page, int perPage}) async {
    api.token = await token;
    return await api.getHomeworkLessons(page: page, perPage: perPage);
  }

  Future<LessonCancelInfo> cancelLessonInfo({int id}) async {
    api.token = await token;
    return await api.cancelLessonInfo(id: id);
  }

  Future<Lesson> cancelLesson({int id}) async {
    api.token = await token;
    return await api.cancelLesson(id: id);
  }

  Future<String> downloadHomework({String url, String name}) async {
    api.token = await token;
    return await api.downloadHomework(url: url, filename: name);
  }
}
