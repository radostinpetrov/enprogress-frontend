import 'dart:convert';

import 'package:EnProgress/top_level/Globals.dart';
import 'package:EnProgress/user/User.dart';
import 'package:EnProgress/widgets/TaskWidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class SelectTaskPage extends StatelessWidget {

  User user;

  SelectTaskPage(this.user);

  Future<String> _getTasks() async {
    Uri uri = Uri.parse(Globals.serverIP + "tasks?fk_user_id=" + user.userID
        .toString());
    Response resp = await Client().get(uri);
    return resp.body;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.primaryBlue,
      body: SafeArea(
        child: Column(children: [

          Spacer(),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FittedBox(fit: BoxFit.fill,
                    child: Text(
                      "Select Task To Update",
                      style: TextStyle(fontSize: 25, inherit: true, color:
                      Colors.white, letterSpacing: 4,
                          fontWeight: FontWeight.w300),
                    )
                ),
              ],
            ),
          ),
          Spacer(flex: 1),
          Expanded(flex:30, child:
        FutureBuilder<String>(
          future: _getTasks(),
          builder:
              (BuildContext context, AsyncSnapshot<String> snapshot) {
            switch (snapshot.connectionState) {
              case (ConnectionState.none):
                return new Text("Not active");
              case (ConnectionState.waiting):
                return new Text("Loading...");
              case (ConnectionState.active):
                return new Text("Active");
              default:
                if (snapshot.hasError)
                  return new Text("Error");
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
                        user: user,
                        body: filteredDecoded[index],
                      );
                    },
                    separatorBuilder: (_, index) => Divider(),
                    itemCount: filteredDecoded.length,
                  );
                }
            }
          },
        )),
        ]
        )
      ),
//    )
    );
  }

}