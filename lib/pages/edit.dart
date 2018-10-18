import 'package:flutter/material.dart';
import '../drive.dart';

class EditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditState();
}

class EditState extends State<EditPage> {
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
                child: TextField(
                  decoration: InputDecoration(
                      hintText: file['name'], labelText: 'Title'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  maxLines: 20,
                  decoration: InputDecoration(
                      hintText: file['content'], labelText: 'Content'),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.check),
      ),
    );
  }
}
