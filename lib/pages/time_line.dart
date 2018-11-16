import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'dart:math';
//import 'package:flutter_google_apis_test/models/main_model.dart';
//import 'package:scoped_model/scoped_model.dart';
//import 'package:flutter_google_apis_test/app_drive_api/v3.dart' as drive;
//import 'package:flutter_google_apis_test/widgets/time_unit.dart';
//import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';

class TimeLinePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TimeLineState();
}

class TimeLineState extends State<TimeLinePage> with TickerProviderStateMixin {
  // TODO Each tabview should show three hours, one day, one week, or one month
  // TODO Scrolling left or right should decrement or increment that range.
  // TODO Maybe not dynamic! Always three tables: Past, Now, Future ... YES!!!
  // TODO The titles and content are changed instead of adding tabs.
  // TODO but we don't actually want the tab to change.
  // TODO Maybe I just need to detect swipes to the side? That would be a GestureDetector.

  DateTime dateTime;
//  Map<String, DateTime> dateMap = Map();
  var formatter;

  PageController pageController;
  //List<DateTime> dateRange;
  int curIndex;
  int initialIndex = 111111;

//  void _addDay() {
//    setState(() {
//      dateTime = dateTime.add(Duration(days: 1));
//    });
//  }
//
//  void _subtractDay() {
//    setState(() {
//      dateTime = dateTime.subtract(Duration(days: 1));
//    });
//  }

//  TabController _tc;
//
//  List<Map<String, dynamic>> _tabs = [];
//  List<String> _views = [];
//
//  TabController _makeNewTabController() => TabController(
//        vsync: this,
//        length: _tabs.length,
//        initialIndex: _tabs.length - 1,
//      );
//
//  void _addTab() {
//    setState(() {
//      _tabs.add({
//        'icon': Icons.star,
//        'text': "Tab ${_tabs.length + 1}",
//      });
//      _views.add("Tab ${_tabs.length}'s view");
//      _tc = _makeNewTabController();
//    });
//  }
//
//  void _removeTab() {
//    setState(() {
//      _tabs.removeLast();
//      _views.removeLast();
//      _tc = _makeNewTabController();
//    });
//  }

//  void _assignDateRange() {
//    dateRange[0] = dateTime.subtract(Duration(days: 4));
//    dateRange[1] = dateTime.subtract(Duration(days: 3));
//    dateRange[2] = dateTime.subtract(Duration(days: 2));
//    dateRange[3] = dateTime.subtract(Duration(days: 1));
//    dateRange[4] = dateTime;
//    dateRange[5] = dateTime.add(Duration(days: 1));
//    dateRange[6] = dateTime.add(Duration(days: 2));
//    dateRange[7] = dateTime.add(Duration(days: 3));
//    dateRange[8] = dateTime.add(Duration(days: 4));
//  }

  @override
  void initState() {
    super.initState();
    formatter = new DateFormat('yMEd');
    //this._addTab();
    dateTime = DateTime.now();
    //dateRange = List(9);
    //_assignDateRange();
    pageController = PageController(initialPage: initialIndex);
    curIndex = initialIndex;
  }

//  Widget _itemBuilder(Color color, int index) {
//    return Opacity(
//      opacity: index.toDouble() / 10,
//      child: Container(
//        color: color,
//        width: 100,
//        height: 100,
//      ),
//    );
//  }

//  Widget _buildRow(int rowIndex) {
//    Color color = Colors.black;
//    switch (rowIndex) {
//      case 0:
//        color = Colors.purple;
//        break;
//      case 1:
//        color = Colors.cyan;
//        break;
//      case 2:
//        color = Colors.deepOrange;
//        break;
//      case 3:
//        color = Colors.green;
//        break;
//      case 4:
//        color = Colors.pink;
//        break;
//      case 5:
//        color = Colors.amber;
//        break;
//      case 6:
//        color = Colors.lightBlue;
//        break;
//      case 7:
//        color = Colors.brown;
//        break;
//      case 8:
//        color = Colors.lightGreen;
//        break;
//      case 9:
//        color = Colors.lime;
//        break;
//    }
//    return ListView.builder(
//      scrollDirection: Axis.horizontal,
//      itemCount: 10,
//      itemBuilder: (BuildContext context, int index) {
//        _itemBuilder(color, index);
//      },
//    );
//  }

//  Widget _buildVerticalListView() {
//    return ListView.builder(
//      scrollDirection: Axis.vertical,
//      itemCount: 10,
//      itemBuilder: (BuildContext context, int index) {
//        _buildRow(index);
//      },
//    );
//  }

  void _setCurIndex(int index) {
    setState(() {
      curIndex = index;
    });
  }

  String _setAppBarText() {
    int actualIndex = curIndex - initialIndex;
    return formatter.format(dateTime.add(Duration(days: actualIndex)));
  }

  @override
  Widget build(BuildContext context) {
    //dateTime = DateTime.now();
    String formattedDate = formatter.format(dateTime);
    return Scaffold(
        appBar: AppBar(
          title: Text("Dynamic days"),
//        actions: <Widget>[
//          IconButton(icon: Icon(Icons.add), onPressed: this._addTab),
//          IconButton(icon: Icon(Icons.remove), onPressed: this._removeTab),
//        ],
          bottom: AppBar(
              leading: Text(''),
              title: Text(
                _setAppBarText(), //dateTime.toIso8601String(),
              )),
        ),
        body: PageView.builder(
            controller: pageController,
            //itemCount: 9,
            onPageChanged: (index) => _setCurIndex(index),
            itemBuilder: (context, index) {
              int actualIndex = index - initialIndex;
              return Center(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    formatter.format(dateTime.add(Duration(days: actualIndex))),
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              );
            }));
//        Dismissible(
//          key: Key(dateTime.toIso8601String()),
//          onDismissed: (direction) {
//            if (direction == DismissDirection.startToEnd) {
//              _subtractDay();
//            }
//            if (direction == DismissDirection.endToStart) {
//              _addDay();
//            }
//          },
//          child: Center(
//            child: Text(
//              formattedDate, //dateTime.toIso8601String(),
//              style: TextStyle(fontSize: 40),
//            ),
//          ),
//        ));
  }

//  TabBarView(
//  key: Key(Random().nextDouble().toString()),
//  controller: _tc,
//  children: _views.map((view) => Center(child: Text(view))).toList(),
//  ),
//  TabBar(
//  controller: _tc,
//  isScrollable: true,
//  tabs: _tabs
//      .map((tab) => Tab(
//  icon: Icon(tab['icon']),
//  text: tab['text'],
//  ))
//      .toList(),
//  ),
}
