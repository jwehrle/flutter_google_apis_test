import 'package:flutter/material.dart';
import 'package:flutter_google_apis_test/models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_google_apis_test/app_drive_api/v3.dart' as drive;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      List<drive.File> files = [];
      if (model.signedIn) {
        for (var id in model.metaMap.entries) {
          files.add(model.metaMap[id]);
        }
      } else if (!model.signInCalled) {
        model.signIn();
      }
      return Scaffold(
        appBar: AppBar(
          title: Text('Drive Test Home Page'),
        ),
        body: _buildBasedOnModel(model),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/add');
          },
          child: Icon(Icons.add),
        ),
      );
    });
  }

  Widget _buildBasedOnModel(MainModel model) {
    if (!model.signedIn) {
      return Center(
        child: Text('Not signed in.'),
      );
    }
    if (model.isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (model.metaMap.isEmpty) {
      return ListView(
        children: <Widget>[],
      );
    }
    List<drive.File> files = [];
    model.metaMap.forEach((id, file) {
      files.add(file);
    });
    return ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(files[index].id),
            onDismissed: (DismissDirection direction) {
              model.deleteFile(files[index].id);
            },
            background: Container(color: Colors.red),
            child: GestureDetector(
              onTap: () {
                model.selectedID = files[index].id;
                Navigator.pushNamed(context, '/detail');
              },
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  files[index].name,
                  style: TextStyle(fontSize: 32.0),
                ),
              ),
            ),
          );
        });
  }
}
