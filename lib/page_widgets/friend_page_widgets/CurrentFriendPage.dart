import 'dart:convert';

import 'package:drp29/top_level/Globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CurrentFriendPage extends StatelessWidget {
  final int index;
  final String title;
  int id;

  CurrentFriendPage({
    this.id, this.index, this.title
  });

  final Client client = new Client();


  Future<String> _getNumberOfTasks() async {
    final uri = Uri.parse(Globals.serverIP + "tasks?fk_user_id=" + id.toString());
    Response response = await client.get(uri);
    String jsonResponse = response.body;
    return jsonResponse;
  }

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
            Expanded(
              flex: 23,
              child: Hero(
                tag: "current_friend" + index.toString(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Globals.buttonColor,
                  ),
                  height: 800,
                  width: 340,
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
                              List<dynamic> separated = _SeparateList
                                (context, decoded);
                              return new ListView.separated(
                                shrinkWrap: true,
                                itemCount: separated.length,
                                itemBuilder: (_, index) {
                                  return Container(
                                    alignment: Alignment.center,
                                    height: 200,
                                    width: 340,
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: separated[index].length,
                                      itemBuilder: (_, newIndex) {
                                        return
                                            Container(
                                              width: 170,
                                              child: CircularPercentIndicator(
                                                radius: 120.0,
                                                lineWidth: 13.0,
                                                animation: true,
                                                percent:
                                                  separated[index][newIndex]['percentage'] / 100,
                                                center: Text(
                                                  separated[index][newIndex]['percentage'].toString() + "%",
                                                  style: Theme.of(context)
                                                      .textTheme.bodyText2,
                                                ),
                                                footer: FittedBox(
                                                  fit: BoxFit.fitWidth,
                                                  child: Text(
                                                    separated[index][newIndex]['name'],
                                                    softWrap: true,
                                                    style: Theme.of(context)
                                                        .textTheme.bodyText2,
                                                  )
                                                ),
                                              )
                                            );
                                      },
                                      separatorBuilder: (_, index) {
                                        return SizedBox(width: 0);
                                        },
                                    )
                                  );
                                },
                                separatorBuilder: (_, index) => Divider(),
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