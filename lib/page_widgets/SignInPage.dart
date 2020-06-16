import 'dart:convert';

import 'package:EnProgress/page_widgets/TasksPage.dart';
import 'package:EnProgress/page_widgets/WorkModePage.dart';
import 'package:EnProgress/page_widgets/friend_page_widgets/FriendsPage.dart';
import 'package:EnProgress/top_level/Globals.dart';
import 'package:EnProgress/user/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:EnProgress/utilities.dart';

import 'package:rflutter_alert/rflutter_alert.dart';

User user;
String _email = " ";
String _password = " ";
String _username = " ";
int userID = -1;

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

String FCMToken = "";

class LandingPage extends StatefulWidget {
  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  final Client client = Client();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        String payload = message['data']['payload'].toString();
        print("onMessageeeeeeeee: ${message['data']['payload']}");
        print("yeet");
        showNotification(message['notification']['title'],
            message['notification']['body'], message['data']['payload']);

        // TODO: REMOVE IF CANCLLED
        if (payload.startsWith("Accepted:")) {
          int _requestID = int.parse(payload.substring(9));
          // Get workmoderequest from DB
          WorkModeRequest workModeRequest =
              await getWorkModeRequest(_requestID);
          scheduledWorkModeNotification(_requestID, workModeRequest);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    // Code for local notification initialization
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    if (payload.startsWith('WorkModeRequest:')) {
      int _requestID = int.parse(payload.substring(16));
      Alert(
          context: context,
          image: Image.asset('images/icons8-study-100.png'),
          title: 'Work Mode Request',
          desc:
              'You have received a work mode request from [USERNAME]. Would you like to study together?',
          buttons: [
            DialogButton(
              onPressed: () async {
                await acceptWorkModeRequest(_requestID);
                Navigator.pop(context, true);
              },
              child: Text(
                "Accept",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              color: Colors.green,
            ),
            DialogButton(
              onPressed: () async {
                await refuseWorkModeRequest(_requestID);
                Navigator.pop(context, false);
              },
              child: Text(
                "Refuse",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              color: Colors.red,
            )
          ]).show();
    } else if (payload.startsWith("Started:")) {
      int _requestID = int.parse(payload.substring(8));
      WorkModeRequest workModeRequest = await getWorkModeRequest(_requestID);

      // Calculate remaining time and set up work mode
      int remainingTime = workModeRequest.duration -
          ((DateTime.now().millisecondsSinceEpoch -
                      workModeRequest.start_time.millisecondsSinceEpoch) /
                  1000)
              .round();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WorkModePage(
                  data: null,
                  user: user,
                  subtasks: null,
                  remainingTime: remainingTime)));
    } else {
      print("goofed it");
    }
  }

  Future acceptWorkModeRequest(int requestID) async {
    // Get workmoderequest from DB
    WorkModeRequest workModeRequest = await getWorkModeRequest(requestID);

    // Send confirmation to sender
    String senderToken =
        await Utilities.getFCMTokenByID(workModeRequest.fk_sender_id);
    await Utilities.sendFcmMessage(
        user.username + ' has accepted your request to work together',
        'A notification will remind you of your study session',
        senderToken,
        'Accepted:' + requestID.toString());

    // Create scheduled notification
    scheduledWorkModeNotification(requestID, workModeRequest);
  }

  Future<WorkModeRequest> getWorkModeRequest(int requestID) async {
//    print("over hyaaaaa");
    Uri uri = Uri.parse(
        'https://enprogressbackend.herokuapp.com/workmoderequests/' +
            requestID.toString());
    Response response = await client.get(uri);
//    print("yoop " + response.body);
    var data = json.decode(response.body)[0];
    return WorkModeRequest(data['fk_sender_id'], data['fk_recipient_id'],
        DateTime.parse(data['start_time']), data['duration']);
  }

  Future refuseWorkModeRequest(int requestID) async {
    // Get workmoderequest from DB
    WorkModeRequest workModeRequest = await getWorkModeRequest(requestID);

    // Send refusal to sender
    String senderToken =
        await Utilities.getFCMTokenByID(workModeRequest.fk_sender_id);
    await Utilities.sendFcmMessage(
        user.username + ' has refused your request to work together',
        'Unfortunately they are busy, try again a different time!',
        senderToken,
        'Refused:' + requestID.toString());
  }

