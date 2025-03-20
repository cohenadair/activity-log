import 'dart:io';

class IoWrapper {
  Future<List<InternetAddress>> lookup(String host) async {
    try {
      return await InternetAddress.lookup(host);
    } catch (_) {
      return Future.value([]);
    }
  }

  bool get isAndroid => Platform.isAndroid;

  bool get isIOS => Platform.isIOS;
}
