import 'package:flutter/material.dart';
import 'package:flutter_google_apis_test/models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';

class DetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DetailState();
}

class DetailState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      String id = model.selectedID;
      if (!model.contentMap.containsKey(id)) {
        model.getFileContent(id);
      }
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
                    model.metaMap[id].name,
                    style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: model.contentMap.containsKey(id)
                      ? Text(
                          model.contentMap[id],
                          style: TextStyle(fontSize: 20),
                        )
                      : Center(
                          child: CircularProgressIndicator(),
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
    });
  }
}
