import 'package:drp29/page_widgets/ArchivePage.dart';
import 'package:drp29/page_widgets/TasksPage.dart';
import 'package:drp29/page_widgets/FriendsPage.dart';
import 'package:flutter/material.dart';
import 'package:drp29/Globals.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "EnProgress",
      theme: Globals.theme,
      home: PageView(
        allowImplicitScrolling: false,
        controller: PageController(
          initialPage: 1,
        ),
        children: <Widget>[
          FriendsPage(),
          TasksPage(),
          ArchivePage()
        ],
      ),
    );
  }
}