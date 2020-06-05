import 'dart:io';

import 'package:drp29/Globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:drp29/page_widgets/friend_page_widgets/CurrentFriendPage.dart';

class FriendWidget extends StatelessWidget {
  final int index;
  final String title;

  FriendWidget({
    this.index, this.title
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Spacer(flex: 5,),
          Hero(
            tag: "current_friend" + index.toString(),
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
                    Navigator.push(context, MaterialPageRoute(builder: (_)
                    {return CurrentFriendPage(index: index, title: title,);}
                    ));
                  },
                  child: Text(title),
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