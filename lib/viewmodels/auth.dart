import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:musicscool/models/lesson_cancel_info.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:musicscool/models/user.dart';
import 'package:musicscool/services/api.dart';
import 'package:musicscool/service_locator.dart';
import 'package:musicscool/services/local_notifications.dart';
import 'package:musicscool/services/intl_service.dart';
import 'package:musicscool/strings.dart' show apiUrl;
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:permission_handler/permission_handler.dart';

class AuthModel extends ChangeNotifier {
  final Api api;
  final storage = FlutterSecureStorage();

  bool isLoggedIn = false;
  String _token;
  bool _notificationsEnabled = true;
  DateTime _nextLesson;
  final DioCacheManager _cache = DioCacheManager(CacheConfig(
    baseUrl: apiUrl,
    defaultRequestMethod: 'GET'));

  AuthModel(this.api);

  Future<AuthModel> init() async {
    String value = await token;
    if (value?.isNotEmpty == true) {
      print('reading token from storage:${value}');
      isLoggedIn = true;
    } else {
      print('token empty!');
    }
    value = await storage.read(key: 'notificationsEnabled');
    print('notificationsEnabled:${value}');
    if (value != null && value == 'false') _notificationsEnabled = false;
    value = await storage.read(key: 'nextLesson');
    print('nextLesson:${value}');
    if (value != null && value != '') {
      try {
        _nextLesson = DateTime.parse(value);
      }
      on FormatException {
        _nextLesson = null;
      }
    }
    api.dio.interceptors.add(InterceptorsWrapper(
      onError: (DioError e, handler) {
        if (<int>[401, 403, 422].contains(e?.response?.statusCode)) {
          print('status:${e.response.statusCode}: logout!');
          logout();
        }
        return handler.next(e);
      }
    ));
    api.dio.interceptors.add(_cache.interceptor);

    notifyListeners();
    return this;
  }

  Future<String> get token async {
    _token ??= await storage.read(key: 'token');
    return _token;
  }

  bool get notificationsEnabled {
    return _notificationsEnabled;
  }

  Future<void> enableNotifications() async {
    _notificationsEnabled = true;
    print('Notifications enabled');
    await storage.write(key: 'notificationsEnabled', value: 'true');
    await scheduleNotifications();
  }
  Future<void> disableNotifications() async {
    _notificationsEnabled = false;
    print('Notifications disabled');
    await storage.write(key: 'notificationsEnabled', value: 'false');
    await cancelNotifications();
  }

  Future<void> scheduleNotifications() async {
    List<Lesson> nextLessons =
        await api.getUpcomingLessons(page: 1, perPage: 10, withCancelled: false);
    await locator<LocalNotifications>().scheduleNotifications(
        nextLessons, locator<IntlService>().currentLocation);
  }

  Future<void> cancelNotifications() async {
    await locator<LocalNotifications>().cancelNotifications();
  }

  Future<void> login(
      {@required String username, @required String password}) async {
    _token = await api.login(username: username, password: password);
    if (_token?.isNotEmpty == true) {
      api.token = _token;
      await storage.write(key: 'token', value: _token);
      await storage.write(key: 'lastUsername', value: username);
    }
    isLoggedIn = true;
    notifyListeners();
  }

  Future<String> resetPassword({@required String username}) async {
    await api.resetPassword(username: username);
    return username;
  }

  void logout() {
    isLoggedIn = false;
    _token = '';
    _nextLesson = null;
    cacheClear().then((_) {});
    storage.write(key: 'token', value: '').then((_) {});
    storage.write(key: 'nextLesson', value: '').then((_) {});
    notifyListeners();
  }

  Future<User> get user async {
    api.token = await token;
    User user = await api.user;
    DateTime newNextLesson = user?.student?.nextLesson?.from;
    if (newNextLesson != _nextLesson) {
      String nextLesson;
      if (newNextLesson != null) {
        nextLesson = newNextLesson.toIso8601String();
      }
      else {
        nextLesson = '';
      }
      await storage.write(key: 'nextLesson', value: nextLesson);
      await cacheClearPast();
      await cacheClearUpcoming();
    }
    if (notificationsEnabled && newNextLesson != null && newNextLesson != _nextLesson) {
      await scheduleNotifications();
    }
    _nextLesson = newNextLesson;
    return user;
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
    Lesson lesson = await api.cancelLesson(id: id);
    await cacheClearUpcoming();
    return lesson;
  }

  Future<String> homeworkPath({String url, String name}) async {
    List<String> urlParts = url.split('/');
    String dir;
    if (Platform.isAndroid && await Permission.storage.status.isGranted) {
      dir = (await getExternalStorageDirectories(type: StorageDirectory.documents))[0].path;
      print('ExternalStorageDirectory:${dir}');
    }
    else {
      dir = (await getTemporaryDirectory()).path;
      print('TemporaryDirectory:${dir}');
    }
    String filePath = '$dir/${urlParts.last}/$name';
    File file = File(filePath);
    if (await file.exists()) return file.path;
    return null;
  }

  Future<String> downloadHomework({String url, String name,
                                   void Function(int, int) onReceiveProgress}) async {
    api.token = await token;
    return await api.downloadHomework(url: url, filename: name,
                                      onReceiveProgress: onReceiveProgress);
  }

  Future<void> cacheClear() async {
    await _cache.clearAll();
  }

  Future<void> cacheClearUpcoming() async {
    await _cache.deleteByPrimaryKey('/student/lessons/upcoming');
  }

  Future<void> cacheClearPast() async {
    await _cache.deleteByPrimaryKey('/student/lessons/past');
  }
}
