import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:EnProgress/page_widgets/UpdateTaskPage.dart';
import 'package:EnProgress/top_level/Globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:EnProgress/user/User.dart';

class TaskWidget extends StatelessWidget {

  final Client client = new Client();
  var uri;

  final int index;
  String title;
  final Map<String, dynamic> task;
  Future<String> subtasks;
  int taskID;
  final User user;
  String deadline;

  bool clickable;

  TaskWidget({
    @required this.index,
    @required this.task,
    @required this.user,
    this.clickable = false,
  }) {
    this.taskID = this.task['id'];
    this.title = this.task.values.toList()[1];
    this.subtasks = _getSubTasks(this.task.values.toList()[0]);
    this.deadline = this.task.values.toList()[3];
  }

  Future<String> _getSubTasks(int id) async {
    uri = Uri.parse(Globals.serverIP + "tasks/" + id.toString() + "/subtasks");
    Response response = await client.get(uri);
    String jsonResponse = response.body;
    return jsonResponse;
  }

  @override
  Widget build(BuildContext context) {

    int daysRemaining = DateTime.parse(deadline).difference(DateTime.now()).inDays;
    if (daysRemaining < 0) daysRemaining = 0;
    double percent = daysRemaining / 50;
    MaterialColor deadlineColor = percent > 1/4 ? Colors.lightGreen : (percent > 1/6 ? Colors.amber : Colors.red);

    return GestureDetector(
      onTap: () {
        if (clickable) {
          Navigator.push(context, MaterialPageRoute
            (builder: (context) => UpdateTaskPage(taskWidget: this, index: index, user: user, title: title, subtasks: subtasks,
              taskID: taskID, deadline: deadline)));
        }
      },
      child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            color: deadlineColor,
          ),
          child: Row(
            children: <Widget>[
              Spacer(flex: 2,),
              Expanded(
                flex: 15,
                child: FittedBox(fit: BoxFit.scaleDown, child: AutoSizeText(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                )),
              ),
              Expanded(
                flex: 15,
                child: CircularPercentIndicator(
                  radius: 110.0,
                  lineWidth: 13.0,
                  animation: true,
                  backgroundColor: Colors.white70,
                  progressColor: (deadlineColor == Colors.amber) ? Colors.amberAccent :
                  (deadlineColor == Colors.lightGreen) ? Colors.lightGreenAccent :Colors.redAccent,
                  reverse: true,
                  percent: percent,
                  center: Container(
                    width: 60,
                    child: Container(
                      width: 40,
                      height: 40,
                      child: AutoSizeText(
                        (daysRemaining == 0) ? "Due" : daysRemaining.toString() + " days",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(flex: 2,)
            ],
          )
      ),
    );
  }
}