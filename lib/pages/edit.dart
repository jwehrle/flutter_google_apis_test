import 'package:flutter/material.dart';
import 'package:flutter_google_apis_test/models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';

class EditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditState();
}

class EditState extends State<EditPage> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      String id = model.selectedID;
      TextEditingController nameController =
          TextEditingController(text: model.metaMap[id].name);
      TextEditingController contentController =
          TextEditingController(text: model.contentMap[id]);
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
            if (model.metaMap[id].name != nameController.text &&
                model.contentMap[id] == contentController.text) {
              model.renameFile(id, nameController.text);
            } else if (model.metaMap[id].name != nameController.text &&
                model.contentMap[id] != contentController.text) {
              model.renameAndUpdateFileContents(
                  id, nameController.text, contentController.text);
            } else if (model.metaMap[id].name == nameController.text &&
                model.contentMap[id] != contentController.text) {
              model.updateFileContents(id, contentController.text);
            }
            Navigator.pushNamed(context, '/');
          },
          child: Icon(Icons.check),
        ),
      );
    });
  }
}
