import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "EnProgress",
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.cyan,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar (
        title: Text("EnProgress"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("images/icons8-user-96.png"),
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("images/icons8-user-100.png"),
            ),
            ]
            ),
            Row (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("images/icons8-peter-the-great-96.png"),
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("images/icons8-princess-96.png"),
            ),
            ]
            ),
            SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.teal.shade700
              )
            ),
            Text(
              "EnProgress",
              style:TextStyle(
                fontSize:30.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: 20,
                width: 200,
                child: Divider(
                    color: Colors.teal.shade700
                )
            ),
            FlatButton(
              onPressed: () {
                return showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Thank you for using EnProgress"),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text("This is a demo app page."),
                            Text("This app is in active development. Please come back soon for more updates!"),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Okay"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(
                "Start Studying!",
              )
            )
          ],
        )
      ),
    );
  }
}
