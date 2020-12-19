import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:musicscool/models/user.dart';
import 'package:musicscool/services/api.dart';

class AuthModel extends ChangeNotifier
{
  final Api api;
  final storage = FlutterSecureStorage();

  bool isLoading = false;
  bool isLoggedIn = false;
  String token;

  AuthModel(this.api) {
    isLoading = true;
    storage.read(key: 'token').then((value) {
      if (value?.isNotEmpty == true) {
        print('reading token from storage:${value}');
        isLoggedIn = true;
        token = value;
      }
      else {
        print('token empty!');
      }
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> login({
    @required String username,
    @required String password}) async {

    isLoading = true;
    token = await api.login(username: username, password: password);
    if (token?.isNotEmpty == true) {
      await storage.write(key: 'token', value: token);
      await storage.write(key: 'lastUsername', value: username);
    }
    isLoggedIn = true;
    isLoading = false;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    storage.write(key: 'token', value: '').then((value){});
    notifyListeners();
  }

  Future<User> get user async {
    return api.user;
  }

  Future<String> get lastUsername async {
    return await storage.read(key: 'lastUsername');
  }
}