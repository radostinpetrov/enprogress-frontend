import 'dart:convert';

import 'package:EnProgress/top_level/Globals.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:EnProgress/utilities.dart';
import 'package:flutter/material.dart';
import 'package:EnProgress/user/User.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:math' as math;

import 'SelectTaskPage.dart';
import 'UpdateTaskPage.dart';

class WorkModePage extends StatefulWidget {

  final User user;
  final int remainingTime;

  WorkModePage({this.user, this.remainingTime});

  @override
  WorkModeState createState() => WorkModeState(
      user: user,  remainingTime: remainingTime);
}

class WorkModeState extends State<WorkModePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  final User user;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var initialisationSettingsAndroid;
  var initialisationSettingsIOS;
  var initialisationSettings;
  final int remainingTime;

  WorkModeState({this.user, this.remainingTime});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initialisationSettingsAndroid = AndroidInitializationSettings("app_icon");
    initialisationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    initialisationSettings = new InitializationSettings(initialisationSettingsAndroid, initialisationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initialisationSettings, onSelectNotification: onSelectNotification);
    controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: _workModeDuration,
          hours: _workModeHours),
    );
    controller.addListener(() async {
      if (controller.value == 0.0) {
        setState(() {
          _isTiming = false;
        });

        await platform.invokeMethod("turnDoNotDisturbModeOff");
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _showNotification();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<dynamic> onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Ok"),
            onPressed: null,
          )
        ],
      )
    );
  }

  Future<dynamic> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint("$payload");
    }
    await platform.invokeMethod("turnDoNotDisturbModeOn");
    controller.reverse(from:
    controller.value == 0.0
        ? 1.0
        : controller.value);
  }

  void _showNotification() async {
    await platform.invokeMethod("turnDoNotDisturbModeOff");
    controller.stop();
    await _demoNotification();
  }

  Future<void> _demoNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel ID',
        'channel name',
        'channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'test ticker');
    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(0, "Come baaaaack!", "You were doing so well! Don't slack off!", platformChannelSpecifics, payload: "test payload");
  }

  AnimationController controller;

  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60)
          .toString()
          .padLeft(2, '0')}';

  }

  bool _isTiming = false;
  int _workModeHours = 0;
  int _workModeMinutes = 0;
  int _workModeDuration = 0;
  double _totalTimeWorked = 0;

  final Client client = new Client();
  var uri;


  _PostUserPointsAndUpdateTask(context) async {
    if (controller.value > 0) {
      _totalTimeWorked -= controller.value;
    }

    Map<String, dynamic> body = {
      'points': (_totalTimeWorked.floor() / 60).floor()
    };

    Map<String, String> headers = {"Content-type": "application/json"};

    String url = Globals.serverIP + "users/" + user.userID.toString();

    Response response =
        await patch(url, headers: headers, body: jsonEncode(body));

//    print(jsonEncode(body));

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectTaskPage(user)));
  }

  static MethodChannel platform = const MethodChannel('flutter/enprogress');

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _workModeDuration),
    );
    controller.addListener(() async {
      if (controller.value == 0.0) {
        setState(() {
          _isTiming = false;
        });

        await Utilities.platform.invokeMethod("turnDoNotDisturbModeOff");
      }
    });

    if (remainingTime != null) {
      print("seeting time");
      controller.duration = Duration(minutes: remainingTime);
      _isTiming = true;
      controller.reverse(
          from:
          controller.value == 0.0
              ? 1.0
              : controller.value);
    }
  }

  AlertStyle alertStyle = AlertStyle(
    animationType: AnimationType.fromBottom,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    descStyle: TextStyle(fontWeight: FontWeight.bold),
    animationDuration: Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0.0),
      side: BorderSide(
        color: Colors.grey,
      ),
    ),
    titleStyle: TextStyle(
      color: Colors.red,
    ),
  );

  Future<bool> _warnAboutExitingWorkMode() {
    // flutter defined function
    return Alert(
      context: context,
      type: AlertType.warning,
      style: alertStyle,
      title: "WAIT!",
      desc: "You were being so productive! Don't Stop Now!",
      buttons: [
        DialogButton(
          child: Text(
            "Im Done!",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            await Utilities.platform.invokeMethod("turnDoNotDisturbModeOff");
            Navigator.pop(context, true);
          },
          color: Colors.red,
        ),
        DialogButton(
          child: Text(
            "I'll stay!",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context, false),
          color: Colors.green,
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return WillPopScope(
      onWillPop: _warnAboutExitingWorkMode,
      child: Scaffold(
        backgroundColor: Colors.white10,
        body: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.amber,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Spacer(flex: 1,),
                      Expanded(
                        flex: 30,
                        child: Align(
                          alignment: FractionalOffset.center,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Stack(
                              children: <Widget>[
                                Positioned.fill(
                                  child: CustomPaint(
                                      painter: CustomWorkModeTimerPainter(
                                    animation: controller,
                                    backgroundColor: Colors.white,
                                    color: themeData.indicatorColor,
                                  )),
                                ),
                                Align(
                                  alignment: FractionalOffset.center,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    child: Column(
                                      //mainAxisAlignment:
                                      //    MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(height: 90),
                                        AutoSizeText(
                                          "", //Work Mode Timer: $_workModeHours hrs $_workModeMinutes mins
                                          maxLines: 1,
                                          style: TextStyle(
//                                              fontSize: 20.0,
                                              color: Colors.white,
                                          letterSpacing: 0),
                                        ),
                                        AutoSizeText(
                                          timerString,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 82.0,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Column(children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: 40.0, left: 50.0, bottom: 50.0),
                                  child: AnimatedBuilder(
                                      animation: controller,
                                      builder: (context, child) {
                                        return FloatingActionButton.extended(
                                            heroTag: "timerStartBtn",
                                            onPressed: () async {
                                              if (controller.value == 0.0) {
                                                controller.duration = Duration(
                                                    seconds: _workModeDuration);
                                                _totalTimeWorked +=
                                                    _workModeDuration;
                                                await platform.invokeMethod(
                                                    "turnDoNotDisturbModeOn");
                                              }
                                              if (controller.isAnimating)
                                                controller.stop();
                                              else {
                                                controller.reverse(
                                                    from:
                                                        controller.value == 0.0
                                                            ? 1.0
                                                            : controller.value);
                                              }
                                              setState(() {
                                                if (controller.value != 0.0) {
                                                  _isTiming = !_isTiming;
                                                }
                                              });
                                            },
                                            icon: Icon(_isTiming
                                                ? Icons.pause
                                                : Icons.play_arrow),
                                            label: Text(
                                                _isTiming ? "Pause" : "Play"));
                                      }),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: 40.0, left: 50.0, bottom: 50.0),
                                  child: Visibility(
                                      visible: !_isTiming,
                                      child: FloatingActionButton.extended(
                                        heroTag: "finishBtn",
                                        onPressed: () {
                                          _PostUserPointsAndUpdateTask(context);
                                        },
                                        label: Text("Finish"),
                                      )),
                                ),
                              ]),
                              Padding(
                                  padding:
                                      EdgeInsets.only(bottom: 50.0, left: 40.0),
                                  child: Visibility(
                                      visible: !_isTiming,
                                      child: NumberPicker.integer(
                                        initialValue: _workModeDuration,
                                        minValue: 0,
                                        maxValue: 200,
                                        onChanged: (newValue) => setState(() {
                                          _workModeDuration = newValue;
                                        }),
                                      ))),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

class CustomWorkModeTimerPainter extends CustomPainter {
  CustomWorkModeTimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(CustomWorkModeTimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
