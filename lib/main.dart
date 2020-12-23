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

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:musicscool/generated/l10n.dart';
import 'package:musicscool/pages/root_page.dart';
import 'package:musicscool/services/api.dart';
import 'package:musicscool/services/api_service.dart';
import 'package:musicscool/theme.dart';
import 'package:musicscool/strings.dart' show appName;

void main() {
  runApp(MusicScoolApp(ApiService()));
}

class MusicScoolApp extends StatelessWidget {
  final Api api;
  MusicScoolApp(this.api);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: theme(),
      home: RootPage(api),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}
