import 'package:flutter/material.dart';
import 'package:drp29/Globals.dart';

class FriendsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF1D1C4D),
      appBar: AppBar (
        title: Text("friends", style: TextStyle(inherit: true)),
        elevation: 0,
        centerTitle: true,
      ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              GestureDetector(
                excludeFromSemantics: true,

              )
            ],
          ),
        )
    );
  }
}