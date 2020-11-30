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

class Student {
  final String name;
  final String email;
  final DateTime nextLesson;
  final int lessonsOwed;
  final int lessonsPresent;
  final DateTime nextInvoice;

  // @todo - Teachers?

  Student(this.name, this.email, this.nextLesson, this.lessonsOwed,
      this.lessonsPresent, this.nextInvoice);

  Student.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        nextLesson = DateTime.parse(json['nextLesson']),
        lessonsOwed = json['lessonsOwed'],
        lessonsPresent = json['lessonsPresent'],
        nextInvoice = DateTime.parse(json['nextInvoice']);

  Map<String, dynamic> toJson() =>
      <String, dynamic> {
        'name': name,
        'email': email,
        'nextLesson': nextLesson?.toIso8601String(),
        'lessonsOwed': lessonsOwed,
        'lessonsPresent': lessonsPresent,
        'nextInvoice': nextInvoice?.toIso8601String()
      };
}
