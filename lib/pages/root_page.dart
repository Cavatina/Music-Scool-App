/* Music'scool App - Copyright (C) 2020  Music'scool DK

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

import 'package:intl/date_symbol_data_local.dart';  //for date locale
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:musicscool/pages/login_page.dart';
import 'package:musicscool/pages/home_page.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _isLoading = true;
//  bool _isLoggedIn = true;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Widget _waitingPage() {
    return Scaffold(
        body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      initializeDateFormatting().then((_) {
        setState(() {
//        _isLoggedIn = prefs.containsKey('token') && prefs.getString('token').isNotEmpty;
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _waitingPage();
    //   if (_isLoggedIn) {
      return HomePage();
//    }
    // else {
    //   return LoginPage();
    // }
  }
}

