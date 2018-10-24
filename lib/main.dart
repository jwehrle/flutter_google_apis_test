import 'package:flutter/material.dart';
import 'package:flutter_google_apis_test/models/main_model.dart';
//import 'package:googleapis/drive/v3.dart';
import './pages/home.dart';
import './pages/detail.dart';
import './pages/edit.dart';
import './pages/add.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  MainModel _model = MainModel();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        title: 'Drive Test',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/': (context) => HomePage(),
          '/detail': (context) => DetailPage(),
          '/edit': (context) => EditPage(),
          '/add': (context) => AddPage()
        },
      ),
    );
  }
}
