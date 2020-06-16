import 'dart:convert';

import 'package:EnProgress/page_widgets/WorkModePage.dart';
import 'package:EnProgress/page_widgets/WorkModeRequest.dart';
import 'package:EnProgress/user/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Utilities {
  static MethodChannel platform = const MethodChannel('flutter/enprogress');
  static final Client client = Client();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static BuildContext context;
  static User user;


  static Future<String> getFCMTokenByID(int userID) async {
    print("Getting fcm for id: " + userID.toString());
    Uri uri = Uri.parse(
        "https://enprogressbackend.herokuapp.com/users/" + userID.toString());
    Client client = Client();
    Response response = await client.get(uri);
    String fcmToken;

    fcmToken = json.decode(response.body)[0]['fcm_token'];
    print("the response is: " + response.body);

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
        headers: headers, body: json.encode(body, toEncodable: Utilities.myEncode));
//    print(response.body);
//    print(json.decode(response.body)['id']);
    return json.decode(response.body)['id'];
  }

  static Future<bool> sendWorkModeRequest(String senderUsername, WorkModeRequest workModeRequest) async {
    // Get friend's FCM token
    String recipientToken = await Utilities.getFCMTokenByID(workModeRequest.fk_recipient_id);

    // Post workmoderequest
    int requestID = await postWorkModeRequest(workModeRequest);

    // Send FCM message to recipient
    return await Utilities.sendFcmMessage(
        senderUsername + ' would like to work with you',
        'From ' +
            workModeRequest.start_time.hour.toString() +
            ':' +
            workModeRequest.start_time.minute.toString() +
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
