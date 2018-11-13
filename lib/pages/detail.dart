import 'package:flutter/material.dart';
import 'package:flutter_google_apis_test/models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';

class DetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DetailState();
}

class DetailState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();
    MainModel model = MainModel.getInstance();
    if (!model.hasContent(model.selectedID)) {
      model.downloadFileContent(model.selectedID);
    }
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
                    name,
                    style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: content == null
                      ? Center(child: CircularProgressIndicator())
                      : Text(content, style: TextStyle(fontSize: 20)),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            Navigator.popAndPushNamed(context, '/edit');
          },
          child: Icon(Icons.edit),
        ),
      );
    });
  }
}
