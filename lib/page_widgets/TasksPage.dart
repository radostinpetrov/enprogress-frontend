import 'dart:convert';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:drp29/page_widgets/CreateTaskPage.dart';
import 'package:drp29/page_widgets/WorkModePage.dart';
import 'package:drp29/page_widgets/WorkingFriendsPage.dart';
import 'package:drp29/widgets/FloatingButton.dart';
import 'package:drp29/widgets/TaskWidget.dart';
import 'package:flutter/material.dart';
import 'package:drp29/top_level/Globals.dart';
import 'package:http/http.dart';

class TasksPage extends StatelessWidget {

  final Future<String> data;

  TasksPage({
    this.data
  });

  FutureBuilder<String> _futureBuilder0(BuildContext context) {
    return FutureBuilder<String>(
      future: this.data,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case(ConnectionState.none):
            return new Text("Not active");
          case(ConnectionState.waiting):
            return new Text("Loading...");
          case(ConnectionState.active):
            return new Text("Active");
          default:
            if (snapshot.hasError)
              return new Text("Error :(");
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
                    body: filteredDecoded[index],
                  );
                },
                separatorBuilder: (_, index) => Divider(),
                itemCount: filteredDecoded.length,
              );
            }
        }
      },
    );
  }

  Text _text0(BuildContext context) {
    return Text(
      "Assignments",
      style: Theme.of(context).textTheme.headline1,
    );
  }

  CarouselSlider _carouselSlider0() {
    return CarouselSlider.builder(
      options: CarouselOptions(
        aspectRatio: 16/7,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
      ),
      itemCount: 3,
      itemBuilder: (BuildContext context, int index) {
        return TaskWidget(index: index, body: null,);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.primaryBlue,
      body: SafeArea(
        child: GestureDetector(
          onDoubleTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTaskPage()));
          },
          onVerticalDragUpdate: (DragUpdateDetails details) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => WorkingFriendsPage()));
          },
          behavior: HitTestBehavior.translucent,
          child: Column(
            children: <Widget>[
              Spacer(flex: 2),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _text0(context),
                  ],
                ),
              ),

              Spacer(flex: 1),
              Expanded(
                flex: 23,
                child: _futureBuilder0(context),
              ),
              Spacer(flex: 3,),
              Expanded(
                flex: 4,
                child: Row(
                  children: <Widget>[
                    Spacer(flex: 5,),
                    Expanded(
                      flex: 5,
                      child: Container(),
                    ),
                    Spacer(flex: 3,),
                    Expanded(
                      flex: 5,
                      child: Container(),
                    ),
                    Spacer(flex: 5,),
                  ],
                ),
              ),
              Spacer(flex: 2,)
            ],
          ),
        ),
      ),
    );
  }
}