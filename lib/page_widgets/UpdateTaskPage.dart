import 'dart:convert';

import 'package:EnProgress/top_level/Globals.dart';
import 'package:EnProgress/top_level/MyApp.dart';
import 'package:EnProgress/user/User.dart';
import 'package:EnProgress/widgets/TaskWidget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:http/http.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class UpdateTaskPage extends StatefulWidget {

  User user;

  final String title;
  int taskID;
  int index;
  var deadline;
  final Future<String> subtasks;
  TaskWidget taskWidget;

  UpdateTaskPage({
    @required this.index,
    @required this.taskWidget,
    @required this.user,
    @required this.title,
    @required this.subtasks,
    @required this.taskID,
    @required this.deadline
});

  @override
  _UpdateTaskPageState createState() =>
      _UpdateTaskPageState(taskWidget: taskWidget, index: index, user: user, title: title,
          subtasks: subtasks, taskID: taskID, deadline: deadline);
}

class _UpdateTaskPageState extends State<UpdateTaskPage> {

  User user;

  final String title;
  final Future<String> subtasks;
  List<dynamic> decoded;
  Map<int, int> updatedPercentages = Map();
  int taskID;
  var deadline;
  int index;
  TaskWidget taskWidget;

  /* State variables */
  List<double> milestoneValues;

  _UpdateTaskPageState({
    @required this.taskWidget,
    @required this.index,
    @required this.user,
    @required this.title,
    @required this.subtasks,
    @required this.taskID,
    @required this.deadline
});

  void _makePutRequest() async {
    if (milestoneValues == null) {
      return;
    }

    String url = Globals.serverIP + "tasks/" + taskID.toString();

    List<int> subTaskPercentages = List();
    List<String> subTasks = List();
    double totalPercentage = 0;

    int numOfTasks = decoded.length;
    for (int i = 0; i < numOfTasks; i++) {
      int p = (milestoneValues[i] * 100).round();
      if (p == null) {
        subTaskPercentages.add(decoded[i]['percentage']);
        totalPercentage += decoded[i]['percentage'] / numOfTasks;
      } else {
        subTaskPercentages.add(p);
        totalPercentage += p / numOfTasks;
      }
      subTasks.add(decoded[i]['name']);
    }

    Map<String, dynamic> body = {
      'fk_user_id' : user.userID,
      'name': title,
      'percentage': totalPercentage.floor(),
      'subtasks': subTasks,
      'subtaskPercentages': subTaskPercentages,
      'deadline': deadline,
    };

    Map<String, String> headers = {"Content-type": "application/json"};
//    print("The JSON is: " + jsonEncode(body));

    Response resp = await put(url, headers: headers, body: jsonEncode(body));
    print(resp.body);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.primaryBlue,
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Spacer(),
              Row(
                children: <Widget>[
                  Spacer(flex: 1,),
                  Expanded(
                    flex: 8,
                    child: Center(
                      child: taskWidget,
                    ),
                  ),
                  Spacer(flex: 1,),
                ],
              ),
              Spacer(),
//              Divider(color: Colors.white),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Spacer(),
                    Expanded(
                      flex: 6,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Colors.white10,
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              Spacer(flex: 1,),
              Expanded(
                flex: 20,
                child: FutureBuilder<String>(
                  future: subtasks,
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    switch (snapshot.connectionState) {
                      case (ConnectionState.none):
                        return new Text("Not active");
                      case (ConnectionState.waiting):
                        return Center(child: Globals.loadingWidget);
                      case (ConnectionState.active):
                        return new Text("Active");
                      default:
                        if (snapshot.hasError)
                          return new Text("Error :(");
                        else {
                          this.decoded = jsonDecode(snapshot.data);
                          if (milestoneValues == null) {
                            milestoneValues = List<double>.generate(decoded.length, (i) => this.decoded[i]["percentage"] / 100);
                          }
                          return new ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (_, index) {
                              Color activeColor =
                                milestoneValues[index] < 0.15 ? Color(0xFFFFEB00) : (
                                  milestoneValues[index] < 0.30 ? Color(0xFFE7FF00) :
                                  milestoneValues[index] < 0.50 ? Color(0xFFBCFF00) :
                                  milestoneValues[index] < 1.0 ? Color(0xFF64FF00) :
                                                                  Colors.lightBlue);
                              return Container(
                                height: 75,
                                child: Row(
                                  children: <Widget>[
                                    Spacer(flex: 2,),
                                    Expanded(
                                      flex: 9,
                                      child: AutoSizeText(
                                        decoded[index].values.toList()[1],
                                        style: TextStyle(
                                          color: Color(0xDFFFFFFF),
                                          letterSpacing: 1.5,
                                        ),
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Spacer(),
//                                  Expanded(
//                                    flex: 2,
//                                    child: Text(
//                                      decoded[index]['percentage'].toString() + "%",
//                                    ),
//                                  ),
                                    Expanded(
                                      flex: 16,
                                      child: Slider(
                                        activeColor: activeColor,
                                        inactiveColor: Colors.white10,
                                        value: milestoneValues[index],
                                        onChanged: (double newVal) {
                                          setState(() {
                                            milestoneValues[index] = newVal;
                                          });
                                        },
                                      )
                                    ),
                                  Spacer(),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (_, index) => Container(
                              height: 10,
                            ),
                            itemCount: decoded.length,
                          );
                        }
                    }
                  },
                ),
              ),
              Spacer(flex: 2,),
              Expanded(
                flex: 4,
                child: Row(
                  children: <Widget>[
                    Spacer(),
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        splashColor: Globals.primaryBlue,
                        onTap: () {
                          _makePutRequest();
                          Navigator.popUntil(
                            context, ModalRoute.withName("/"));
//                            Navigator.of(context).popAndPushNamed("/");
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                            color: Colors.lightBlue,
                          ),
                          child: Center(
                            child: AutoSizeText(
                              "Update",
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 20,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Spacer()
                  ],
                )
              ),
              Spacer(flex: 2,),
//              InkWell(
//                child: Container(
//                    alignment: Alignment.center,
//                    width: MediaQuery.of(context).size.width,
//                    padding: const EdgeInsets.all(10),
//                    decoration: BoxDecoration(
//                        color: Colors.white70,
//                        shape: BoxShape.rectangle,
//                        borderRadius: BorderRadius.only(
//                            topLeft: Radius.circular(25.0),
//                            bottomRight: Radius.circular(25.0)),
//                        boxShadow: [
//                          BoxShadow(
//                            color: Colors.green,
//                            offset: Offset(1, 1),
//                            blurRadius: 20,
//                          )
//                        ]),
//                    child: Text(
//                      'Update',
//                      style: TextStyle(
//                        fontWeight: FontWeight.bold,
//                        fontSize: 15,
//                        color: Colors.black,
//                      ),
//                    )),
//                onTap: () {
//                  _makePutRequest();
//                  Navigator.popUntil(
//                      context, ModalRoute.withName("/"));
//                  Navigator.of(context).popAndPushNamed("/");
//                },
//              )
            ],
          )),
    );
  }
}
