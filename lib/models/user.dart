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

import 'package:json_annotation/json_annotation.dart';
import 'package:musicscool/models/student.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String name;
  final String email;
  final Student student;

  User(this.name, this.email, this.student);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
