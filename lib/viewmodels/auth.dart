import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:musicscool/models/available_dates.dart';
import 'package:musicscool/models/instrument.dart';
import 'package:musicscool/models/lesson_cancel_info.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:musicscool/models/time_slot.dart';
import 'package:musicscool/models/user.dart';
import 'package:musicscool/models/voucher.dart';
import 'package:musicscool/services/api.dart';
import 'package:musicscool/service_locator.dart';
import 'package:musicscool/services/local_notifications.dart';
import 'package:musicscool/services/remote_notifications.dart';
import 'package:musicscool/strings.dart' show apiUrl;
import 'package:musicscool/widgets/duration_select.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:permission_handler/permission_handler.dart';

class AuthModel extends ChangeNotifier {
  final Api api;
  final storage = FlutterSecureStorage();

  bool isLoggedIn = false;
  String _token = '';
  bool _notificationsEnabled = true;
  DateTime? _nextLesson;
  final DioCacheManager _cache = DioCacheManager(CacheConfig(
    baseUrl: apiUrl,
    defaultRequestMethod: 'GET'));

  AuthModel(this.api);

  Future<AuthModel> init() async {
    String? value = await token;
    if (value.isNotEmpty == true) {
      print('reading token from storage:${value}');
      isLoggedIn = true;
    } else {
      print('token empty!');
    }
    value = await readStorage('notificationsEnabled');
    if (value != null && value == 'false') _notificationsEnabled = false;
    value = await readStorage('nextLesson');
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
        if (e.requestOptions.method == 'GET' && <int>[401, 403].contains(e.response?.statusCode)) {
          print('status:${e.response!.statusCode}: logout!');
          clearLoginToken();
        }
        return handler.next(e);
      }
    ));
    api.dio.interceptors.add(_cache.interceptor);

    // Temporary, cancel any local notifications scheduled by previous versions.
    await cancelNotifications();
    notifyListeners();
    return this;
  }

  Future<String?> readStorage(String key) async {
    try {
      return await storage.read(key: key);
    }
    catch(e) {
      await storage.deleteAll();
      return null;
    }
  }

  Future<String> get token async {
    if (_token == '') {
      _token = (await readStorage('token')) ?? '';
    }
    return _token;
  }

  bool get notificationsEnabled {
    return _notificationsEnabled;
  }

  Future<void> enableNotifications() async {
    _notificationsEnabled = true;
    print('Notifications enabled');
    var deviceToken = locator<RemoteNotifications>().token;
    if (deviceToken != null) {
      await api.registerDevice(deviceToken: deviceToken, locale: Platform.localeName);
      print('registerDevice:${deviceToken}, locale:${Platform.localeName}');
    }
    await storage.write(key: 'notificationsEnabled', value: 'true');
  }
  Future<void> disableNotifications() async {
    _notificationsEnabled = false;
    print('Notifications disabled');
    var deviceToken = locator<RemoteNotifications>().token;
    if (deviceToken != null) {
      await api.removeDevice(deviceToken: deviceToken);
    }
    await storage.write(key: 'notificationsEnabled', value: 'false');
  }

  Future<void> cancelNotifications() async {
    await locator<LocalNotifications>().cancelNotifications();
  }

  Future<void> login(
      {required String username, required String password}) async {
    _token = await api.login(username: username, password: password);
    if (_token.isNotEmpty == true) {
      api.token = _token;
      await storage.write(key: 'token', value: _token);
      await storage.write(key: 'lastUsername', value: username);
    }
    var deviceToken = locator<RemoteNotifications>().token;
    print('deviceToken:${deviceToken}');
    if (deviceToken != null) {
      await api.registerDevice(deviceToken: deviceToken, locale: Platform.localeName);
      print('registerDevice:${deviceToken}, locale:${Platform.localeName}');
    }
    locator<RemoteNotifications>().tokenStream.listen((String token) {
      if (isLoggedIn && notificationsEnabled) {
        api.registerDevice(deviceToken: token, locale: Platform.localeName).then((_) {});
      }
    });

    isLoggedIn = true;
    notifyListeners();
  }

  Future<String> resetPassword({required String username}) async {
    await api.resetPassword(username: username);
    return username;
  }

  void logout() {
    var deviceToken = locator<RemoteNotifications>().token;
    if (deviceToken != null) {
      api.removeDevice(deviceToken: deviceToken).then((_) {});
    }
    clearLoginToken();
  }

  void clearLoginToken() {
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
    DateTime? newNextLesson = user.student?.nextLesson?.from;
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
    _nextLesson = newNextLesson;
    return user;
  }

  Future<String> get lastUsername async {
    return await readStorage('lastUsername') ?? '';
  }

  Future<List<Lesson>> getUpcomingLessons({required int page, required int perPage}) async {
    api.token = await token;
    return await api.getUpcomingLessons(page: page, perPage: perPage);
  }

  Future<List<Lesson>> getHomeworkLessons({required int page, required int perPage}) async {
    api.token = await token;
    return await api.getHomeworkLessons(page: page, perPage: perPage);
  }

  Future<List<Voucher>> getVouchers() async {
    return await api.getVouchers();
  }

  Future<LessonCancelInfo> cancelLessonInfo({required int id}) async {
    api.token = await token;
    return await api.cancelLessonInfo(id: id);
  }

  Future<Lesson?> cancelLesson({required int id}) async {
    api.token = await token;
    Lesson? lesson = await api.cancelLesson(id: id);
    await cacheClearUpcoming();
    return lesson;
  }

  Future<void> createLessonRequest({
    required Voucher voucher,
    required AvailableDates date,
    required Instrument instrument,
    required TimeSlot time,
    required LessonDuration duration}) async
  {
    api.token = await token;
    await api.createLessonRequest(
      voucher: voucher, date: date, instrument: instrument, time: time, duration: duration);
    return cacheClearUpcoming();
  }

  Future<String> homeworkPath({required String url, required String name}) async {
    List<String> urlParts = url.split('/');
    String dir;
    if (Platform.isAndroid && await Permission.storage.status.isGranted) {
      dir = (await getExternalStorageDirectories(type: StorageDirectory.documents))![0].path;
      print('ExternalStorageDirectory:${dir}');
    }
    else {
      dir = (await getTemporaryDirectory()).path;
      print('TemporaryDirectory:${dir}');
    }
    String filePath = '$dir/${urlParts.last}/$name';
    File file = File(filePath);
    if (await file.exists()) return file.path;
    return '';
  }

  Future<String> downloadHomework({required String url, required String name,
                                   required void Function(int, int) onReceiveProgress}) async {
    api.token = await token;
    return await api.downloadHomework(url: url, filename: name,
                                      onReceiveProgress: onReceiveProgress);
  }

  Future<List<Instrument>> getInstruments() async {
    return await api.getInstruments();
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
