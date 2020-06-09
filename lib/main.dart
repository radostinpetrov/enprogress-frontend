import 'package:drp29/page_widgets/ArchivePage.dart';
import 'package:drp29/page_widgets/TasksPage.dart';
import 'package:drp29/page_widgets/friend_page_widgets/FriendsPage.dart';
import 'package:drp29/user/User.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'page_widgets/WorkModePage.dart';
import 'package:drp29/Globals.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final User user = new User(username: "test");
  final Client client = new Client();
  final uri = Uri.parse("http://146.169.40.203:3000/tasks");

  Future<String> _getTasks() async {
    Response response = await client.get(uri);
    String jsonResponse = response.body;
    return jsonResponse;
  }

  @override
  Widget build(BuildContext context) {
    Future<String> data = _getTasks();

    return MaterialApp(
      title: "EnProgress",
      theme: Globals.theme,
      home: PageView(
        allowImplicitScrolling: false,
        controller: PageController(
          initialPage: 1,
        ),
        children: [
          FriendsPage(),
          TasksPage(data: data,),
          ArchivePage(data: data,),
          WorkModePage(),
        ],
      ),
    );
  }
}
