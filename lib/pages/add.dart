import 'package:flutter/material.dart';
import '../drive.dart';

class AddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddState();
}

class AddState extends State<AddPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: contentController,
                  maxLines: 20,
                  decoration: InputDecoration(labelText: 'Content'),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Drive.of(context)
              .addFile(titleController.text, contentController.text);
          Navigator.pushNamed(context, '/');
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
