import 'package:flutter/material.dart';
import '../blocProvider.dart';

class EditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditState();
}

class EditState extends State<EditPage> {
  @override
  Widget build(BuildContext context) {
    Map<String, String> file = DriveBloc.of(context).getSelected();
    return Scaffold(
      appBar: new AppBar(
        title: new Text('File Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(18.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(hintText: file['name']),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                maxLines: 20,
                decoration: InputDecoration(hintText: file['content']),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.check),
      ),
    );
  }
}
