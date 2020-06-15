import 'dart:io';

import 'package:EnProgress/top_level/Globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:EnProgress/page_widgets/friend_page_widgets/CurrentFriendPage.dart';

class FriendWidget extends StatelessWidget {
  final int index;
  final String title;
  int points;
  int id;

  FriendWidget({
    this.index, this.points, this.id, this.title
  });


  Color _setColor(index) {
    switch(index) {
      case 0:
        return Colors.amberAccent; // Gold
      case 1:
        return Colors.grey; // Silver
      case 2:
        return Colors.brown; // Bronze
      default:
        return Globals.buttonColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Spacer(flex: 5,),
          Hero(
            tag: "current_friend" + index.toString(),
            child: Container(
              width: 250,
              height: 50,
              child: ButtonTheme(
                minWidth: 250,
                height: 50,
                buttonColor: _setColor(index),
                textTheme: ButtonTextTheme.primary,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_)
                    {return CurrentFriendPage(id: id, index: index, title:
                    title,);}
                    ));
                  },
                  child: Row(
                      children: [
                        Expanded(child: Text(title)),
                        Text(points.toString()),
                        Icon(Icons.hourglass_empty, color: Colors.green, size:
                        15),
                      ]
                  )
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