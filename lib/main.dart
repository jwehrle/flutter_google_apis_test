import 'dart:io' as io;

import 'drive_helper.dart';
import 'package:scoped_model/scoped_model.dart';
import 'scoped_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:googleapis/drive/v3.dart';
import 'app_drive_api/v3.dart' as drive;
import 'app_drive_api/clients.dart' as clients;
import 'app_drive_api/requests.dart' as requests;
import 'package:http/http.dart' as http
    show BaseRequest, IOClient, Response, StreamedResponse;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'blocProvider.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DriveBloc(
        child: MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//  static const String appDataFileTitle =
//      'com.mobilityapplied.fluttergoogleapistest.appdata';
//  static const String contentKey = 'content';
//  final FirebaseAuth _auth = FirebaseAuth.instance;

//  drive.File appDataFile;
//  String appDataId;

//  GoogleSignIn _googleSignIn = new GoogleSignIn(scopes: <String>[
//    drive.DriveApi.DriveAppdataScope,
//    drive.DriveApi.DriveFileScope
//  ]);

//  GoogleSignInAccount _googleSignInAccount;

//  Map<String, String> authHeaders;

//  DriveHelper driveHelper;

//  Future<FirebaseUser> _signIn() async {
//    FirebaseUser firebaseUser;
//    try {
//      _googleSignIn.signIn().then((account) {
//        _googleSignInAccount = account;
//        _googleSignInAccount.authentication.then((gsa) {
//          _googleSignInAccount.authHeaders.then((headers) {
//            authHeaders = headers;
//            //client = new DriveClient(headers);
//            driveHelper = new DriveHelper(headers: headers);
//          }, onError: (e) {
//            print(e);
//          });
//          _auth
//              .signInWithGoogle(
//                  idToken: gsa.idToken, accessToken: gsa.accessToken)
//              .then((user) {
//            print("Signed in as : ${user.displayName}");
//            firebaseUser = user;
//            _initFiles();
//          }, onError: (e) {
//            print(e);
//          });
//        }, onError: (e) {
//          print(e);
//        });
//      }, onError: (e) {
//        print(e);
//      });
//      return firebaseUser;
//    } on Exception catch (e) {
//      return null;
//    }
//  }

//  drive.FileList list;

//  void _initFiles() async {
//    list = await driveHelper.listAppDataFiles();
//    setState(() {
//      areFilesFresh = true;
//    });
//    //model.setFileList(list);
//  }

//  requests.Media selected;
//  bool isSelectedFresh = false;

//  String selectedString;
//  bool isSelectedStringFresh = false;

//  void getSelectedString(MainModel model) async {
//    List<int> byteArray = [];
//    await for (var b in model.selected.stream) {
//      byteArray = b;
//    }
//    selectedString = String.fromCharCodes(byteArray);
//  }

//  void _initFile(String id) async {
//    selected = await driveHelper.getAppDataFile(fileId: id);
//    await for (var bytes in selected.stream) {
//      selectedString = String.fromCharCodes(bytes);
//    }
//    setState(() {
//      isSelectedFresh = true;
//    });
//  }

//  bool areFilesFresh = false;
//  RefreshController refreshController = new RefreshController();
//  TextEditingController titleController = new TextEditingController();
//  TextEditingController contentController = new TextEditingController();

//  ListView _buidlSelectedFileListView(BuildContext context, MainModel model) {
//    if (isSelectedFresh) {
//      isSelectedFresh = false;
//      model.setSelected(selected);
//    }
//
//    if (model.selected == null) {
//      return new ListView(children: <Widget>[]);
//    }
//
//    return new ListView(children: <Widget>[
//      Text(
//        selectedString,
//      ),
//    ]);
//  }

//  ListView _buildDriveList(BuildContext context, MainModel model) {
//    if (areFilesFresh) {
//      areFilesFresh = false;
//      model.setFileList(list);
//    }
//
//    if (model.fileList == null) {
//      return new ListView(children: <Widget>[]);
//    }
//    if (model.fileList.files == null) {
//      return new ListView(children: <Widget>[]);
//    }
//    if (model.fileList.files.isEmpty) {
//      return new ListView(children: <Widget>[]);
//    }
//
//    return new ListView.builder(
//        itemCount: model.fileList.files.length,
//        itemBuilder: (context, index) {
//          return new ListTile(
//            onTap: () {
//              _initFile(model.fileList.files[index].id);
//              model.setSelectedFie(index);
//            },
//            title: Text(model.fileList.files[index].name),
//          );
//        });
//  }

//  @override
//  void initState() {
////    super.initState();
////    _signIn();
////    areFilesFresh = false;
//  }

  @override
  Widget build(BuildContext context) {
    DriveBloc.of(context).registerListener(notify);
    return Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
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
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      DriveBloc.of(context).driveContents[index]['name'],
                      style: TextStyle(fontSize: 32.0),
                    ),
                  ),
                );
              }),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {},
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
