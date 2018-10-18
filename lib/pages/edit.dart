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
    TextEditingController nameController =
        TextEditingController(text: file[Drive.NAME]);
    TextEditingController contentController =
        TextEditingController(text: file[Drive.CONTENT]);
    return Scaffold(
      appBar: new AppBar(
        title: new Text('File Editing'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: nameController,
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
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          if (file[Drive.NAME] != nameController.text) {
            file[Drive.NAME] = nameController.text;
            file[Drive.CONTENT] = contentController.text;
            Drive.of(context).rename(file);
          } else if (file[Drive.CONTENT] != contentController.text) {
            file[Drive.NAME] = nameController.text;
            file[Drive.CONTENT] = contentController.text;
            Drive.of(context).updateFile(file);
          }
          Navigator.pushNamed(context, '/');
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