  // TODO: CREATE GET USER INFO FUNCTION!!
  Future scheduledWorkModeNotification(
      int requestID, WorkModeRequest workModeRequest) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'second channel ID', 'second Channel title', 'second channel body',
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.schedule(
        1,
        'It\'s time to work!',
        '[USERNAME] is waiting for you, join them now!',
        workModeRequest.start_time.add(Duration(hours: 1)),
        notificationDetails,
        payload: "Started:" + requestID.toString());
  }

  Future showNotification(String title, String body, String payload) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data == null) {
            return SignInPage();
          }
          user = User(_username, userID, snapshot.data);
          return HomePage();
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  _makePostRequest() async {
    final Uri uri = Uri.parse(Globals.serverIP + "users");

    Map<String, String> headers = {"Content-type": "application/json"};

    Map<String, dynamic> body = {'name': _username, 'email': _email};
    Response resp =
        await Client().post(uri, headers: headers, body: json.encode(body));
    userID = json.decode(resp.body)['id'];
  }

  Future<void> _signInWithEmail() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      await _setUserInfo();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  Future<void> _registerWithEmail() async {
    try {
      await _makePostRequest();
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  TextEditingController _usernamecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign in')),
      resizeToAvoidBottomPadding: false,
      body: Center(
        child: Column(
          children: [
//          RaisedButton(
//            child: Text(
//              'Sign in anonymously',
//              style: TextStyle(fontSize: 20.0, color: Colors.white),
//            ),
//            onPressed: _signInAnonymously,
//          ),
            Spacer(flex: 10,),
            Expanded(
              flex: 6,
              child: TextFormField(
                controller: _usernamecontroller,
                maxLines: 1,
                keyboardType: TextInputType.text,
                autofocus: true,
                autovalidate: true,
                decoration: InputDecoration(
                    hintText: 'Username',
                    icon: Icon(
                      Icons.supervised_user_circle,
                      color: Colors.grey,
                    )),
                validator: (value) =>
                value.isEmpty ? 'Username can\'t be empty' : null,
                onSaved: (String value) {
                  _username = value.trim();
                },
              ),
            ),
            Expanded(
              flex: 6,
              child: TextFormField(
                controller: _emailcontroller,
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                autovalidate: true,
                decoration: InputDecoration(
                    hintText: 'Email',
                    icon: Icon(
                      Icons.mail,
                      color: Colors.grey,
                    )),
                validator: (value) =>
                value.isEmpty ? 'Email can\'t be empty' : null,
                onSaved: (String value) {
                  _email = value.trim();
                },
              ),
            ),
            Expanded(
              flex: 6,
              child: TextFormField(
                controller: _passwordcontroller,
                maxLines: 1,
                obscureText: true,
                autofocus: true,
                autovalidate: true,
                decoration: InputDecoration(
                    hintText: 'Password',
                    icon: Icon(
                      Icons.lock,
                      color: Colors.grey,
                    )),
                validator: (value) =>
                value.isEmpty ? 'Password can\'t be empty' : null,
                onSaved: (value) => _password = value.trim(),
              ),
            ),
            Spacer(flex: 2,),
            Expanded(
              flex: 4,
              child: RaisedButton(
                child: Text(
                  'Sign in with email',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                onPressed: () {
                  _username = _usernamecontroller.text.toString();
                  _email = _emailcontroller.text.toString();
                  _password = _passwordcontroller.text.toString();
                  _signInWithEmail();
                },
              ),
            ),
            Spacer(flex: 2,),
            Expanded(
              flex: 4,
              child: RaisedButton(
                child: Text(
                  'Register with email',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                onPressed: () {
                  _username = _usernamecontroller.text.toString();
                  _email = _emailcontroller.text.toString();
                  _password = _passwordcontroller.text.toString();
                  _registerWithEmail();
                },
              ),
            ),
            Spacer(flex: 15,)
          ],
        )
      ),
    );
  }
}

class HomePage extends StatefulWidget {

  @override
  HomePageState createState() => HomePageState();
}

Future<dynamic> _setUserInfo() async {
  try {
    // Get user info (username, id)
    Uri uri = Uri.parse("https://enprogressbackend.herokuapp.com/users?email=" +
        user.firebaseUser.email.toString());
    final Client client = Client();
    Response resp = await client.get(uri);
    Map<String, dynamic> jsonResp = json.decode(resp.body).elementAt(0);
    _username = jsonResp['name'];
    userID = jsonResp['id'];
    user = User(_username, userID, user.firebaseUser);

    // Update user fcm_token
    FCMToken = await _firebaseMessaging.getToken();
    Map<String, String> headers = {"Content-type": "application/json"};
    Map<String, dynamic> body = {'fcm_token': FCMToken};
    uri = Uri.parse(
        "https://enprogressbackend.herokuapp.com/users/" + userID.toString());
    Response response =
        await client.patch(uri, headers: headers, body: jsonEncode(body));
//    print(response.body);
  } catch (e) {
    print(e);
  }
}

class HomePageState extends State<HomePage> {

  int _currentIndex = 1;
  Future<dynamic> userInfo;

  HomePageState() {
    this.userInfo = _getUserInfo();
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }


  /// *     Widgets   ***/

  BottomNavigationBar _bottomNavigationBar() {

    TextStyle navTextStyle = TextStyle(
      color: Colors.white,
      letterSpacing: 2.5,
    );

    return BottomNavigationBar(
      backgroundColor: _currentIndex != 2 ? Globals.primaryBlue : Colors.amber,
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.blue,
      onTap: _onNavBarTapped,
      currentIndex: _currentIndex,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            title: Text("Friends", style: navTextStyle,),
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            title: Text("Tasks", style: navTextStyle,)
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            title: Text("Study", style: navTextStyle,)
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    BottomNavigationBar bottomNavigationBar = _bottomNavigationBar();

    return FutureBuilder<dynamic>(
      future: userInfo,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        switch (snapshot.connectionState) {
          case(ConnectionState.none):
            return new Text("Not active");
          case(ConnectionState.waiting):
            return Scaffold(
              backgroundColor: Globals.primaryBlue,
              bottomNavigationBar: bottomNavigationBar,
              body: SafeArea(
                child: Center(
                  child: Globals.loadingWidget
                )
              ),
            );
          case(ConnectionState.active):
            return new Text("Active");
          default:
            if (snapshot.hasError)
              return new Text("An error occurred while connecting to the server :(",
                textAlign: TextAlign.center,);
            else {
              List<Widget> children = [
                FriendsPage(user: user),
                TasksPage(user: user, signoutCallback: _signOut),
                WorkModePage(user: user),
              ];

              return Scaffold(
                bottomNavigationBar: bottomNavigationBar,
                backgroundColor: _currentIndex != 2 ? Globals.primaryBlue : Colors.amber,
                body: SafeArea(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 100,
                        child: children[_currentIndex],
                      ),
                      Expanded(
                        flex: 1,
                        child: Divider(
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
        }
      },
    );
  }
}
