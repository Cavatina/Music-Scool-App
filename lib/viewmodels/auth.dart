import 'package:flutter/foundation.dart';
import 'package:musicscool/services/api.dart';

class AuthModel extends ChangeNotifier
{
  final Api api;
  bool isLoading = false;
  bool isLoggedIn = false;
  String token;

  AuthModel(this.api);

  Future<void> login({
    @required String username,
    @required String password}) async {

    isLoading = true;
    await api.login(username: username, password: password);
    isLoggedIn = true;
    isLoading = false;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }
}