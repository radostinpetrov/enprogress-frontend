import 'package:drp29/Globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CurrentTaskPage extends StatelessWidget {
  int index;

  CurrentTaskPage({
    this.index
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.primaryBlue,
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
                    "assigment1",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
              ],
            ),
            Spacer(flex: 1),
            Spacer(flex: 2,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: "current_task" + index.toString(),
                  child: Container(
                    color: Globals.buttonColor,
                    height: 500,
                    width: 300,
                  ),
                ),
              ],
            ),
            Spacer(flex: 5,),
          ],
        )
      ),
    );
  }
}