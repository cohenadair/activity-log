import '../io_wrapper.dart';

Future<bool> isConnected(IoWrapper io) async {
  // A quick DNS lookup will tell us if there's a current internet
  // connection.
  return (await io.lookup("example.com")).isNotEmpty ||
      (await io.lookup("google.com")).isNotEmpty;
}
