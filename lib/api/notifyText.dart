import 'dart:convert';

import 'package:http/http.dart' as http;

class NotifyTextRequest {
  static Future<void> send(String id, String msg) async {
    print("$id, $msg");
    http.post(
        Uri.parse("http://${DotEnv().get("BACKEND_ADDRESS")}/notify/text"),
        body: jsonEncode({"telegramId": id, "body": msg}),
        headers: {"Content-Type": "application/json"});
  }
}
