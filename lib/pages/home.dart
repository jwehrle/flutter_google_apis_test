import 'package:flutter/material.dart';
import '../drive.dart';
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
    Drive.of(context).registerListener(notify);
    return Scaffold(
      appBar: AppBar(
        title: Text('Drive Test Home Page'),
      ),
      body: Drive.of(context).driveContents.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: Drive.of(context).driveContents.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(Drive.of(context).driveContents[index][Drive.ID]),
                  onDismissed: (DismissDirection direction) {
                    String id =
                        Drive.of(context).driveContents[index][Drive.ID];
                    Drive.of(context).delete(id);
                  },
                  background: Container(color: Colors.red),
                  child: GestureDetector(
                    onTap: () {
                      Drive.of(context).selectFile(
                          Drive.of(context).driveContents[index][Drive.ID]);
                      Navigator.pushNamed(context, '/detail');
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        Drive.of(context).driveContents[index][Drive.NAME],
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
}
