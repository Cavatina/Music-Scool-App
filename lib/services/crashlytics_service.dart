import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void recordApiError(DioError error) {
  final response = error.response;
  final request = error.requestOptions;
  final crashlytics = FirebaseCrashlytics.instance;

  unawaited(crashlytics.setCustomKey('api_path', request.path));
  unawaited(crashlytics.setCustomKey('api_method', request.method));
  if (response?.statusCode != null) {
    unawaited(crashlytics.setCustomKey('api_status', response!.statusCode!));
  }

  unawaited(crashlytics.recordError(
    error,
    error.stackTrace,
    reason: 'API ${request.method} ${request.path}',
    fatal: false,
    information: [
      'type: ${error.type}',
      if (response?.data != null) 'response: ${_sanitizeForLogging(response!.data)}',
    ],
  ));
}

void recordParseError(
  Object error,
  StackTrace stack, {
  required String context,
  dynamic data,
}) {
  final crashlytics = FirebaseCrashlytics.instance;
  unawaited(crashlytics.setCustomKey('parse_context', context));
  unawaited(crashlytics.recordError(
    error,
    stack,
    reason: 'JSON parse error: $context',
    fatal: false,
    information: [
      if (data != null) 'data: ${_sanitizeForLogging(data)}',
    ],
  ));
}

T parseApiJson<T>(String context, dynamic data, T Function() parse) {
  try {
    return parse();
  } catch (error, stack) {
    recordParseError(error, stack, context: context, data: data);
    rethrow;
  }
}

String _sanitizeForLogging(Object data) {
  final text = data.toString();
  if (text.length <= 500) {
    return text;
  }
  return '${text.substring(0, 500)}...';
}
