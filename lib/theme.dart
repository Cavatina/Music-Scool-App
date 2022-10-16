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
import 'package:google_fonts/google_fonts.dart';

final Map<int, Color> mmColors = {
  50: Color.fromRGBO(255, 186, 0, .1),
  100: Color.fromRGBO(255, 186, 0, .2),
  200: Color.fromRGBO(255, 186, 0, .3),
  300: Color.fromRGBO(255, 186, 0, .4),
  400: Color.fromRGBO(255, 186, 0, .5),
  500: Color.fromRGBO(255, 186, 0, .6),
  600: Color.fromRGBO(255, 186, 0, .7),
  700: Color.fromRGBO(255, 186, 0, .8),
  800: Color.fromRGBO(255, 186, 0, .9),
  900: Color.fromRGBO(255, 186, 0, 1),
};

final ColorScheme colorScheme = ColorScheme(
  primary: Colors.white,
  primaryContainer: Colors.white60,
  secondary: mmColors[900]!,
  secondaryContainer: mmColors[700]!,
  background: Colors.black,
  surface: Color.fromRGBO(21, 21, 21, 0.3),
  onBackground: Colors.white,
  error: Colors.redAccent,
  onError: Colors.white,
  onPrimary: Colors.black,
  onSecondary: Colors.black,
  onSurface: Colors.white,
  brightness: Brightness.dark,
);
ThemeData theme()
{
  //MaterialColor mmYellow = MaterialColor(mmColors[900].value, mmColors);
  ThemeData theme = ThemeData(
    colorScheme: colorScheme,
    brightness: Brightness.dark,
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: mmColors[400],
      selectionHandleColor: mmColors[900],
    ),
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.white,
    appBarTheme: AppBarTheme(
      foregroundColor: colorScheme.onSecondary,
      backgroundColor: colorScheme.secondary,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    cardTheme: CardTheme(color: Color.fromRGBO(21, 21, 21, 0.3))
  );
  return theme.copyWith(
      textTheme: GoogleFonts.robotoTextTheme(theme.textTheme),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.secondary, // Colors.white,
        //backgroundColor: Colors.white24,
        backgroundColor: Colors.black
      )
    )
  );
}
