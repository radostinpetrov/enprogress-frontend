import 'dart:io';

import 'package:drp29/top_level/Globals.dart';
import 'package:drp29/page_widgets/CurrentTaskPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class TaskWidget extends StatelessWidget {

  final Client client = new Client();
  var uri;

  final int index;
  String title;
  final Map<String, dynamic> body;
  Future<String> subtasks;
  int taskID;
  var deadline;
  final user;

  TaskWidget({
    this.user,
    this.index,
    this.body,
  }) {
    this.taskID = this.body['id'];
    this.title = this.body.values.toList()[1];
    this.subtasks = _getSubTasks(this.body.values.toList()[0]);
    this.deadline = this.body.values.toList()[3];
  }

  Future<String> _getSubTasks(int id) async {
    uri = Uri.parse("http://146.169.40.203:3000/tasks/" + id.toString() + "/subtasks");
//    print(uri);
    Response response = await client.get(uri);
    String jsonResponse = response.body;
    return jsonResponse;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Spacer(flex: 5,),
          Hero(
            tag: "current_task" + index.toString(),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Globals.buttonColor,
                ),
//              color: Globals.buttonColor,
              width: 250,
              height: 50,
              child: ButtonTheme(
                minWidth: 250,
                height: 50,
                buttonColor: Globals.buttonColor,
                textTheme: ButtonTextTheme.primary,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_)
                    {return CurrentTaskPage(user: user, index: index, title:
                    title,
                        subtasks: subtasks, taskID: taskID, deadline: deadline);} ));
                  },
                  child: Text(title),
                ),
              )
            ),
          ),
          Spacer(flex: 5,)
        ],
      )
    );
  }
}