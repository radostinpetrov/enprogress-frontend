import 'dart:convert';
import 'package:EnProgress/top_level/Globals.dart';
import 'package:EnProgress/user/User.dart';
import 'package:EnProgress/widgets/FriendWidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class FriendsPage extends StatefulWidget {

  final User user;

  FriendsPage({
    @required this.user,
  });

  @override
  FriendsPageState createState() => FriendsPageState(user: user);
}

class FriendsPageState extends State<FriendsPage> {
  final Client client = new Client();
  final uri = Uri.parse(Globals.serverIP + "users");
  TextEditingController addFriend = TextEditingController();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  String friends;
  User user;

  FriendsPageState({
    @required this.user,
  });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  Future<String> _getNumberOfFriends() async {
    Response response = await client.get(uri);
    String jsonResponse = response.body;
    return jsonResponse;
  }

  Future<Null> _refresh() {
    return _getNumberOfFriends().then((_friends) {
      setState(() => friends = _friends);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF1D1C4D),
        body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refresh,
            child: SafeArea(
                child: Column(children: <Widget>[
              Spacer(flex: 2),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FittedBox(fit: BoxFit.fitWidth,
                        child: Text(
                          "Friends LeaderBoard",
                          style: Theme.of(context).textTheme.headline1,
                        )
                    ),
                  ],
                ),
              ),
              Spacer(flex: 1),
              Expanded(
                flex: 30,
                child: FutureBuilder<String>(
                  future: _getNumberOfFriends(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    switch (snapshot.connectionState) {
                      case (ConnectionState.none):
                        return new Text("Not active");
                      case (ConnectionState.waiting):
                        return new Text("Loading...");
                      case (ConnectionState.active):
                        return new Text("Active");
                      default:
                        if (snapshot.hasError)
                          return new Text("Error");
                        else {
                          List<dynamic> decoded = jsonDecode(snapshot.data);

                          decoded.sort((a, b) => b['points'].compareTo
                            (a['points']));

                          return new ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (_, index) {
                              return FriendWidget(
                                index: index,
                                points: decoded[index]['points'],
                                id: decoded[index]['id'],
                                title: decoded[index].values.toList()[1],
                              );
                            },
                            separatorBuilder: (_, index) => Divider(),
                            itemCount: decoded.length,
                          );
                        }
                    }
                  },
                ),
              ),
              Spacer(flex: 5),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: addFriend,
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          hintText: "Enter Friend's Name Here",
                          hintStyle: TextStyle(color: Colors.white)),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      _makePostRequest();
                      addFriend.clear();
                    },
                  )
                ],
              )
            ]))));
  }

  _makePostRequest() async {
    String url = Globals.serverIP + "users";

    String text = addFriend.text;
    String name = text.substring(0, text.length);

    Map<String, String> headers = {"Content-type": "application/json"};
    Map<String, dynamic> body = {'name': name, 'email': 'example@abc.com'};

    Response resp = await post(url, headers: headers, body: json.encode(body));
  }
}
