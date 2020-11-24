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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_musicscool_app/pages/login_page.dart';
import 'package:my_musicscool_app/pages/home_page.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Widget _waitingPage() {
    return Scaffold(
        body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      setState(() {
        _isLoggedIn = prefs.containsKey('token') && prefs.getString('token').isNotEmpty;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _waitingPage();
    if (true) { //_isLoggedIn) {
      return HomePage();
    }
    else {
      return LoginPage();
    }
  }
}

