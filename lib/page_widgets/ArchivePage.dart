import 'dart:convert';
import 'dart:math';

import 'package:drp29/page_widgets/CreateTaskPage.dart';
import 'package:drp29/page_widgets/WorkModePage.dart';
import 'package:drp29/widgets/FloatingButton.dart';
import 'package:drp29/widgets/TaskWidget.dart';
import 'package:flutter/material.dart';
import 'package:drp29/top_level/Globals.dart';
import 'package:http/http.dart';

class ArchivePage extends StatelessWidget {

  final Future<String> data;

  ArchivePage({
    this.data
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1C4D),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Spacer(flex: 2),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Past Assignments",
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ],
                ),
              ),

              Spacer(flex: 1),
              Expanded(
                flex: 23,
                child: FutureBuilder<String>(
                  future: data,
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
                          for(var elem in decoded) {
                            if (elem != null && elem["deadline"] != null) {
                              DateTime deadline = DateTime.parse(elem["deadline"]);
                              if (deadline != null && DateTime.now().isAfter(deadline)) {
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
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTaskPage()));
                        },
                        color: Globals.buttonColor,
                        child: Container(
                          child: Text("Add new task", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
//                    Spacer(flex: 3,),
//                    Expanded(
//                      flex: 5,
//                      child: FlatButton(
//                        onPressed: () {
////                          Navigator.push(context, MaterialPageRoute(builder: (context) => WorkModePage()));
//                        },
//                        color: Globals.buttonColor,
//                        child: Container(
//                          child: Text("Study mode", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
//                        ),
//                      ),
//                    ),
                    Spacer(flex: 5,),
                  ],
                ),
              ),
              Spacer(flex: 2,)
            ],
          )
      ),
    );
  }
}