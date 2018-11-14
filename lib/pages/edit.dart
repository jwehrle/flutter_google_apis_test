import 'package:flutter/material.dart';
import 'package:flutter_google_apis_test/models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_google_apis_test/models/change.dart';

class EditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditState();
}

class EditState extends State<EditPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    MainModel model = MainModel.getInstance();
    String id = model.selectedID;
    _nameController.text = model.getMetaFile(id).name;
    _contentController.text = model.getFileContent(id);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      String id = model.selectedID;
      String name = model.getMetaFile(id).name;
      String content = model.getFileContent(id);
      return Scaffold(
        appBar: new AppBar(
          title: new Text('File Editing'),
        ),
        body: ListView(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
            )
          ],
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            String changeType;
            if (name == _nameController.text &&
                content == _contentController.text) {
              return;
            }
            if (name == _nameController.text &&
                content != _contentController.text) {
              changeType = Change.UPDATED;
            } else if (name != _nameController.text &&
                content == _contentController.text) {
              changeType = Change.RENAMED;
            } else {
              changeType = Change.UPDATED_AND_RENAMED;
            }
            model.updateFile(
                id, _nameController.text, _contentController.text, changeType);
            Navigator.pushNamed(context, '/');
          },
          child: Icon(Icons.check),
        ),
      );
    });
  }
}
