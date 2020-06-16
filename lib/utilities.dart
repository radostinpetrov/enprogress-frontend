import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Utilities {
  static MethodChannel platform = const MethodChannel('flutter/enprogress');

  static Future<String> getFCMTokenByID(int userID) async {
    Uri uri = Uri.parse(
        "https://enprogressbackend.herokuapp.com/users/" + userID.toString());
    Client client = Client();
    Response response = await client.get(uri);
    return json.decode(response.body)[0]['fcm_token'];
  }

  static Future<bool> sendFcmMessage(String title, String message,
      String recipientToken, String payload) async {
    try {
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization":
            "key=AAAAtChCW9c:APA91bFB8Il2OZLpctWxp3GGPdEGmu5J3P29KREf-wSW0hfxNIB5Z8xEBfoqzVI5Sj-nsPNdM3Omg2mCJRxnAiAAUZvC2kihg-lizb2rRF-FAYO9gfmsBFzdyF_Uizf5wUYo9pZgjPso",
      };
      var request = {
        'notification': {'title': title, 'body': message},
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'type': 'COMMENT',
          'payload': payload,
        },
        'priority': 'high',
        'to': recipientToken,
      };

      var client = new Client();
      await client.post(url, headers: header, body: json.encode(request));
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }
}
