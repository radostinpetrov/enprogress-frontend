import 'package:drp29/Globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CurrentTaskPage extends StatelessWidget {
  final int index;
  final String title;

  CurrentTaskPage({
    this.index, this.title
  });

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
                tag: "current_task" + index.toString(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Globals.buttonColor,
                  ),
                  height: 500,
                  width: 300,
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