import 'package:flutter/material.dart';
import '../drive.dart';

class DetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DetailState();
}

class DetailState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    Map<String, String> file = Drive.of(context).getSelected();
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
                  file[Drive.NAME],
                  style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  file[Drive.CONTENT],
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
