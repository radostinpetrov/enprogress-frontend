import 'dart:convert';
import 'dart:math';

import 'package:drp29/page_widgets/CreateTaskPage.dart';
import 'package:drp29/page_widgets/WorkModePage.dart';
import 'package:drp29/page_widgets/WorkingFriendsPage.dart';
import 'package:drp29/user/User.dart';
import 'package:drp29/widgets/FloatingButton.dart';
import 'package:drp29/widgets/TaskWidget.dart';
import 'package:flutter/material.dart';
import 'package:drp29/top_level/Globals.dart';
import 'package:http/http.dart';

class TasksPage extends StatelessWidget {

  final Future<String> data;
  final User user;

  TasksPage({
    this.data,
    this.user
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1C4D),
      body: SafeArea(
        child: GestureDetector(
          onDoubleTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTaskPage()));
          },
          onVerticalDragUpdate: (DragUpdateDetails details) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => WorkingFriendsPage()));
          },
          behavior: HitTestBehavior.translucent,
          child: Column(
            children: <Widget>[
              Spacer(flex: 2),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Assignments",
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ],
                ),
              ),

              Spacer(flex: 1),
              Expanded(
                flex: 23,
                child: FutureBuilder<String>(
                  future: this.data,
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    switch(snapshot.connectionState) {
                      case(ConnectionState.none):
                        return new Text("Not active");
                      case(ConnectionState.waiting):
                        return new Text("Loading...");
                      case(ConnectionState.active):
                        return new Text("Active");
                      default:
                        if (snapshot.hasError)
                          return new Text("Error :(");
                        else {
                          List<dynamic> decoded = jsonDecode(snapshot.data);
                          List<dynamic> filteredDecoded = new List();
                          for (var elem in decoded) {
                            if (elem != null && elem["deadline"] != null) {
                              DateTime deadline = DateTime.parse(elem["deadline"]);
                              if (deadline != null && DateTime.now().isBefore(deadline)) {
                                filteredDecoded.add(elem);
                              }
                            }
                          }
                          return new ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (_, index) {
                              return TaskWidget(
                                index: index,
                                body: filteredDecoded[index],
                              );
                            },
                            separatorBuilder: (_, index) => Divider(),
                            itemCount: filteredDecoded.length,
                          );
                        }
                    }
                  },
                ),
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
//                    child: FlatButton(
//                      onPressed: () {
//                        Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTaskPage()));
//                      },
//                      color: Globals.buttonColor,
//                      child: Container(
//                        child: Text("Add new task", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
//                      ),
//                    ),
                    ),
                    Spacer(flex: 3,),
                    Expanded(
                      flex: 5,
                      child: Container(),
//                    child: FlatButton(
//                      onPressed: () {
//                        Navigator.push(context, MaterialPageRoute(builder: (context) => WorkModePage()));
//                      },
//                      color: Globals.buttonColor,
//                      child: Container(
//                        child: Text("Study mode", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
//                      ),
//                    ),
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