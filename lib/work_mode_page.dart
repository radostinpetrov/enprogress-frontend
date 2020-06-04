import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'dart:math' as math;


class WorkModePage extends StatefulWidget {
  @override
  WorkModeState createState() => WorkModeState();


}

class WorkModeState extends State<WorkModePage>
    with TickerProviderStateMixin {
  static const platform = const MethodChannel('flutter/enprogress');
  AnimationController controller;

  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  bool _isTiming = false;
  int _workModeDuration = 0;

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
                            Padding(
                              padding: EdgeInsets.only(right: 40.0, left: 50.0, bottom: 50.0),
                              child: AnimatedBuilder(
                                  animation: controller,
                                  builder: (context, child) {
                                    return FloatingActionButton.extended(
                                        onPressed: () async {
                                          if (controller.value == 0.0) {
                                            controller.duration = Duration(seconds: _workModeDuration);
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
                                padding:
                                EdgeInsets.only(bottom: 50.0, left: 40.0),
                                child: Visibility(
                                    visible: true,
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
