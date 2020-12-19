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
import 'package:musicscool/services/api.dart';
import 'package:musicscool/viewmodels/auth.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';
import 'home_page.dart';

class RootPage extends StatefulWidget {
  final Api api;
  final AuthModel auth;

  RootPage(this.api) : auth = AuthModel(api);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {

  Widget _waitingPage() {
    return Scaffold(
        body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  void initState() {
    initializeDateFormatting().then((obj){});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthModel>.value(value: widget.auth)
        ],
        child: choosePage(context)
    );
  }

  Widget choosePage(BuildContext context) {
    return Consumer<AuthModel>(builder: (context, model, child) {
      if (model?.isLoading == true) return _waitingPage();
      if (model.isLoggedIn) {
        return HomePage();
      }
      else {
        return LoginPage();
      }
    });
  }
}
