import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:drp29/page_widgets/CreateTaskPage.dart';
import 'package:drp29/page_widgets/WorkModePage.dart';
import 'package:drp29/page_widgets/WorkingFriendsPage.dart';
import 'package:drp29/widgets/FloatingButton.dart';
import 'package:drp29/widgets/TaskWidget.dart';
import 'package:flutter/material.dart';
import 'package:drp29/top_level/Globals.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class TasksPage extends StatefulWidget {

  final Future<String> data;

  TasksPage({
    this.data
});

  @override
  State<StatefulWidget> createState() {
    return TasksPageState(data: data);
  }

}

class TasksPageState extends State<TasksPage> {

  final Future<String> data;
  
  List<dynamic> filteredDecoded;

  TasksPageState({
    this.data
  });

  int _currentIndex = 0;

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
              return new Text("An error occurred while connecting to the server :(",
              textAlign: TextAlign.center,);
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
              this.filteredDecoded = filteredDecoded;
              return _carouselSlider0(filteredDecoded);
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

  CarouselSlider _carouselSlider0(List<dynamic> filteredDecoded) {
    return CarouselSlider.builder(
      options: CarouselOptions(
        aspectRatio: 16/7,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
        onPageChanged: _carouselSlider0PageChanged,
      ),
      itemCount: filteredDecoded.length,
      itemBuilder: (BuildContext context, int index) {
        return TaskWidget(index: index, body: filteredDecoded[index],);
      },
    );
  }

  void _carouselSlider0PageChanged(int index, CarouselPageChangedReason _) {
    setState(() {
      _currentIndex = index;
    });
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
              Spacer(flex: 5,),
              Expanded(
                flex: 30,
                child: _futureBuilder0(context),
              ),
              Spacer(flex: 2,),
              Expanded(
                flex: 1,
                child: Row(
                  children: <Widget>[
                    Spacer(flex: 1,),
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Colors.white10,
                        ),
                      ),
                    ),
                    Spacer(flex: 1,),
                  ],
                ),
              ),
              Spacer(flex: 5,),
              Expanded(
                flex: 45,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: <Widget>[
                          Spacer(flex: 1,),
                          Expanded(
                            child: Icon(Icons.timer, size: 40, color: Color(0xDFFFFFFF),),
                          ),
                          Spacer(flex: 1,),
                          Expanded(
                            flex: 10,
                            child: AutoSizeText(
                              ""
                            ),
                          ),
                          Spacer(flex: 1,),
                        ],
                      ),
                    ),
                    Spacer(flex: 30,)
                  ],
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}