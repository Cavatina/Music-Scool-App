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

import 'package:json_annotation/json_annotation.dart';
import 'lesson.dart';
import 'pagination_links.dart';
import 'pagination_meta.dart';

part 'lesson_response.g.dart';

@JsonSerializable()
class LessonResponse {
  final List<Lesson> data;
  final PaginationMeta meta;
  final PaginationLinks links;

  LessonResponse(this.data, this.meta, this.links);
  factory LessonResponse.fromJson(Map<String, dynamic> json) => _$LessonResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LessonResponseToJson(this);
}
