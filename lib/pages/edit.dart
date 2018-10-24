import 'package:flutter/material.dart';
import 'package:flutter_google_apis_test/models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';

class EditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditState();
}

class EditState extends State<EditPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  Widget _buildNameField(MainModel model) {
    if (_nameController.text.trim() == '') {
      _nameController.text = model.metaMap[model.selectedID].name;
    }
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(labelText: 'Title'),
    );
  }

  Widget _buildContentField(MainModel model) {
    if (_contentController.text.trim() == '') {
      _contentController.text = model.contentMap[model.selectedID];
    }
    return TextField(
      controller: _contentController,
      decoration: InputDecoration(labelText: 'Title'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      String id = model.selectedID;
      return Scaffold(
        appBar: new AppBar(
          title: new Text('File Editing'),
        ),
        body: ListView(
          children: <Widget>[_buildNameField(model), _buildContentField(model)],
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            if (model.metaMap[id].name != _nameController.text &&
                model.contentMap[id] == _contentController.text) {
              model.renameFile(id, _nameController.text);
            } else if (model.metaMap[id].name != _nameController.text &&
                model.contentMap[id] != _contentController.text) {
              model.renameAndUpdateFileContents(
                  id, _nameController.text, _contentController.text);
            } else if (model.metaMap[id].name == _nameController.text &&
                model.contentMap[id] != _contentController.text) {
              model.updateFileContents(id, _contentController.text);
            }
            Navigator.pushNamed(context, '/');
          },
          child: Icon(Icons.check),
        ),
      );
    });
  }
}
