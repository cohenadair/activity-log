import 'dart:io';

class IoWrapper {
  Future<bool> isConnected() async {
    try {
      // A quick DNS lookup will tell us if there's a current internet
      // connection. InternetAddress.lookup throws an exception if internet is
      // off, such as when in Airplane Mode.
      return (await InternetAddress.lookup("example.com")).isNotEmpty;
    } on Exception catch (ex, _) {
      return false;
    }
  }

  bool get isAndroid => Platform.isAndroid;

  bool get isIOS => Platform.isIOS;
}
