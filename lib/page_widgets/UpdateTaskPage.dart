import 'dart:convert';

import 'package:EnProgress/top_level/Globals.dart';
import 'package:EnProgress/top_level/MyApp.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:numberpicker/numberpicker.dart';

class UpdateTaskPage extends StatefulWidget {
  final String title;
  final Future<String> subtasks;
  int id;
  var deadline;

  UpdateTaskPage(this.title, this.subtasks, this.id, this.deadline);

  @override
  _UpdateTaskPageState createState() =>
      _UpdateTaskPageState(title, subtasks, id, deadline);
}

class _UpdateTaskPageState extends State<UpdateTaskPage> {
  final String title;
  final Future<String> subtasks;
  List<dynamic> decoded;
  Map<int, int> updatedPercentages = Map();
  int taskID;
  var deadline;

  _UpdateTaskPageState(this.title, this.subtasks, this.taskID, this.deadline);

  _makePutRequest() async {
    String url = Globals.serverIP + "tasks/" + taskID.toString();

    List<int> subTaskPercentages = List();
    List<String> subTasks = List();
    double totalPercentage = 0;

    int numOfTasks = decoded.length;
    for (int i = 0; i < numOfTasks; i++) {
      int p = updatedPercentages[i];
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
      'name': title,
      'percentage': totalPercentage.floor(),
      'subtasks': subTasks,
      'subtaskPercentages': subTaskPercentages,
      'deadline': deadline
    };

    Map<String, String> headers = {"Content-type": "application/json"};
//    print("The JSON is: " + jsonEncode(body));

    Response resp = await put(url, headers: headers, body: jsonEncode(body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.primaryBlue,
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Spacer(),
          Center(
              child: Container(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Updating " + title,
              style: Theme.of(context).textTheme.headline1,
            ),
          )),
          Spacer(),
          Divider(color: Colors.white),
          Expanded(
            flex: 20,
            child: FutureBuilder<String>(
              future: subtasks,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
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
                      this.decoded = jsonDecode(snapshot.data);
//                      print("this is the decoded list: " + decoded.toString());
                      return new ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (_, index) {
//                          print(decoded);
                          return Row(
                            children: <Widget>[
                              Spacer(),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  decoded[index].values.toList()[1],
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ),
                              Spacer(),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  decoded[index]['percentage'].toString() + "%",
                                ),
                              ),
                              Icon(Icons.arrow_forward),
                              Theme(
                                  data: Globals.theme
                                      .copyWith(accentColor: Colors.green),
                                  child: NumberPicker.integer(
                                    initialValue: decoded[index]['percentage'],
                                    step: 10,
                                    minValue: 0,
                                    maxValue: 100,
                                    onChanged: (newValue) => setState(() {
//                                      print(index);
//                                      print(newValue);
                                      updatedPercentages[index] = newValue;
                                    }),
                                  )),
                              Text("%")
                            ],
                          );
                        },
                        separatorBuilder: (_, index) => Divider(
                          color: Colors.white,
                        ),
                        itemCount: decoded.length,
                      );
                    }
                }
              },
            ),
          ),
          InkWell(
            child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        bottomRight: Radius.circular(25.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green,
                        offset: Offset(1, 1),
                        blurRadius: 20,
                      )
                    ]),
                child: Text(
                  'Update',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                )),
            onTap: () {
              _makePutRequest();
              Navigator.pop(
                  context, MaterialPageRoute(builder: (context) => MyApp()));
            },
          )
        ],
      )),
    );
  }
}
