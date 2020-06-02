import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateTaskPage extends StatefulWidget {
  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  var _dateTime;

  @override
  Widget build(BuildContext context) {
    Widget titleSection = Center(
        child: Container(
            height: 75,
            padding: const EdgeInsets.all(10),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                'Creating A New Task',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            ])));

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
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          TextField(
            textAlign: TextAlign.center,
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
                        _dateTime = DateFormat('d-MM-yyyy').format(date);
                      });
                    });
                  })
            ],
          ),
        ]));

    Widget subGoals = Container(
      height: 100,
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
    );

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xFF1D1C4D),
        body: SafeArea(
            child: Column(children: [
          titleSection,
          dateAndName,
          SizedBox(height: 10),
          subGoals
        ])));
  }
}
