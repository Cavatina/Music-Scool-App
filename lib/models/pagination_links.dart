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

part 'pagination_links.g.dart';

@JsonSerializable()
class PaginationLinks {
  final String first;
  final String last;
  final String prev;
  final String next;

  PaginationLinks(this.first, this.last, this.prev, this.next);
  factory PaginationLinks.fromJson(Map<String, dynamic> json) => _$PaginationLinksFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationLinksToJson(this);
}
