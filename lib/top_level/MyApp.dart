import 'package:EnProgress/page_widgets/SignInPage.dart';
import 'package:flutter/material.dart';
import 'package:EnProgress/top_level/Globals.dart';

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "EnProgress",
      theme: Globals.theme,
      home: LandingPage(),
    );
  }
}
