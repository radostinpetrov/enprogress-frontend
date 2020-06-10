import 'dart:convert';

import 'package:drp29/top_level/Globals.dart';
import 'package:drp29/top_level/MyApp.dart';
import 'package:drp29/page_widgets/UpdateTaskPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';


class CurrentTaskPage extends StatelessWidget {
  final int index;
  final String title;
  final Future<String> subtasks;
  int taskID;
  var deadline;

  CurrentTaskPage({this.index, this.title, this.subtasks, this.taskID, this.deadline});


  List<dynamic> _SeparateList(BuildContext context ,List<dynamic> list) {

    List<dynamic> items = List();
    List<dynamic> separated = List();

    for(int i = 0; i < list.length; i++) {
      items.add(list[i]);

      if (((i + 1) % 2) == 0) {
        separated.add(items);
        items = List();
      }
    }

    if (items.length > 0) {
      separated.add(items);
    }

    return separated;
  }

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
                        Navigator.pop(context, MaterialPageRoute(builder: (context) => MyApp()));
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
                                      List<dynamic> separated = _SeparateList
                                        (context, decoded);
                                      return new ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: separated.length,
                                        itemBuilder: (_, index) {
                                          return Container(
                                              alignment: Alignment.center,
                                              height: 170,
                                              width: 340,
                                              child: ListView.separated(
                                                  shrinkWrap: true,
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: separated[index].length,
                                                  itemBuilder: (_, newIndex) {
                                                    return
                                                      CircularPercentIndicator(
                                                        radius: 120.0,
                                                        lineWidth: 13.0,
                                                        animation: true,
                                                        percent:
                                                        separated[index][newIndex]['percentage']/100,
                                                        center: Text(
                                                          separated[index][newIndex]['percentage']
                                                              .toString() + "%",
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyText2,
                                                        ),
                                                        footer: Text(
                                                          separated[index][newIndex]['name'],
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyText2,
                                                        ),
                                                      );
                                                    },
                                                  separatorBuilder:
                                                      (BuildContext context,
                                                      int index) {
                                                    return SizedBox(width: 20);
                                                  }));
                                          },
                                        separatorBuilder: (_, index) => Divider(),
                                      );
                                    }
                                }
                              },
                            ),
                          ),
                          FlatButton(
                            color: Globals.primaryBlue,
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute
                              (builder: (context) => UpdateTaskPage(title, subtasks,
                                  taskID, deadline)));
                            },
                            child: Container(
                              child: Text("Update", textAlign: TextAlign
                                  .center, style: Theme.of(context).textTheme.bodyText2),
                            ),
                          )
                        ],
                      ),
                    )
                  ),
                ),
            ),
              Spacer(flex: 2,),
            ],
        )
      ),
    );
  }
}