import 'dart:convert';

import 'package:drp29/user/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:numberpicker/numberpicker.dart';
import 'dart:math' as math;

import 'UpdateTaskPage.dart';


class WorkModePage extends StatefulWidget {

//  final String title;
  final Future<String> subtasks;
//  int taskID;
//  var deadline;
  final User user;
  final Future<String> data;

  WorkModePage({
    this.data,
    this.user,
    this.subtasks
});

  @override
  WorkModeState createState() => WorkModeState(data: data, user: user, subtasks: subtasks);

}

class WorkModeState extends State<WorkModePage>
    with TickerProviderStateMixin {

//  final String title;
  final Future<String> subtasks;
//  int taskID;
//  var deadline;
  final User user;
  final Future<String> data;

  WorkModeState({
    this.data,
    this.user,
    this.subtasks
  });


  static const platform = const MethodChannel('flutter/enprogress');
  AnimationController controller;

  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  bool _isTiming = false;
  int _workModeDuration = 0;
  double _totalTimeWorked = 0;

  final Client client = new Client();
  var uri;

  Future<String> _getSubTasks(int id) async {
    uri = Uri.parse("http://146.169.40.203:3000/tasks/" + id.toString() + "/subtasks");
    Response response = await client.get(uri);
    String jsonResponse = response.body;
    return jsonResponse;
  }


  _PostUserPointsAndUpdateTask(context) async {

    if (controller.value > 0) {
      _totalTimeWorked -= controller.value;
    }

    Map<String, dynamic> body = {
      'points' : (_totalTimeWorked.floor() / 60).floor()
    };

    Map<String, String> headers = {"Content-type": "application/json"};

    String url = "http://146.169.40.203:3000/users/" + user.userID.toString() ;

    Response response = await patch(url, headers: headers, body:
    jsonEncode(body));

//    print(jsonEncode(body));

    String dataResponse = await data;
    List<dynamic> list = jsonDecode(dataResponse);
    Map<String, dynamic> map = list[0];
    print(map);
    String title = map["name"];
    print(title);
    int taskID = map["id"];
    print(taskID);
    String deadline = map["deadline"];
    print(deadline);

    Future<String> subtasks = _getSubTasks(taskID);


    Navigator.push(context, MaterialPageRoute
      (builder: (context) => UpdateTaskPage(title, subtasks,
        taskID, deadline)));
  }


  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _workModeDuration),
    );
    controller.addListener(() async {
      if(controller.value == 0.0) {
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

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
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
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
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
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Work Mode Timer: $_workModeDuration",
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        timerString,
                                        style: TextStyle(
                                            fontSize: 112.0,
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
                            Column( children: [
                            Padding(
                              padding: EdgeInsets.only(right: 40.0, left: 50.0, bottom: 50.0),
                              child: AnimatedBuilder(
                                  animation: controller,
                                  builder: (context, child) {
                                    return FloatingActionButton.extended(
                                      heroTag: "timerStartBtn",
                                        onPressed: () async {
                                          if (controller.value == 0.0) {
                                            controller.duration = Duration(seconds: _workModeDuration);
                                            _totalTimeWorked +=
                                                _workModeDuration;
                                            await platform.invokeMethod("turnDoNotDisturbModeOn");
                                          }
                                          if (controller.isAnimating)
                                            controller.stop();
                                          else {
                                            controller.reverse(
                                                from: controller.value == 0.0
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
                                        label:
                                        Text(_isTiming ? "Pause" : "Play"));
                                  }),
                            ),

                            Padding(
                              padding: EdgeInsets.only(right: 40.0, left: 50.0, bottom: 50.0),
                              child: Visibility(
                                  visible: !_isTiming,
                                  child: FloatingActionButton.extended(
                                    heroTag: "finishBtn",
                                      onPressed: () {
                                        _PostUserPointsAndUpdateTask(context);
                                      },
                                      label: Text("Finish"),)),
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
