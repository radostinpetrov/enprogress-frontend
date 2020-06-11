import 'package:drp29/top_level/MyApp.dart';
import 'package:drp29/user/User.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart';
import 'dart:convert';

class CreateTaskPage extends StatefulWidget {
  User user;

  CreateTaskPage(User user) {
    this.user = user;
  }

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  var _dateTime;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<String> data = [];
  final nameController = TextEditingController();
  final progressController = TextEditingController();
  bool error = false;
  Color submitColor = Colors.amber;

  Widget _buildItem(String item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        title: Text(
          item,
          style: TextStyle(fontSize: 15),
        ),
        trailing: IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              _removeItem(item);
              updateSubmitColor('');
            }),
      ),
    );
  }

  void _removeItem(String item) {
    int index = data.indexOf(item);
    if (index >= 0) {
      data.removeAt(index);
      AnimatedListRemovedItemBuilder builder = (context, animation) {
        return _buildItem(item, animation);
      };
      _listKey.currentState.removeItem(index, builder);
    }
  }

  void _insertItem() {
    String item = progressController.text;
    if (item.length > 0) {
      data.insert(0, item);
      _listKey.currentState.insertItem(0);
      progressController.clear();
      updateSubmitColor('');
    }
  }

  bool conditions() {
    return (_dateTime != null) &&
        (nameController.text.length > 0) &&
        (data.length > 0);
  }

  void updateSubmitColor(String s) {
    setState(() {
      submitColor = conditions() ? Colors.green : Colors.amber;
    });
  }

  _makePostRequest() async {
    String url = "http://146.169.40.203:3000/tasks";
    var subTaskPercentages = [];

    for (int i = 0; i < data.length; i++) {
      subTaskPercentages.add(0);
    }

    String text = nameController.text;
    String name = text.substring(0, text.length);

    var deadline = _dateTime;


    Map<String, String> headers = {"Content-type": "application/json"};
    Map<String,dynamic> body = {'name' : name, 'percentage' : 0,
      'deadline' : deadline, 'fk_user_id' : widget.user.userID, 'subtasks' : data, 'subtaskPercentages' :
      subTaskPercentages};

    Response resp = await post(url,headers: headers,body: json.encode(body));
    print(resp.body);

  }

  @override
  Widget build(BuildContext context) {
    Widget titleSection = Center(
        child: Container(
          height: 75,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.keyboard_arrow_left),
                color: Colors.white,
                alignment: Alignment.centerLeft,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder:
                      (context) => MyApp()));
                },
              ),
              Spacer(flex: 13,),
              Text(
                'Creating A New Task',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(flex: 24,),
            ],
          ),
        )
    );

    Widget dateAndName = Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white70,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.red,
                offset: Offset(10, 10),
                blurRadius: 20,
              )
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
            'Name of Task',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          TextField(
            controller: nameController,
            textAlign: TextAlign.center,
            onChanged: updateSubmitColor,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'Enter Here',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _dateTime == null
                    ? 'Tap to Select Deadline'
                    : 'Selected '
                    'Deadline: '
                    '$_dateTime',
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2021),
                    ).then((date) {
                      setState(() {
                        _dateTime = DateFormat('yyyy-MM-dd').format(date);
                        updateSubmitColor('');
                      });
                    });
                  })
            ],
          ),
        ]));

    Widget subGoals = Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white70,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(25.0),
                bottomLeft: Radius.circular(25.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.red,
                offset: Offset(-10, 10),
                blurRadius: 20,
              )
            ]),
        child: Column(children: [
          Text(
            'Add Progress Measures',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: TextField(
                    controller: progressController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: 'Enter Here',
                    ),
                  )),
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _insertItem();
                  })
            ],
          ),
          Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: AnimatedList(
                key: _listKey,
                initialItemCount: 0,
                itemBuilder: (context, index, animation) {
                  return _buildItem(data[index], animation);
                },
              )),
        ]));

    Widget submit = InkWell(
      child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  bottomRight: Radius.circular(25.0)),
              boxShadow: [
                BoxShadow(
                  color: submitColor, // (conditions() ? Colors.green :
                  // Colors.amber)
                  offset: Offset(10, 10),
                  blurRadius: 20,
                )
              ]),
          child: Text(
            'Create Task',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          )),
      onTap: () {
        if (conditions()) {
          _makePostRequest();
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              MyApp()));
        } else {
          setState(() {
            error = true;
          });
        }
      },
    );

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xFF1D1C4D),
        body: SafeArea(
            child: Column(children: [
              titleSection,
              dateAndName,
              SizedBox(height: 10),
              subGoals,
              SizedBox(height: 10),
              submit,
              SizedBox(height: 10),
              Visibility(
                  visible: error,
                  child: Text('Please fill out all fields!',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      )))
            ])));
  }
}
