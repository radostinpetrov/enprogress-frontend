import 'dart:convert';
import 'dart:math';

import 'package:EnProgress/page_widgets/CreateTaskPage.dart';
import 'package:EnProgress/page_widgets/WorkModePage.dart';
import 'package:EnProgress/top_level/MyApp.dart';
import 'package:EnProgress/widgets/FloatingButton.dart';
import 'package:EnProgress/widgets/TaskWidget.dart';
import 'package:flutter/material.dart';
import 'package:EnProgress/top_level/Globals.dart';
import 'package:http/http.dart';

class WorkingFriendsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1C4D),
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragUpdate: (DragUpdateDetails details) {
            Navigator.pop(context, MaterialPageRoute(builder: (context) => MyApp()));
          },
          behavior: HitTestBehavior.translucent,
          child: Column(
            children: <Widget>[
              Spacer(flex: 2),
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Spacer(),
                    Expanded(
                      flex: 10,
                      child: Text(
                        "Friends currently working",
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),

              Spacer(flex: 1),
              Expanded(
                flex: 22,
                child: Row(
                  children: <Widget>[
                    Spacer(flex: 2),
                    Expanded(
                      flex: 10,
                      child: Image(
                        height: 70.0,
                        width: 56.0,
                        image: AssetImage("images/icons8-peter-the-great-96.png"),
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Image(
                        height: 70.0,
                        width: 56.0,
                        image: AssetImage("images/icons8-peter-the-great-96.png"),
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Image(
                        height: 70.0,
                        width: 56.0,
                        image: AssetImage("images/icons8-peter-the-great-96.png"),
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Image(
                        height: 70.0,
                        width: 56.0,
                        image: AssetImage("images/icons8-peter-the-great-96.png"),
                      ),
                    ),
                    Spacer(flex: 2),
                  ],
                )
              ),
              Spacer(flex: 3,),
              Expanded(
                flex: 4,
                child: Row(
                  children: <Widget>[
                    Spacer(flex: 5,),
                    Expanded(
                      flex: 5,
                      child: Container(),
                    ),
                    Spacer(flex: 3,),
                    Expanded(
                      flex: 5,
                      child: Container(),
                    ),
                    Spacer(flex: 5,),
                  ],
                ),
              ),
              Spacer(flex: 2,)
            ],
          ),
        ),
      ),
    );
  }
}