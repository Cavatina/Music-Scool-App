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

import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:musicscool/models/lesson_cancel_info.dart';
import 'package:musicscool/models/lesson_response.dart';
import 'package:musicscool/services/api.dart';
import 'package:musicscool/models/user.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:path_provider/path_provider.dart';


class ApiService implements Api {
  static const String baseUrl = 'https://testscool.cavatina.no/api/v1';
  final http.BaseClient client = http.Client();
  String _token;

  @override
  Future<String> login({String username, String password}) async {
    print('${baseUrl}/login');
    String body = json.encode(
        <String, dynamic> {
          'email': username,
          'password': password,
          'deviceName': 'test123'
    });
    http.Response response = await client.post('${baseUrl}/login',
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: body
    ).timeout(Duration(seconds: 20));
    if (response.statusCode != 200) {

    }
    Map<String, dynamic> js = json.decode(response.body);
    if (js.containsKey('data') && js['data'].containsKey('token')) {
      _token = js['data']['token'];
      return _token;
    }
    else if (js.containsKey('message')) {
      print(body);
      print(response.body);
      throw Exception(js['message']);
    }
    throw Exception('Illegal login');
  }

  @override
  Future<void> resetPassword({String username}) async {
    String body = json.encode(
        <String, dynamic> {
          'email': username,
        });
    http.Response response = await client.post('${baseUrl}/requestPasswordReset',
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: body
    ).timeout(Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw ApiError('Failed');
    }
    return;
  }

  @override
  set token (String token) {
    _token = token;
  }

  @override
  Future<User> get user async {
    print(baseUrl);
    http.Response response = await client.get('${baseUrl}/profile',
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer ${_token}'
        }).timeout(Duration(seconds: 20));
    Map<String, dynamic> js = json.decode(response.body);
    print(js.toString());
    if (js == null || !js.containsKey('data')) {
      print('AuthenticationFailed!');
      throw AuthenticationFailed();
    }
    return User.fromJson(js['data']);
  }

  Future<Map<String, dynamic>> jsonGet(String path, {int page, int perPage, bool withHomework}) async {
    print(path);
    Map<String, String> params = <String, String>{};
    if (page != null && page != 0) params['page'] = page.toString();
    if (perPage != null && perPage != 0) params['per_page'] = perPage.toString();
    if (withHomework == true) params['with_homework'] = 'true';
    Uri url = Uri.parse(baseUrl + path).replace(queryParameters: params);
    print(url);
    http.Response response = await client.get(url,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer ${_token}'
        }).timeout(Duration(seconds: 30));
    print(response.body);
    print(response.statusCode);
    return json.decode(response.body);
  }

  @override
  Future<List<Lesson>> getUpcomingLessons({page = 0, perPage = 20}) async {
    LessonResponse response = LessonResponse.fromJson(await jsonGet('/student/lessons/upcoming',
        page: page, perPage: perPage));
    return response.data;
  }

  @override
  Future<List<Lesson>> getHomeworkLessons({page = 0, perPage = 20}) async {
    LessonResponse response = LessonResponse.fromJson(await jsonGet('/student/lessons/past',
        page: page, perPage: perPage, withHomework: true));
    return response.data;
  }

  @override
  Future<LessonCancelInfo> cancelLessonInfo({int id}) async {
    return LessonCancelInfo.fromJson((await jsonGet('/student/lessons/${id}/cancel'))['data']);
  }

  @override
  Future<Lesson> cancelLesson({int id}) async {
    http.Response response = await client.post('${baseUrl}/student/lessons/${id}/cancel',
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer ${_token}'
        }).timeout(Duration(seconds: 20));
    if (response.statusCode != 200) {
      print(response.statusCode);
      // @todo Error handling!!
      throw ApiError(response.body);
    }

    return Lesson.fromJson(json.decode(response.body)['data']);
  }

  @override
  Future<String> downloadHomework({String url, String filename}) async {
    String dir = (await getTemporaryDirectory()).path;
    File file = File('$dir/$filename');
    if (await file.exists()) return file.path;
    await file.create(recursive: true);
    print('Downloading:${filename} from ${url}');
    var response = await client.get(url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${_token}'
      }).timeout(Duration(seconds: 60));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    }
    print(response.statusCode);
    print(response.body);
    throw ApiError('Download ${filename} failed!');
  }

  static const pageSize = 25;
}