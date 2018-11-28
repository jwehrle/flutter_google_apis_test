import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_google_apis_test/pages/time_line.dart';

class TimeLineState extends State<TimeLinePage> with TickerProviderStateMixin {
  static const int SECONDS = 0;
  static const int MINUTES = 1;
  static const int HOURS = 2;
  static const int DAYS = 3;

  DateTime dateTime;
  var formatter;
  PageController pageController;
  int curIndex;
  int initialIndex = 111111;
  int scale;

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
    pageController = PageController(initialPage: initialIndex);
    curIndex = initialIndex;
    scale = SECONDS;
    _setScale(scale);
  }

  void _setScale(int timeScale) {
    switch (timeScale) {
      case SECONDS:
        setState(() {
          formatter = DateFormat.yMEd().add_jms();
          Timer.periodic(Duration(seconds: 1), _onTic);
        });
        break;
      case MINUTES:
        setState(() {
          formatter = DateFormat.yMEd().add_jm();
          Timer.periodic(Duration(minutes: 1), _onTic);
        });
        break;
      case HOURS:
        setState(() {
          formatter = DateFormat.yMEd().add_j();
          Timer.periodic(Duration(hours: 1), _onTic);
        });
        break;
      case DAYS:
        setState(() {
          formatter = DateFormat.yMEd();
          Timer.periodic(Duration(days: 1), _onTic);
        });
        break;
    }
  }

  void _onTic(Timer timer) {
    setState(() {
      dateTime = DateTime.now();
    });
  }

  void _incrementScale() {
    if (scale == DAYS) {
      return;
    }
    scale += 1;
    _setScale(scale);
  }

  void _decrementScale() {
    if (scale == SECONDS) {
      return;
    }
    scale -= 1;
    _setScale(scale);
  }

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Dynamic days"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: _incrementScale),
          IconButton(icon: Icon(Icons.remove), onPressed: _decrementScale),
        ],
        bottom: AppBar(
            leading: Text(''),
            title: Text(
              _setAppBarText(),
            )),
      ),
      body: PageView.builder(
          controller: pageController,
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
          }),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.purpleAccent,
          child: Icon(Icons.map),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return Opacity(
                          opacity: index.toDouble() / 10,
                          child: Container(
                            color: Colors.deepPurple,
                            height: 100,
                            width: 100,
                          ),
                        );
                      });
                });
          }),
    );
  }
}
