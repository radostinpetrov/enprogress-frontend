import 'package:drp29/page_widgets/ArchivePage.dart';
import 'package:drp29/page_widgets/TasksPage.dart';
import 'package:drp29/page_widgets/WorkModePage.dart';
import 'package:drp29/page_widgets/friend_page_widgets/FriendsPage.dart';
import 'package:drp29/top_level/Globals.dart';
import 'package:drp29/user/User.dart';
import 'package:drp29/widgets/FloatingButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';


User user;

class LandingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User user = User("name", 0, snapshot.data);
          if (user == null) {
            return SignInPage();
          }
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

  Future<void> _signInWithEmail() async {
    print(_email);
    print(_password);
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  Future<void> _registerWithEmail() async {
    print(_email);
    print(_password);
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  String _email = " ";
  String _password = " ";

  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign in')),
      body: Center(
          child: Column(
        children: [
          RaisedButton(
            child: Text(
              'Sign in anonymously',
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
            onPressed: _signInAnonymously,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
            child: new TextFormField(
              controller: _emailcontroller,
              maxLines: 1,
              keyboardType: TextInputType.emailAddress,
              autofocus: false,
              autovalidate: true,
              decoration: new InputDecoration(
                  hintText: 'Email',
                  icon: new Icon(
                    Icons.mail,
                    color: Colors.grey,
                  )),
              validator: (value) =>
                  value.isEmpty ? 'Email can\'t be empty' : null,
              onSaved: (String value) {
                print("here");
                _email = value.trim();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
            child: new TextFormField(
              controller: _passwordcontroller,
              maxLines: 1,
              obscureText: true,
              autofocus: false,
              autovalidate: true,
              decoration: new InputDecoration(
                  hintText: 'Password',
                  icon: new Icon(
                    Icons.lock,
                    color: Colors.grey,
                  )),
              validator: (value) =>
                  value.isEmpty ? 'Password can\'t be empty' : null,
              onSaved: (value) => _password = value.trim(),
            ),
          ),
          Column(
            children: [
              RaisedButton(
                child: Text(
                  'Sign in with email',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                onPressed: () {
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
                  _email = _emailcontroller.text.toString();
                  _password = _passwordcontroller.text.toString();
                  _registerWithEmail();
                },
              ),
            ],
          ),
        ],
      )),
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
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  final uri = Uri.parse("http://146.169.40.203:3000/tasks");
  final Client client = new Client();

  Future<String> _getTasks() async {
    Response response = await client.get(uri);
    String jsonResponse = response.body;
    return jsonResponse;
  }

  @override
  Widget build(BuildContext context) {
    Future<String> data = _getTasks();
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            onPressed: _signOut,
          ),
        ],
      ),
      backgroundColor: Globals.primaryBlue,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingButton(),
      ),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 100,
                child: PageView(
                  allowImplicitScrolling: false,
                  controller: PageController(
                    initialPage: 1,
                  ),
                  children: [
                    FriendsPage(),
                    TasksPage(data: data, user: user),
                    ArchivePage(data: data,),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: <Widget>[],
                ),
              ),
            ],
          )
      ),
    );
  }
}
