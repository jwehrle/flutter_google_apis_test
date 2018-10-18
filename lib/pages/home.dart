import 'package:flutter/material.dart';
import '../blocProvider.dart';
import 'detail.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    DriveBloc.of(context).registerListener(notify);
    return Scaffold(
      appBar: AppBar(
        title: Text('Drive Test Home Page'),
      ),
      body: DriveBloc.of(context).driveContents.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: DriveBloc.of(context).driveContents.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(DriveBloc.of(context).driveContents[index]['id']),
                  onDismissed: (DismissDirection direction) {
                    String id =
                        DriveBloc.of(context).driveContents[index]['id'];
                    DriveBloc.of(context).delete(id);
                  },
                  background: Container(color: Colors.red),
                  child: GestureDetector(
                    onTap: () {
                      DriveBloc.of(context).selectFile(
                          DriveBloc.of(context).driveContents[index]['id']);
                      Navigator.pushNamed(context, '/detail');
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        DriveBloc.of(context).driveContents[index]['name'],
                        style: TextStyle(fontSize: 32.0),
                      ),
                    ),
                  ),
                );
              }),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void notify() {
    setState(() {});
  }

//  void _createFile(MainModel model, String title, String content) async {
//    driveHelper.createAppDataFile(title, content).then((drive.File file) {
//      driveHelper.listAppDataFiles().then((drive.FileList fileList) {
//        model.setFileList(fileList);
//      });
//    });
//  }
}
