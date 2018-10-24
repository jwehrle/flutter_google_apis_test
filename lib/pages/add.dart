import 'package:flutter/material.dart';
import 'package:flutter_google_apis_test/models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';

class AddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddState();
}

class AddState extends State<AddPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: new AppBar(
          title: new Text('Add A File'),
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
            model.addFile(titleController.text, contentController.text);
            Navigator.pushNamed(context, '/');
          },
          child: Icon(Icons.check),
        ),
      );
    });
  }
}
