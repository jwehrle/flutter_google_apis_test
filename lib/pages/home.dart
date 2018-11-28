import 'package:flutter/material.dart';
import 'package:flutter_google_apis_test/states/home_state.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  HomePageState createState() => HomePageState();
}
