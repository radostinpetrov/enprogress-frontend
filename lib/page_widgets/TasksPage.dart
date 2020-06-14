import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:drp29/page_widgets/ArchivePage.dart';
import 'package:drp29/page_widgets/CreateTaskPage.dart';
import 'package:drp29/page_widgets/SignInPage.dart';
import 'package:drp29/page_widgets/WorkModePage.dart';
import 'package:drp29/page_widgets/WorkingFriendsPage.dart';
import 'package:drp29/user/User.dart';
import 'package:drp29/widgets/FloatingButton.dart';
import 'package:drp29/widgets/TaskWidget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:drp29/top_level/Globals.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TasksPage extends StatefulWidget {

  final Future<String> data;
  final User user;
  var signoutCallback;

  TasksPage({
    this.data,
    this.user,
    this.signoutCallback
  });

  @override
  State<StatefulWidget> createState() {
    return TasksPageState(
        data: data, user: user, signoutCallback: signoutCallback);
  }

}

class TasksPageState extends State<TasksPage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final Client client = new Client();
  var uri;

  final Future<String> data;
  Future<String> subtasks;
  List<dynamic> filteredDecoded;
  final User user;
  var signoutCallback;

  static Future<bool> sendFcmMessage(String title, String message) async {
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
        'to': 'dh2zmmpZGG8:APA91bGw1P-vZfUdNK8chk12Q_TFPryEum2Q5wy3kXQeiJoW0vnzqiQQFAbbjwoUqk2lACIAWclknb3MT4FXavDdse_MSAaTLYPuvCvEtKNmI5G3rz2yj1Aqk7Tc-SMgQyapyBlp9niY'
      };

      var client = new Client();
      var response =
      await client.post(url, headers: header, body: json.encode(request));
      return true;
    } catch (e, s) {
      print(e);
      return false;
    }
  }

  @override
  initState() {
    super.initState();

    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        print("${message['body']}");
        onSelectNotification(message['notification']['body']);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        onSelectNotification(message['body']);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        onSelectNotification(message['body']);
      },
    );

    _firebaseMessaging.getToken();

    var initializationSettingsAndroid = AndroidInitializationSettings(
        'app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
        initializationSettings, onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    print("oh nana");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("This is a notification"),
        content: Text("This is the description of the notification. Payload: $payload"),
      )
    );
  }

  Future _showNotificationWithoutSound() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'flutter/enprogress', 'your channel description',
        playSound: false, importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
      'How to Show Notification in Flutter',
      platformChannelSpecifics,
      payload: 'No_Sound',
    );
  }


  TasksPageState({
    this.data,
    this.user,
    this.signoutCallback
  });

  int _currentIndex = 0;

  Future<String> _getSubTasks(int id) async {
    uri = Uri.parse(
        "http://enprogressbackend.herokuapp.com/tasks/" + id.toString() +
            "/subtasks");
    Response response = await client.get(uri);
    String jsonResponse = response.body;
    return jsonResponse;
  }

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
              return new Text(
                "An error occurred while connecting to the server :(",
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
              this.subtasks =
                  _getSubTasks(filteredDecoded[_currentIndex]["id"]);
              return _carouselSlider0(filteredDecoded);
            }
        }
      },
    );
  }

  FutureBuilder<String> _futureBuilder1(BuildContext context) {
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
              return new Text(
                "An error occurred while connecting to the server :(",
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
              return _currentTaskSubpage(filteredDecoded);
            }
        }
      },
    );
  }

  CarouselSlider _carouselSlider0(List<dynamic> filteredDecoded) {
    return CarouselSlider.builder(
      options: CarouselOptions(
        aspectRatio: 16 / 7,
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

  Column _currentTaskSubpage(List<dynamic> filteredDecoded) {
    int _taskID = filteredDecoded[_currentIndex]["id"];
    DateTime deadline = DateTime.parse(
        filteredDecoded[_currentIndex]["deadline"]);

    return Column(
      children: <Widget>[
        Expanded(
          flex: 8,
          child: Row(
            children: <Widget>[
              Spacer(flex: 1,),
              Expanded(
                flex: 4,
                child: Icon(Icons.timer, size: 40, color: Color(0xDFFFFFFF),),
              ),
              Spacer(flex: 1,),
              Expanded(
                flex: 8,
                child: AutoSizeText(
                  DateFormat.yMd().format(deadline),
                  maxLines: 1,
                ),
              ),
              Spacer(flex: 1,),
              Expanded(
                flex: 5,
                child: AutoSizeText(
                  DateFormat.Hm().format(deadline),
                  maxLines: 1,
                ),
              ),
              Spacer(flex: 1,)
            ],
          ),
        ),
        Spacer(flex: 1,),
        Expanded(
          flex: 20,
          child: FutureBuilder<String>(
            future: subtasks,
            builder: (BuildContext context,
                AsyncSnapshot<String> snapshot) {
              switch (snapshot.connectionState) {
                case (ConnectionState.none):
                  return new Text("Not active");
                case (ConnectionState.waiting):
                  return new Text("Loading...");
                case (ConnectionState.active):
                  return new Text("Active");
                default:
                  if (snapshot.hasError)
                    return new Text("Error :(");
                  else {
                    List<dynamic> decoded =
                    jsonDecode(snapshot.data);
                    List<dynamic> separated = _SeparateList
                      (context, decoded);
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
                                  return
                                    Container(width: 170,
                                        child:
                                        CircularPercentIndicator(
                                            radius: 80.0,
                                            lineWidth: 11.0,
                                            animation: true,
                                            percent:
                                            separated[index][newIndex]['percentage'] /
                                                100,
                                            center: Text(
                                                separated[index][newIndex]['percentage']
                                                    .toString() + "%",
                                                style: TextStyle(
                                                    letterSpacing: 1,
                                                    fontSize: 14
                                                )
                                            ),
                                            footer: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(
                                                  separated[index][newIndex]['name'],
                                                  textAlign: TextAlign.center,
                                                  softWrap: true,
//                                                          textWidthBasis: t,
                                                  style: TextStyle(
                                                      fontSize: 20
                                                  )
                                              ),
                                            )));
                                },
                                separatorBuilder: (_, index) {
                                  return SizedBox(width: 0);
                                }));
                      },
                      separatorBuilder: (_, index) => Divider(),
                    );
                  }
              }
            },
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.primaryBlue,
      body: SafeArea(
        child: Column(
            children: <Widget>[
              Spacer(flex: 1,),
              Expanded(
                flex: 4,
                child: Row(
                  children: <Widget>[
                    Spacer(),
                    Expanded(
                        child: GestureDetector(
                          onTap: () {
//                          signoutCallback();
//                          _showNotificationWithoutSound();
                            sendFcmMessage("Hello World", "Look at me im Mr. Meeesiks");
                          },
                          child: Icon(Icons.menu, color: Colors.white,),
                        )
                    ),
                    Spacer(flex: 3,),
                    Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) =>
                                ArchivePage(data: data, user: user,)));
                          },
                          child: Icon(Icons.archive, color: Colors.white,),
                        )
                    ),
                    Spacer(flex: 3,),
                    Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) =>
                                CreateTaskPage(user)));
                          },
                          child: Icon(Icons.add, color: Colors.white,),
                        )
                    ),
                    Spacer()
                  ],
                ),
              ),
              Spacer(),
              Expanded(
                child: Divider(color: Colors.black,),
              ),
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
//              Spacer(flex: 5,),
              Expanded(
                flex: 45,
                child: _futureBuilder1(context),
              ),
            ]
        ),
      ),
    );
  }
}