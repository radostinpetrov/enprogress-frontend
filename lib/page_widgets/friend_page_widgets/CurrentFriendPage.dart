import 'dart:convert';

import 'package:EnProgress/top_level/Globals.dart';
import 'package:EnProgress/page_widgets/SignInPage.dart';
import 'package:EnProgress/page_widgets/WorkModeRequest.dart';
import 'package:EnProgress/top_level/Globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';


import '../../utils.dart';

class CurrentFriendPage extends StatefulWidget {
  final int index;
  final String title;
  int id;

  CurrentFriendPage({this.id, this.index, this.title});

  @override
  CurrentFriendPageState createState() => CurrentFriendPageState();
}

class CurrentFriendPageState extends State<CurrentFriendPage> {
  final Client client = new Client();


  Future<String> _getNumberOfTasks() async {
    final uri = Uri.parse(Globals.serverIP + "tasks?fk_user_id=" + widget.id.toString());
    Response response = await client.get(uri);
    String jsonResponse = response.body;
    return jsonResponse;
  }

  List<dynamic> _SeparateList(BuildContext context, List<dynamic> list) {
    List<dynamic> items = List();
    List<dynamic> separated = List();

    for (int i = 0; i < list.length; i++) {
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

  DateTime _selectedDateTime;

  //TODO: make sure time < current time
  Future<TimeOfDay> _selectTime(BuildContext context) {
    final now = DateTime.now();

    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );
  }

  int _duration = 10;

  Future<bool> _showRequestSyncWorkMode() {
    return Alert(
        style: AlertStyle(backgroundColor: Globals.buttonColor),
        context: context,
        title: "Study With " + widget.title.toString(),
        image: Image.asset('images/icons8-study-100.png'),
        content: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.symmetric(
              inside: BorderSide(width: 1.0),
              outside: BorderSide(width: 0.5, color: Colors.grey)),
          defaultColumnWidth: IntrinsicColumnWidth(),
          children: [
            TableRow(
              children: [
                Center(
                  child: Text(
                    'Duration',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Theme(
                  data: Globals.theme.copyWith(
                      textTheme: TextTheme(
                          bodyText1: TextStyle(fontSize: 30),
                          bodyText2: TextStyle(fontSize: 15))),
                  child: Center(
                    child: NumberPicker.horizontal(
                      minValue: 10,
                      maxValue: 300,
                      initialValue: 20,
                      step: 10,
                      highlightSelectedValue: true,
                      onChanged: (value) => setState(() {
                        _duration = value;
                      }),
                    ),
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Center(
                    child: Text(
                      'Start time',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final selectedDate = DateTime.now();
                      final selectedTime = await _selectTime(context);
                      if (selectedTime == null) return;

                      setState(() {
                        _selectedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        _selectedDateTime = _selectedDateTime.subtract(Duration(hours: 1));
                      });
                    }),
              ],
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () async {
              // TODO: MINUS 1 HOUR FROM TIME (timezone weird thingy)
              print("Friend id is: " + widget.id.toString());
              await Utils.sendWorkModeRequest(user.username, WorkModeRequest(
                  user.userID, widget.id, _selectedDateTime, _duration));
              Navigator.pop(context, true);
            },
            child: Text(
              "STUDY",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            color: Colors.green,
          ),
          DialogButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "CANCEL",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            color: Colors.red,
          )
        ]).show();
  }

  _setRanges(value) {
    return [
      GaugeRange(
          startWidth: 20,
          endWidth: 20,
          startValue: 0,
          endValue:
          20,
          color: (value > 0) ? Color(
              0xFFFF0000) : Colors.grey),
      GaugeRange(
          startWidth: 20,
          endWidth: 20,
          startValue: 21,
          endValue: 40,
          color: (value > 20) ? Color(
              0xFFEF7215) : Colors.grey),
      GaugeRange(
          startWidth: 20,
          endWidth: 20,
          startValue: 41,
          endValue:
          60,
          color: (value > 40) ? Color(
              0xFFFFBF00) : Colors.grey),
      GaugeRange(
          startWidth: 20,
          endWidth: 20,
          startValue: 61,
          endValue: 80,
          color: (value > 60) ? Color(
              0xFFD5E35B): Colors.grey),
      GaugeRange(
          startWidth: 20,
          endWidth: 20,
          startValue: 81,
          endValue:
          100,
          color: (value > 81) ? Color(
              0xFF39FF14) : Colors.grey),
    ];
  }

  _setEmoji(value) {
    if (value == 0) {
      return Icons.sentiment_very_dissatisfied;
    } else if (value < 21) {
      return Icons.sentiment_dissatisfied;
    } else if (value < 61) {
      return Icons.sentiment_neutral;
    } else if (value < 81) {
      return Icons.sentiment_satisfied;
    }
    return Icons.sentiment_very_satisfied;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.primaryBlue,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      widget.title,
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(flex: 1),
            Expanded(
              flex: 50,
              child: Hero(
                tag: "current_friend" + widget.index.toString(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Globals.primaryBlue,
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
                                        return Container(
                                            width: 170,
                                            child: Column(
                                                children: [
                                                  Expanded(child: SfRadialGauge(
                                                      axes: [
                                                        RadialAxis(showLabels: false,
                                                            showAxisLine: true,
                                                            showTicks: false,

                                                            minimum: 0,
                                                            maximum: 100,
                                                            axisLineStyle: AxisLineStyle(
                                                              cornerStyle: CornerStyle
                                                                  .bothCurve,
                                                              color: Colors
                                                                  .transparent,

                                                            ),
                                                            ranges: _setRanges
                                                              (
                                                                separated[index][newIndex]['percentage']),
                                                            annotations: [
                                                              GaugeAnnotation(
                                                                  widget: Container(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                        left: 10),
                                                                    child: Icon(
                                                                      _setEmoji(
                                                                          separated[index][newIndex]['percentage']),
                                                                      size: 90,
                                                                    ),
                                                                  )
                                                              )
                                                            ]
                                                        )
                                                      ]
                                                  )),
                                                  Text
                                                    (separated[index][newIndex]['name'],
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(fontSize: 20),
                                                  )
                                                ]));
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
            Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: FloatingActionButton.extended(
                onPressed: () async {
                  await _showRequestSyncWorkMode();
                },
                backgroundColor: Colors.teal,
                label: Text('Start working together!'),
              ),
            ),
            Spacer(flex: 2),
          ],
        )
      ),
    );
  }
}