import 'package:drp29/user/User.dart';
import 'package:flutter/material.dart';
import 'package:drp29/Globals.dart';
import 'package:drp29/page_widgets/SignInPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final User user = new User(username: "test");

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "EnProgress",
      theme: Globals.theme,
      home: LandingPage()
    );
  }
}
