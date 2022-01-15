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
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:musicscool/models/lesson_cancel_info.dart';
import 'package:musicscool/models/lesson_response.dart';
import 'package:musicscool/services/api.dart';
import 'package:musicscool/models/user.dart';
import 'package:musicscool/models/lesson.dart';
import 'package:path_provider/path_provider.dart';
import 'package:musicscool/strings.dart' show apiUrl;
import 'package:permission_handler/permission_handler.dart';


ApiError httpStatusError(int statusCode) {
  if (<int>[401, 403, 422].contains(statusCode)) {
    return AuthenticationFailed();
  }
  else {
    return ServerError();
  }
}

class ApiService implements Api {
  final Dio _dio = Dio();
  String _token;

  ApiService() {
    _dio.options.baseUrl = apiUrl;
    _dio.options.connectTimeout = 5000;
    _dio.options.receiveTimeout = 10000;
    _dio.options.headers[HttpHeaders.acceptHeader] = 'application/json';
  }

  @override
  Dio get dio {
    return _dio;
  }

  @override
  Future<String> login({String username, String password}) async {
    try {
      Response response = await _dio.post(
        '/login',
        data: <String, String> {
          'email': username,
          'password': password,
          'deviceName': 'test123',
        }
      );
      if (response.data.containsKey('data') && response.data['data'].containsKey('token')) {
        _token = response.data['data']['token'];
        return _token;
      }
      else if (response.data.containsKey('message')) {
        print(response.data);
      }
      throw httpStatusError(response.statusCode);
    }
    catch (e) {
      if (e is DioError) {
        print(e.requestOptions);
        print(e.message);
        if (e.response != null) {
          print(e.response.data);
          throw httpStatusError(e.response.statusCode);
        }
      }
      else {
        print('login error:${e}');
      }
      throw ServerError();
    }
  }

  @override
  Future<void> resetPassword({String username}) async {
    try {
      await _dio.post(
        '/requestPasswordReset',
        data: <String, String> {
          'email': username,
        }
      );
    }
    catch (_) {
      throw ServerError();
    }
    return;
  }

  @override
  set token (String token) {
    _token = token;
  }

  @override
  Future<User> get user async {
    try {
      Response response = await _dio.get(
        '/profile',
        options: buildCacheOptions(Duration(seconds: 30),
          maxStale: Duration(days:30),
          options: Options(
            headers: <String, String> {
              HttpHeaders.authorizationHeader: 'Bearer ${_token}'
            }
          ),
        )
      );
      if (null != response.headers.value(DIO_CACHE_HEADER_KEY_DATA_SOURCE)) {
        print('/profile: Using cache');
      }
      else {
        print('/profile: Loaded fresh.');
      }
      if (!response.data.containsKey('data')) {
        print(response.data);
        throw httpStatusError(response.statusCode);
      }
      return User.fromJson(response.data['data']);
    }
    catch (_) {
      throw ServerError();
    }
  }

  Future<Map<String, dynamic>> jsonGet(
    String path, {
      int page,
      int perPage,
      bool withHomework,
      bool withCancelled = true,
      bool useCache = false,
      }) async {
    Map<String, String> params = <String, String>{};
    if (page != null && page != 0) params['page'] = page.toString();
    if (perPage != null && perPage != 0) params['per_page'] = perPage.toString();
    if (withHomework == true) params['with_homework'] = 'true';
    if (withCancelled == false) params['with_cancelled'] = 'false';

    Options options = Options(
      headers: <String, String> {
        HttpHeaders.authorizationHeader: 'Bearer ${_token}'
      }
    );
    if (useCache == true) {
      options = buildCacheOptions(Duration(hours:8),
          maxStale: Duration(days:30),
          options: options
      );
    }
    try {
      Response response = await _dio.get(
        path,
        options: options,
        queryParameters: params,
      );
      if (null != response.headers.value(DIO_CACHE_HEADER_KEY_DATA_SOURCE)) {
        print('${path}: Using cache');
      }
      else {
        print('${path}: Loaded fresh.');
      }
      return response.data;
    }
    catch (e) {
      if (e is DioError) {
        if (e.response != null) {
          print(e.response.data);
          throw httpStatusError(e.response.statusCode);
        }
        else {
          print(e.message);
        }
      }
      throw ServerError();
    }
  }

  @override
  Future<List<Lesson>> getUpcomingLessons({int page = 0, int perPage = 20, bool withCancelled = true}) async {
    LessonResponse response = LessonResponse.fromJson(await jsonGet('/student/lessons/upcoming',
        page: page, perPage: perPage, withCancelled: withCancelled, useCache: true));
    return response.data;
  }

  @override
  Future<List<Lesson>> getHomeworkLessons({int page = 0, int perPage = 20}) async {
    LessonResponse response = LessonResponse.fromJson(await jsonGet('/student/lessons/past',
        page: page, perPage: perPage, withHomework: true, useCache: true));
    return response.data;
  }

  @override
  Future<LessonCancelInfo> cancelLessonInfo({int id}) async {
    return LessonCancelInfo.fromJson((await jsonGet('/student/lessons/${id}/cancel'))['data']);
  }

  @override
  Future<Lesson> cancelLesson({int id}) async {
    try {
      Response response = await _dio.post(
        '/student/lessons/${id}/cancel',
        options: Options(
          headers: <String, String> {
            HttpHeaders.authorizationHeader: 'Bearer ${_token}'
          }
        )
      );
      return Lesson.fromJson(response.data['data']);
    }
    catch (e) {
      if (e is DioError) {
        if (e.response != null) {
          print(e.response.data);
          throw httpStatusError(e.response.statusCode);
        }
        else {
          print(e.message);
        }
      }
      else {
        print(e);
      }
      throw ServerError();
    }
  }

  @override
  Future<String> downloadHomework({String url, String filename,
                                   void Function(int, int) onReceiveProgress}) async {
    List<String> urlParts = url.split('/');
    String dir;
    if (Platform.isAndroid && await Permission.storage.request().isGranted) {
      dir = (await getExternalStorageDirectories(type: StorageDirectory.documents))[0].path;
    }
    else {
      dir = (await getTemporaryDirectory()).path;
    }
    print('ExternalStorageDirectory:${dir}');
    String filePath = '$dir/${urlParts.last}/$filename';
    File file = File(filePath);
    if (await file.exists()) return file.path;
    try {
      await _dio.download(url, filePath,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          receiveTimeout: 3*60000,
          headers: <String, String> {
            HttpHeaders.authorizationHeader: 'Bearer ${_token}'
          }
        )
      );
      print('Downloaded homework from ${url} into ${filePath}');
      return filePath;
    }
    catch (e) {
      print(e);
      if (e is DioError) {
        if (e.requestOptions != null) {
          print (e.requestOptions.responseType);
        }
        if (e.response != null) {
          print (e.response.statusCode);
        }
        print (e.message);
      }
      throw ServerError();
    }
  }

  static const pageSize = 25;
}
