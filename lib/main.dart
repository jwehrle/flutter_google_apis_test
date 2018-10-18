import 'package:flutter/material.dart';
//import 'package:googleapis/drive/v3.dart';
import 'blocProvider.dart';
import './pages/home.dart';
import './pages/detail.dart';
import './pages/edit.dart';
import './pages/add.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DriveBloc(
        child: MaterialApp(
      title: 'Drive Test',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: new HomePage(title: 'Drive Test Home Page'),
      routes: {
        '/' : (context) => HomePage(),
        '/detail' : (context) => DetailPage(),
        '/edit': (context) => EditPage(),
        '/add' : (context) => AddPage()
      },
    ));
  }
}
