import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:musicscool/models/user.dart';
import 'package:musicscool/services/api.dart';
import 'dart:async';

class AuthModel extends ChangeNotifier
{
  final Api api;
  final storage = FlutterSecureStorage();

  bool isLoading = false;
  bool isLoggedIn = false;
  String _token;

  AuthModel(this.api) {
    isLoading = true;
    token.then((value) {
      if (value?.isNotEmpty == true) {
        print('reading token from storage:${value}');
        isLoggedIn = true;
      }
      else {
        print('token empty!');
      }
      isLoading = false;
      notifyListeners();
    });
  }

  Future<String> get token async {
    _token ??= await storage.read(key: 'token');
    return _token;
  }

  Future<void> login({
    @required String username,
    @required String password}) async {

    isLoading = true;
    _token = await api.login(username: username, password: password);
    if (_token?.isNotEmpty == true) {
      api.token = _token;
      await storage.write(key: 'token', value: _token);
      await storage.write(key: 'lastUsername', value: username);
    }
    isLoggedIn = true;
    isLoading = false;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    _token = '';
    storage.write(key: 'token', value: '').then((value){});
    notifyListeners();
  }

  Future<User> get user async {
    try {
      api.token = await token;
      return await api.user;
    }
    on AuthenticationFailed catch (_) {
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
}