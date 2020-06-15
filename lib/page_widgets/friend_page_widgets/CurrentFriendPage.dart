import 'dart:convert';

import 'package:drp29/page_widgets/SignInPage.dart';
import 'package:drp29/top_level/Globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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
    final uri = Uri.parse(
        "https://enprogressbackend.herokuapp.com/tasks?fk_user_id=" +
            widget.id.toString());
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

  DateTime selectedDateTime;

  //TODO: make sure time < current time
  Future<TimeOfDay> _selectTime(BuildContext context) {
    final now = DateTime.now();

    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );
  }

  int _studyMinutes = 10;

  Future<bool> _showRequestSyncWorkMode() {
    return Alert(
        style: AlertStyle(backgroundColor: Globals.buttonColor),
        context: context,
        title: "Study With " + widget.title.toString(),
        image: Image.asset('images/icons8-study-100.png'),
        content: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.symmetric(inside: BorderSide(width: 1.0), outside: BorderSide(width: 0.5, color: Colors.grey)),
          defaultColumnWidth: IntrinsicColumnWidth(),
          children: [
            TableRow(
              children: [
                Center (
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
                        _studyMinutes = value;
                      }),
                    ),
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding (
                  padding: EdgeInsets.all(5.0),
                  child: Center (
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
                        selectedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      });
                    }),
              ],
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () async {
              await _sendWorkModeRequest(selectedDateTime, _studyMinutes, 111);
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
  Future<bool> _sendWorkModeRequest(DateTime startTime, int duration, int userID) async {
    // Get friend's FCM token
    String recipientToken = await _getFCMTokenByID(userID);

    // Send FCM message to recipient
    return await sendFcmMessage(user.username + ' would like to work with you', 'From '
        + selectedDateTime.hour.toString() + ':' + selectedDateTime.minute.toString() +
        ' for ' + _studyMinutes.toString() + ' minutes.', recipientToken);
  }
  
  Future<String> _getFCMTokenByID(int userID) async {
    Uri uri = Uri.parse("https://enprogressbackend.herokuapp.com/users/" + userID.toString());
    Response response = await client.get(uri);
    return json.decode(response.body)[0]['fcm_token'];
  }

  static Future<bool> sendFcmMessage(String title, String message, String recipientToken) async {
    try {
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization":
        "key=AAAAtChCW9c:APA91bFB8Il2OZLpctWxp3GGPdEGmu5J3P29KREf-wSW0hfxNIB5Z8xEBfoqzVI5Sj-nsPNdM3Omg2mCJRxnAiAAUZvC2kihg-lizb2rRF-FAYO9gfmsBFzdyF_Uizf5wUYo9pZgjPso",
      };
      var request = {
        'notification': {'title': title, 'body': message},
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'type': 'COMMENT'
        },
        'priority' : 'high',
        'to': recipientToken,
      };

      var client = new Client();
      await client.post(url, headers: header, body: json.encode(request));
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _sendRequest() async {
    return true;
  }
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
                    widget.title,
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
              tag: "current_friend" + widget.index.toString(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Globals.buttonColor,
                ),
                height: 800,
                width: 340,
                child: FutureBuilder<String>(
                  future: _getNumberOfTasks(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    switch (snapshot.connectionState) {
                      case (ConnectionState.none):
                        return new Text("Not active");
                      case (ConnectionState.waiting):
                        return new Text(
                          "Loading...",
                          style: TextStyle(fontSize: 15),
                        );
                      case (ConnectionState.active):
                        return new Text("Active");
                      default:
                        if (snapshot.hasError)
                          return new Text("Error :(");
                        else {
                          List<dynamic> decoded = jsonDecode(snapshot.data);
                          List<dynamic> separated =
                              _SeparateList(context, decoded);
                          return new ListView.separated(
                            shrinkWrap: true,
                            itemCount: separated.length,
                            itemBuilder: (_, index) {
                              return Container(
                                  alignment: Alignment.center,
                                  height: 170,
                                  width: 340,
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: separated[index].length,
                                    itemBuilder: (_, newIndex) {
                                      return Container(
                                          width: 170,
                                          child: CircularPercentIndicator(
                                            radius: 120.0,
                                            lineWidth: 13.0,
                                            animation: true,
                                            percent: separated[index][newIndex]
                                                    ['percentage'] /
                                                100,
                                            center: Text(
                                              separated[index][newIndex]
                                                          ['percentage']
                                                      .toString() +
                                                  "%",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2,
                                            ),
                                            footer: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                  separated[index][newIndex]
                                                      ['name'],
                                                  softWrap: true,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2,
                                                )),
                                          ));
                                    },
                                    separatorBuilder: (_, index) {
                                      return SizedBox(width: 0);
                                    },
                                  ));
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
                if (await _showRequestSyncWorkMode()) {
                  print("hyaa");
                } else {
                  print("ovaahya");
                }
              },
              backgroundColor: Colors.teal,
              label: Text('Start working together!'),
            ),
          ),
          Spacer(
            flex: 9,
          ),
        ],
      )),
    );
  }
}
