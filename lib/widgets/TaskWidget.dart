import 'dart:io';

import 'package:drp29/Globals.dart';
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
  var deadline;

  TaskWidget({
    this.index,
    this.body,
  }) {
    this.title = this.body.values.toList()[1];
    this.subtasks = _getSubTasks(this.body.values.toList()[0]);
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
              color: Globals.buttonColor,
              width: 250,
              height: 50,
              child: ButtonTheme(
                minWidth: 250,
                height: 50,
                buttonColor: Globals.buttonColor,
                textTheme: ButtonTextTheme.primary,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {return CurrentTaskPage(index: index, title: title, subtasks: subtasks, deadline: deadline);} ));
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