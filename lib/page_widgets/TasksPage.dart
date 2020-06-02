import 'package:drp29/widgets/TaskWidget.dart';
import 'package:flutter/material.dart';
import 'package:drp29/Globals.dart';

import 'FriendsPage.dart';

class TasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1C4D),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Spacer(flex: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: "title",
                  child: Text(
                    "Assignments",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                )
              ],
            ),
            Spacer(flex: 1),
            Flexible(
                flex: 23,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (_, index) => TaskWidget(index: index,),
                  separatorBuilder: (_, index) => Divider(),
                  itemCount: 30),
            ),
            Spacer(flex: 3,),
            Flexible(
              flex: 4,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FriendsPage()));
                },
                backgroundColor: Colors.white,
                elevation: 5,
                child: Icon(Icons.add, color: Globals.primaryOrange, size: 50,),
              )
            ),
            Spacer(flex: 2,)
          ],
        )
      )
    );
  }
}