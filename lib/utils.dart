import 'dart:convert';

import 'package:EnProgress/page_widgets/WorkModeRequest.dart';
import 'package:EnProgress/top_level/Globals.dart';
import 'package:EnProgress/user/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class Utils {
  static MethodChannel platform = const MethodChannel('flutter/enprogress');
  static final Client client = Client();
  static BuildContext context;
  static User user;
  static int _notificationID = 0;

  static int getNotificationID() {
    return _notificationID++;
  }

  static Future<String> getUsername(int userID) async {
    Uri uri = Uri.parse(Globals.serverIP + "users/" + userID.toString());
    Response response = await client.get(uri);
    Map<String, dynamic> data = json.decode(response.body)[0];
    return data['name'];
  }

  static Future<String> getFCMTokenByID(int userID) async {
    print("Getting fcm for id: " + userID.toString());
    Uri uri = Uri.parse(
        Globals.serverIP + "users/" + userID.toString());
    Response response = await client.get(uri);
    String fcmToken;

    print("the response is: " + response.body);
    fcmToken = json.decode(response.body)[0]['fcm_token'];

    return fcmToken;
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
      print('Message shoudda been title: ' + title + " body: " + message);
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

  static Future<int> postWorkModeRequest(WorkModeRequest workModeRequest) async {
    Uri uri =
    Uri.parse("https://enprogressbackend.herokuapp.com/workmoderequests");
    Map<String, String> headers = {"Content-type": "application/json"};
    Map<String, dynamic> body = {
      'fk_sender_id': workModeRequest.fk_sender_id,
      'fk_recipient_id': workModeRequest.fk_recipient_id,
      'start_time': workModeRequest.start_time,
      'duration': workModeRequest.duration
    };
    Response response = await client.post(uri,
        headers: headers, body: json.encode(body, toEncodable: Utils.myEncode));
//    print(response.body);
//    print(json.decode(response.body)['id']);
    return json.decode(response.body)['id'];
  }

  static Future<bool> sendWorkModeRequest(String senderUsername, WorkModeRequest workModeRequest) async {
    // Get friend's FCM token
    String recipientToken = await Utils.getFCMTokenByID(workModeRequest.fk_recipient_id);

    // Post workmoderequest
    int requestID = await postWorkModeRequest(workModeRequest);

    // Send FCM message to recipient
    return await Utils.sendFcmMessage(
        senderUsername + ' would like to work with you',
        'From ' +
            (workModeRequest.start_time.hour + 1).toString() +
            ':' +
            workModeRequest.start_time.minute.toString().padLeft(2, '0') +
            ' for ' +
            workModeRequest.duration.toString() +
            ' minutes.',
        recipientToken, 'WorkModeRequest:' + requestID.toString());
  }


//  static void updateFCMToken(int userID) async {
//    // Update user fcm_token
//    String FCMToken = await _firebaseMessaging.getToken();
//    Map<String, String> headers = {"Content-type": "application/json"};
//    Map<String, dynamic> body = {'fcm_token': FCMToken};
//    Uri uri = Uri.parse(
//        "https://enprogressbackend.herokuapp.com/users/" + userID.toString());
//    Response response =
//        await client.patch(uri, headers: headers, body: jsonEncode(body));
//  }

}
