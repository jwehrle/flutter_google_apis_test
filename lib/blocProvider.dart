import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';
import 'app_drive_api/v3.dart' as drive;
import 'app_drive_api/clients.dart' as clients;
import 'app_drive_api/requests.dart' as requests;
import 'package:http/http.dart' as http;

class AuthService {
  Stream<GoogleSignInAccount> authStream;
  FirebaseUser _user;

  Stream<GoogleSignInAccount> signIn() async* {
    GoogleSignInAccount gsa = await GoogleSignIn(scopes: <String>[
      drive.DriveApi.DriveAppdataScope,
      drive.DriveApi.DriveFileScope
    ]).signIn();
    GoogleSignInAuthentication signInAuthentication = await gsa.authentication;
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    _user = await firebaseAuth.signInWithGoogle(
        idToken: signInAuthentication.idToken,
        accessToken: signInAuthentication.accessToken);
    yield gsa;
  }

  void signOut() {
    _user = null;
    authStream.drain();
  }
}

class DriveService {
  Stream<List<Map<String, String>>> driveContents;
  Stream<Map<String, String>> driveItemStream;
  Map<String, String> selectedContents;
  drive.DriveApi _driveApi;

  DriveService();

  Future<dynamic> deleteFile(String id) async {
    return _driveApi.files.delete(id);
  }

  void initialize(Map<String, String> headers) {
    _driveApi = drive.DriveApi(new http.Client(), headers);
    //driveContents = updateDriveContents();
  }

  Stream<Map<String, String>> updateDriveContents() async* {
    Map<String, String> contents = Map();
    if (_driveApi == null) {
      yield contents;
    }
    drive.FileList fileList = await _driveApi.files.list(
        spaces: 'appDataFolder',
        $fields: 'files(id, name, parents)',
        pageSize: 10);
    List<requests.Media> mediaList = [];
    for (var metaFile in fileList.files) {
      requests.Media mediaFile = await _driveApi.files.get(metaFile.id,
          downloadOptions: requests.DownloadOptions.FullMedia);
      mediaList.add(mediaFile);
    }

    for (int i = 0; i < mediaList.length; i++) {
      Map<String, String> entry = Map();
      entry['id'] = fileList.files[i].id;
      entry['name'] = fileList.files[i].name;
      entry['content'] = await _getStringFromStream(mediaList[i].stream);
      yield entry;
      //contents.add(entry);
    }
    //yield contents;
  }

  Future<drive.FileList> getDriveMetaData() async {
    return await _driveApi.files.list(
        spaces: 'appDataFolder',
        $fields: 'files(id, name, parents)',
        pageSize: 10);
  }

  Stream<Map<String, String>> fillDriveItemStream(String id) async* {
    yield await _driveApi.files
        .get(id, downloadOptions: requests.DownloadOptions.FullMedia);
  }

  Future<String> _getStringFromStream(Stream<List<int>> stream) async {
    List<int> byteArray = [];
    await for (var b in stream) {
      byteArray = b;
    }
    return String.fromCharCodes(byteArray);
  }

  Stream<Map<String, String>> updateSelected({String id}) async* {
    if (id == null) {
      yield null;
    }
    await for (var list in driveContents) {
      for (var map in list) {
        if (map['id'] == id) {
          yield map;
        }
      }
    }
    yield null;
  }
}

class DriveBloc extends InheritedWidget {
  final AuthService _authService = AuthService();
  final DriveService driveService = DriveService();
  List<Map<String, String>> driveContents = [];
  Function listener;

  DriveBloc({Key key, Widget child}) : super(child: child, key: key) {
    _authService.signIn().listen((GoogleSignInAccount account) async {
      driveService.initialize(await account.authHeaders);
//      drive.FileList metaList = await driveService.getDriveMetaData();
//      for (var metaFile in metaList.files) {
//        driveService.fillDriveItemStream(metaFile.id);
//      }
      updateList();
//      driveService.updateDriveContents().listen((contents) {
//        driveContents.add(contents);
//        if (listener != null) {
//          listener();
//        }
//      });
    });
  }

  void delete(String id) async {
    int indexToRemove;
    for (int i = 0; i < driveContents.length; i++) {
      if (driveContents[i]['id'] == id) {
        indexToRemove = i;
        break;
      }
    }
    driveContents.removeAt(indexToRemove);
    requests.ApiRequestError response = await driveService.deleteFile(id);
    if (response != null) {
      print(response);
      driveContents.clear();
      updateList();
    }
  }

  void updateList() {
    driveService.updateDriveContents().listen((contents) {
      driveContents.add(contents);
      if (listener != null) {
        listener();
      }
    });
  }

  void registerListener(Function notify) {
    listener = notify;
  }

  static DriveBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(DriveBloc));

  @override
  bool updateShouldNotify(DriveBloc oldWidget) {
    return true;
  }
}
