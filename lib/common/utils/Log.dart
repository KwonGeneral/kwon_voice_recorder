

// ignore_for_file: unused_field, constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class Log {
  static const String _MY_LOG_TAG = "KWON_LOG";
  static const String _LOG_TAG = _MY_LOG_TAG;

  static Logger logger = Logger(
    filter: null,
    printer: PrettyPrinter(),
    output: null,
  );


  // MARK: - 기본 로그
  static void d(String message, {String tag = _LOG_TAG}) {
    if (kDebugMode) {
      logger.d("[$tag] $message", stackTrace: StackTrace.fromString(""), error: null);
    }
  }

  // MARK: - 에러 로그
  static void e(Object message, StackTrace stackTrace, {String tag = _LOG_TAG}) {
    if (kDebugMode) {
      logger.e("[$tag] $message", stackTrace: StackTrace.fromString(""), error: null);
      String trace = "";
      stackTrace.toString().split("\n").forEach((element) {
        trace += "$element\n";
      });
      logger.t("[$tag] $trace", stackTrace: StackTrace.fromString(""), error: null);
    }
  }

  // MARK: - 정보 로그
  static void i(String message, {String tag = _LOG_TAG}) {
    if (kDebugMode) {
      logger.i("[$tag] $message", stackTrace: StackTrace.fromString(""), error: null);
    }
  }

  // MARK: - 경고 로그
  static void w(String message, {String tag = _LOG_TAG}) {
    if (kDebugMode) {
      logger.w("[$tag] $message", stackTrace: StackTrace.fromString(""), error: null);
    }
  }
}