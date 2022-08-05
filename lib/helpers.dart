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
import 'package:musicscool/generated/l10n.dart';

void showUnexpectedError(BuildContext context)
{
  WidgetsBinding.instance?.addPostFrameCallback((_) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).unexpectedErrorMessage),
//      duration: Duration(seconds: 5)
    )));
}

Widget waiting() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget> [
      CircularProgressIndicator()
    ]
  );
}

Widget waitingSmall() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget> [
      SizedBox(width:24.0, height:24.0, child: CircularProgressIndicator())
    ]
  );
}

bool isNullOrEmpty(Object? o) => o == null || o == '';
