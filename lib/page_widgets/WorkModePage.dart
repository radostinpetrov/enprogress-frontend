import 'dart:convert';

import 'package:EnProgress/top_level/Globals.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:EnProgress/user/User.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:numberpicker/numberpicker.dart';
import 'dart:math' as math;

import 'SelectTaskPage.dart';
import 'UpdateTaskPage.dart';

class WorkModePage extends StatefulWidget {

  final User user;

  WorkModePage({
    @required this.user,
});

  @override
  WorkModeState createState() => WorkModeState(user: user);

}

class WorkModeState extends State<WorkModePage>
    with TickerProviderStateMixin {

  final User user;

  WorkModeState({
    @required this.user,
  });

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

  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<bool> _warnAboutExitingWorkMode() {
    // flutter defined function
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Wait!"),
          content: new Text(
              "Are you sure you want to quit the app while in WorkMode?"
              " All progress will be lost!"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () async {
                await platform.invokeMethod("turnDoNotDisturbModeOff");
                Navigator.pop(context, true);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return WillPopScope(
      onWillPop: _warnAboutExitingWorkMode,
//      onWillPop: () async {
//        if (_isTiming) {
//          await _warnAboutExitingWorkMode();
//        }
//        return Future.value(true);
//      },
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Spacer(flex: 1,),
                      Expanded(
                        flex: 16,
                        child: Row(
                          children: [
                            Spacer(flex: 4,),
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  Spacer(flex: 2,),
                                  Expanded(
                                    flex: 4,
                                    child: AnimatedBuilder(
                                        animation: controller,
                                        builder: (context, child) {
                                          return FloatingActionButton.extended(
                                              heroTag: "timerStartBtn",
                                              onPressed: () async {
                                                controller.duration = Duration(
                                                    minutes: _workModeMinutes,
                                                    hours: _workModeHours);
                                                if (controller.value == 0.0) {
                                                  controller.duration = Duration(
                                                      minutes: _workModeMinutes,
                                                  hours: _workModeHours);
                                                  _totalTimeWorked +=
                                                      _workModeDuration;
                                                  await platform.invokeMethod(
                                                      "turnDoNotDisturbModeOn");
                                                }
                                                if (controller.isAnimating) {
                                                  controller.stop();
                                                  await platform.invokeMethod(
                                                      "turnDoNotDisturbModeOff");
                                                } else {
                                                  await platform.invokeMethod(
                                                      "turnDoNotDisturbModeOn");
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
                                  Spacer(flex: 6,),
                                  Expanded(
                                    flex: 4,
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
                                  Spacer(flex: 6,),
                                ]
                              ),
                            ),
                            Spacer(flex: 3,),
                            Expanded(
                              flex: 4,
                              child: Visibility(
                                  visible: !_isTiming,
                                  child: Column(children: [
                                    Text("Hours",
                                        style: TextStyle(
                                            fontSize: 10,
                                            letterSpacing: 0)),
                                    NumberPicker.integer(
                                      listViewWidth: 40,
                                      initialValue: _workModeHours,
                                      minValue: 0,
                                      maxValue: 23,
                                      onChanged: (newValue) => setState(() {
                                        _workModeHours = newValue;
                                      }),
                                    ),
                                  ])),
                            ),
                            Spacer(flex: 1,),
                            Expanded(
                              flex: 4,
                              child: Visibility(
                                  visible: !_isTiming,
                                  child: Column(children: [
                                    Text("Minutes",
                                        style: TextStyle(
                                            fontSize: 10,
                                            letterSpacing: 0)),
                                    NumberPicker.integer(
                                      listViewWidth: 40,
                                      initialValue: _workModeMinutes,
                                      minValue: 0,
                                      maxValue: 59,
                                      onChanged: (newValue) => setState(() {
                                        _workModeMinutes = newValue;
                                      }),
                                    ),
                                  ])),
                            ),
                            Spacer(flex: 5,),
                          ],
                        ),
                      )
                    ],
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
