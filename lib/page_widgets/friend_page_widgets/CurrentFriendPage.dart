import 'dart:convert';

import 'package:drp29/top_level/Globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class CurrentFriendPage extends StatelessWidget {
  final int index;
  final String title;

  CurrentFriendPage({
    this.index, this.title
  });

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
            Expanded(
              flex: 23,
              child: Hero(
                tag: "current_friend" + index.toString(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Globals.buttonColor,
                  ),
                  height: 500,
                  width: 300,
                  child: FutureBuilder<String>(
                      future: _getNumberOfTasks(),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        switch(snapshot.connectionState) {
                          case(ConnectionState.none):
                            return new Text("Not active");
                          case(ConnectionState.waiting):
                            return new Text("Loading...", style: TextStyle
                              (fontSize: 15),);
                          case(ConnectionState.active):
                            return new Text("Active");
                          default:
                            if (snapshot.hasError)
                              return new Text("Error :(");
                            else {
                              List<dynamic> decoded = jsonDecode(snapshot.data);
                              return new ListView.separated(
                                shrinkWrap: true,
                                itemBuilder: (_, index) {
                                  return Row(
                                    children: [
                                    Expanded(child: Text(decoded[index].values
                                        .toList()
                                    [1], softWrap: true, style: TextStyle
                                      (fontSize: 15),)),
                                    Text(decoded[index].values
                                        .toList()[2].toString()+"%"),
                                  ]);
                                },
                                separatorBuilder: (_, index) => Divider(),
                                itemCount: decoded.length,
                              );
                            }
                        }
                      },
                    ),
                  ),
              ),
            ),
            Spacer(flex: 9,),
          ],
        )
      ),
    );
  }
}