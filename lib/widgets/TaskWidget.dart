import 'dart:io';

import 'package:drp29/Globals.dart';
import 'package:drp29/page_widgets/CurrentTaskPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TaskWidget extends StatelessWidget {
  int index;

  TaskWidget({
    this.index
  });

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
                    Navigator.push(context, MaterialPageRoute(builder: (_) {return CurrentTaskPage(index: index,);} ));
                  },
                  child: Text("Stop procrastinating"),
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