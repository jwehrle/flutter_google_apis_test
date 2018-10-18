import 'package:flutter/material.dart';
import '../blocProvider.dart';

class DetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DetailState();
}

class DetailState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    Map<String, String> file = DriveBloc.of(context).getSelected();
    return Scaffold(
      appBar: new AppBar(
        title: new Text('File Details'),
      ),
      body: Container(
        constraints: BoxConstraints.expand(width: double.maxFinite),
        child: Padding(
          padding: EdgeInsets.all(18.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  file['name'],
                  style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  file['content'],
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/edit');
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}
