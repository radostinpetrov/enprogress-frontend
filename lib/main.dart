import 'package:EnProgress/push_notifications.dart';
import 'package:flutter/material.dart';
import 'top_level/MyApp.dart';
import 'package:syncfusion_flutter_core/core.dart';


void main() {
//  WidgetsFlutterBinding.ensureInitialized();
//  PushNotificationsManager pushNotificationsManager = PushNotificationsManager();
//  pushNotificationsManager.init();
  SyncfusionLicense.registerLicense
  ("NT8mJyc2IWhia31ifWN9ZmFoZHxiZXxhY2Fjc2JjaWZjaWNlcwMeaCU4NGJrEzowfTIwfSY4");
  runApp(MyApp());
}


