import 'dart:convert';

import 'package:drp29/Globals.dart';
import 'package:drp29/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CurrentTaskPage extends StatelessWidget {
  final int index;
  final String title;
  final Future<String> subtasks;
  var deadline;

  CurrentTaskPage({this.index, this.title, this.subtasks, this.deadline});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.primaryBlue,
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Spacer(flex: 2),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: "title",
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
              ],
            ),
          ),
          Spacer(flex: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today
              ),
              Text(
                deadline == null
                ? 'Deadline N/A' :
                'Due by:'
                '$deadline',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
            ),
          ),
          ]
          ),
          Spacer(flex: 1),
          Expanded(
            flex: 30,
            child: Hero(
              tag: "current_task" + index.toString(),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Globals.buttonColor,
                  ),
                  height: 800,
                  width: 340,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyApp()));
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Column(
                      children: <Widget>[
                        Spacer(
                          flex: 1,
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: <Widget>[
                              Spacer(
                                flex: 1,
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  "Subtasks",
                                  style: Theme.of(context).textTheme.bodyText2,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Spacer(
                                flex: 1,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Divider(
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          flex: 20,
                          child: FutureBuilder<String>(
                            future: subtasks,
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              switch (snapshot.connectionState) {
                                case (ConnectionState.none):
                                  return new Text("Not active");
                                case (ConnectionState.waiting):
                                  return new Text("Loading...");
                                case (ConnectionState.active):
                                  return new Text("Active");
                                default:
                                  if (snapshot.hasError)
                                    return new Text("Error :(");
                                  else {
                                    List<dynamic> decoded =
                                        jsonDecode(snapshot.data);
                                    return new ListView.separated(
                                      shrinkWrap: true,
                                      itemBuilder: (_, index) {
                                        return Row(
                                          children: <Widget>[
                                            Spacer(
                                              flex: 1,
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Text(
                                                decoded[index]
                                                    .values
                                                    .toList()[1],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                              ),
                                            ),
                                            Spacer(
                                              flex: 1,
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                decoded[index]
                                                        .values
                                                        .toList()[2]
                                                        .toString() +
                                                    "%",
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                      separatorBuilder: (_, index) => Divider(),
                                      itemCount: decoded.length,
                                    );
                                  }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
          Spacer(
            flex: 2,
          ),
        ],
      )),
    );
  }
}
