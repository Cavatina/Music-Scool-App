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

part 'homework.g.dart';

@JsonSerializable()
class Homework {
  final String message;
  final String fileName;
  final String fileUrl;
  final String linkUrl;

  Homework(this.message, this.fileName, this.fileUrl, this.linkUrl);
  factory Homework.fromJson(Map<String, dynamic> json) => _$HomeworkFromJson(json);

  Map<String, dynamic> toJson() => _$HomeworkToJson(this);
}
