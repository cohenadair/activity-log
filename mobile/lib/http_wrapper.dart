import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpWrapper {
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return http.post(url, headers: headers, body: body, encoding: encoding);
  }
}
