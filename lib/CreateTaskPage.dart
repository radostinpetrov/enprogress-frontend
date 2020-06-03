import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateTaskPage extends StatefulWidget {
  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  var _dateTime;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<String> data = [];
  final nameController = TextEditingController();
  final progressController = TextEditingController();

  Widget _buildItem(String item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
          title: Text(item,
        style: TextStyle(fontSize: 15),
      ),
      trailing: IconButton(
      icon: Icon(Icons.remove),
        onPressed: () {
          _removeItem(item);
        }),

      ),);
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
    }
  }

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
            controller: nameController,
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
              constraints: BoxConstraints(
                maxHeight: 200
              ),
              child: AnimatedList(
                key: _listKey,
                initialItemCount: 0,
                itemBuilder: (context, index, animation) {
                  return _buildItem(data[index], animation);
                },
              )),
        ]));

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
