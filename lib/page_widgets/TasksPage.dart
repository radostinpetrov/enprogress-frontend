import 'dart:convert';
import 'dart:math';

import 'package:drp29/page_widgets/CreateTaskPage.dart';
import 'package:drp29/widgets/TaskWidget.dart';
import 'package:flutter/material.dart';
import 'package:drp29/Globals.dart';
import 'package:http/http.dart';

class TasksPage extends StatelessWidget {

  final Client client = new Client();
  final uri = Uri.parse("http://146.169.40.203:3000/tasks");

  Future<String> _getNumberOfTasks() async {
    Response response = await client.get(uri);
    String jsonResponse = response.body;
    return jsonResponse;
  }

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
                  future: _getNumberOfTasks(),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    switch(snapshot.connectionState) {
                      case(ConnectionState.none):
                        return new Text("Not active");
                      case(ConnectionState.waiting):
                        return new Text("Loading...");
                      case(ConnectionState.active):
                        return new Text("Active");
//                      case(ConnectionState.done):
//                        print(snapshot.data);
//                        return new Text("Done");
                      default:
                        if (snapshot.hasError)
                          return new Text("Error");
                        else {
                          print(snapshot.data);
                          List<dynamic> decoded = jsonDecode(snapshot.data);
                          for (Map<String, dynamic> elem in decoded) {
                            print(elem.values.toList()[1]);
                          }
                          return new ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (_, index) {
                              return TaskWidget(
                                index: index,
                                title: decoded[index].values.toList()[1],
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
            Spacer(flex: 3,),
            Expanded(
              flex: 4,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTaskPage()));
                },
                backgroundColor: Colors.white,
                elevation: 5,
                child: Icon(Icons.add, color: Globals.primaryOrange, size: 50,),
              )
            ),
            Spacer(flex: 2,)
          ],
        )
      ),
      floatingActionButton: FloatingButton(
      ),
    );
  }
}