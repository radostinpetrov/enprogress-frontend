import 'dart:convert';

import 'package:EnProgress/page_widgets/TasksPage.dart';
import 'package:EnProgress/page_widgets/WorkModePage.dart';
import 'package:EnProgress/page_widgets/friend_page_widgets/FriendsPage.dart';
import 'package:EnProgress/top_level/Globals.dart';
import 'package:EnProgress/user/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

User user;
String _email = " ";
String _password = " ";
String _username = " ";
int userID = -1;

Future<dynamic> _getUserInfo() async {
  try {
    Uri uri = Uri.parse(Globals.serverIP + "users?email=" + user.firebaseUser.email
        .toString());
    Response resp = await Client().get(uri);
    Map<String, dynamic> jsonResp = json.decode(resp.body).elementAt(0);
    _username = jsonResp['name'];
    userID = jsonResp['id'];
    user = User(_username, userID, user.firebaseUser);
  } catch (e) {
    print(e);
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {

//        if (snapshot.hasData) {
//          return HomePage(snapshot.data.)
//        } else {
//          return LoginPage();
//        }

        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data == null) {
            return SignInPage();
          }
          user = User(_username, userID, snapshot.data);
          return HomePage(user);
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

    Map<String, dynamic> body = {'name': _username, 'email': "moe@moe.com"};
    Response resp =
        await Client().post(uri, headers: headers, body: json.encode(body));
    userID = json.decode(resp.body)['id'];
  }

  Future<void> _signInWithEmail() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: "moe@moe.com", password: _password);
      await _getUserInfo();
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
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
              child: Column(
                children: [
                  TextFormField(
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
                  TextFormField(
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
                  TextFormField(
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
                ],
              )
            ),
            Column(
              children: [
                RaisedButton(
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
                RaisedButton(
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
              ],
            ),
          ],
        )
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  User _user;

  HomePage(User user) {
    this._user = user;
  }

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  int _currentIndex = 1;

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
    return BottomNavigationBar(
      backgroundColor: _currentIndex != 2 ? Globals.primaryBlue : Colors.amber,
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.blue,
      onTap: _onNavBarTapped,
      currentIndex: _currentIndex,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            title: Text("Friends"),
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            title: Text("Tasks")
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            title: Text("Study")
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    BottomNavigationBar bottomNavigationBar = _bottomNavigationBar();

    return FutureBuilder<dynamic>(
      future: _getUserInfo(),
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
