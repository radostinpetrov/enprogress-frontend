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
          children: [
            Row (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("images/icons8-user-96.png"),
              child: FlatButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PersonalPage())
                  );
                },
              ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskCreatePage())
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

class TaskCreatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar(
        title: Text("New Personal Task"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column (
          children: [
            SizedBox(
                height: 20,
                width: 200,
            ),
          Text(
            "Name of Task",
            style: TextStyle(
              fontSize:20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter task name"
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
              height: 50,
              width: 200,
              child: Divider(
                  color: Colors.teal.shade700
              )
          ),
          Text(
            "Add Sections To Work On",
            style: TextStyle(
              fontSize:20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: <Widget>[
              Container(
                height: 50,
                color: Colors.grey[600],
                child: const Center(child: Text("Research")),
              ),
              Container(
                height: 50,
                color: Colors.grey[500],
                child: const Center(child: Text("Write Introduction")),
              ),
              Container(
                height: 50,
                color: Colors.grey[400],
                child: const Center(child: Text("Write Module")),
              ),
            ],
            ),
            SizedBox(
                height: 50,
                width: 200,
                child: Divider(
                    color: Colors.teal.shade700
                )
            ),
            Text(
              "Use Sections as Template",
              style: TextStyle(
                fontSize:20.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter template name"
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
                height: 20,
                width: 200,
            ),
            RaisedButton(
              onPressed: (){},
              textColor: Colors.white,
              padding: const EdgeInsets.all(0.0),
              child: Text("Finish", style: TextStyle(fontSize: 20))
            )
          ]
        )
      ),
    );
  }
}

class PersonalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[200],
      appBar: AppBar(
        title: Text("My profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Column (
              children: [
                SizedBox(
                  height: 20,
                  width: 200,
                ),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("images/icons8-user-96.png"),
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "My tasks",
                      style: TextStyle(
                          fontSize:20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                ListView(
                  padding: const EdgeInsets.all(8),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: <Widget>[
                    Container(
                      height: 50,
                      color: Colors.grey[400],
                      child: const Center(child: Text("Research")),
                    ),
                    Container(
                      height: 50,
                      color: Colors.grey[500],
                      child: const Center(child: Text("Write Introduction")),
                    ),
                    Container(
                      height: 50,
                      color: Colors.grey[400],
                      child: const Center(child: Text("Write Module")),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Your friends",
                      style: TextStyle(
                          fontSize:20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage("images/icons8-peter-the-great-96.png"),
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage("images/icons8-princess-96.png"),
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage("images/icons8-user-100.png"),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Your progress",
                      style: TextStyle(
                          fontSize:20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Image(
                  image: AssetImage("images/graph.png"),
                ),
              ]
          )
      ),
    );
  }
}
