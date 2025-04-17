import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HttpWrapper {
  static var _instance = HttpWrapper._();

  static HttpWrapper get get => _instance;

  @visibleForTesting
  static void set(HttpWrapper manager) => _instance = manager;

  @visibleForTesting
  static void suicide() => _instance = HttpWrapper._();

  HttpWrapper._();

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return http.post(url, headers: headers, body: body, encoding: encoding);
  }
}
