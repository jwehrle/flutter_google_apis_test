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
  drive.FileList _fileList;

  DriveService();

  Future<Map<String, String>> updateFile(
      String id, String title, String content) async {
    Map<String, String> map = Map();
    drive.File updateFile;
    for (int i = 0; i < _fileList.files.length; i++) {
      if (_fileList.files[i].id == id) {
        updateFile = _fileList.files[i];
        break;
      }
    }
    updateFile = await _updateAppDataFile(updateFile, id, content);
    map[Drive.ID] = updateFile.id;
    map[Drive.NAME] = updateFile.name;
    map[Drive.CONTENT] = content;
    return map;
  }

  Future<drive.File> _updateAppDataFile(
      drive.File file, String id, String content) async {
    var media = requests.Media(
        Stream.fromFuture(_getBytes(content)), content.codeUnits.length);
    _driveApi.files
        .update(file, id,
            uploadMedia: media,
            $fields: 'id, name, parents',
            useContentAsIndexableText: true)
        .then((drive.File f) {
      print('Successful update. Name: ' +
          f.name +
          ', ID: ' +
          f.id +
          ', parent: ' +
          f.parents.toString());
      file = f;
    }, onError: (e) {
      file = null;
      print('Failed to upload file: ' + e.toString());
    });
    return file;
  }

  Future<Map<String, String>> createFile(String title, String content) async {
    Map<String, String> map;
    drive.File file = await _createAppDataFile(title, content);
    map = Map();
    map[Drive.ID] = file.id;
    map[Drive.NAME] = file.name;
    map[Drive.CONTENT] = content;
    return map;
  }

  Future<List<int>> _getBytes(String text) async {
    return text.codeUnits;
  }

  Future<drive.File> _createAppDataFile(String title, String content) async {
    drive.File createdFile = new drive.File();
    createdFile.name = title;
    createdFile.parents = ['appDataFolder'];
    createdFile.mimeType = 'application/json';
    var media = requests.Media(
        Stream.fromFuture(_getBytes(content)), content.codeUnits.length);
    _driveApi.files
        .create(createdFile,
            uploadMedia: media,
            $fields: 'id, name, parents',
            useContentAsIndexableText: true)
        .then((drive.File f) {
      print('Successful upload. Name: ' +
          f.name +
          ', ID: ' +
          f.id +
          ', parent: ' +
          f.parents.toString());
      createdFile = f;
    }, onError: (e) {
      createdFile = null;
      print('Failed to upload file: ' + e.toString());
    });
    return createdFile;
  }

  Future<dynamic> deleteFile(String id) async {
    return _driveApi.files.delete(id);
  }

  void initialize(Map<String, String> headers) {
    _driveApi = drive.DriveApi(new http.Client(), headers);
  }

  Stream<Map<String, String>> updateDriveContents() async* {
    Map<String, String> contents = Map();
    if (_driveApi == null) {
      yield contents;
    }
    _fileList = await _driveApi.files.list(
        spaces: 'appDataFolder',
        $fields: 'files(id, name, parents)',
        pageSize: 10);
    List<requests.Media> mediaList = [];
    for (var metaFile in _fileList.files) {
      requests.Media mediaFile = await _driveApi.files.get(metaFile.id,
          downloadOptions: requests.DownloadOptions.FullMedia);
      mediaList.add(mediaFile);
    }

    for (int i = 0; i < mediaList.length; i++) {
      Map<String, String> entry = Map();
      entry[Drive.ID] = _fileList.files[i].id;
      entry[Drive.NAME] = _fileList.files[i].name;
      entry[Drive.CONTENT] = await _getStringFromStream(mediaList[i].stream);
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
        if (map[Drive.ID] == id) {
          yield map;
        }
      }
    }
    yield null;
  }
}

class _SelectedFile {
  static Map<String, String> _selected;
  static void setSelected(Map<String, String> select) {
    _selected = select;
  }

  static void unselect() {
    _selected = null;
  }

  static bool isSelected() {
    return _selected != null;
  }

  static Map<String, String> getSelected() {
    return _selected;
  }
}

class Drive extends InheritedWidget {
  static const String ID = 'id';
  static const String NAME = 'name';
  static const String CONTENT = 'content';
  final AuthService _authService = AuthService();
  final DriveService _driveService = DriveService();
  List<Map<String, String>> driveContents = [];
  Function _listener;

  Drive({Key key, Widget child}) : super(child: child, key: key) {
    _authService.signIn().listen((GoogleSignInAccount account) async {
      _driveService.initialize(await account.authHeaders);
      updateList();
    });
  }

  void _notify() {
    if (_listener != null) {
      _listener();
    }
  }

  void updateFile(Map<String, String> file) async {
    Map<String, String> updatedFile =
        await _driveService.updateFile(file[ID], file[NAME], file[CONTENT]);
    int indexOfUpdated;
    for (int i = 0; i < driveContents.length; ++i) {
      if (driveContents[i][ID] == updatedFile[ID]) {
        indexOfUpdated = i;
        break;
      }
    }
    driveContents[indexOfUpdated] = updatedFile;
    _notify();
  }

  void addFile(String title, String content) async {
    driveContents.insert(0, await _driveService.createFile(title, content));
    _notify();
  }

  void selectFile(String id) {
    int indexToSelect;
    for (int i = 0; i < driveContents.length; i++) {
      if (driveContents[i][ID] == id) {
        indexToSelect = i;
        break;
      }
    }
    _SelectedFile.setSelected(driveContents[indexToSelect]);
  }

  void unselectFile() {
    _SelectedFile.unselect();
  }

  Map<String, String> getSelected() {
    return _SelectedFile.getSelected();
  }

  void delete(String id) async {
    int indexToRemove;
    for (int i = 0; i < driveContents.length; i++) {
      if (driveContents[i][ID] == id) {
        indexToRemove = i;
        break;
      }
    }
    driveContents.removeAt(indexToRemove);
    requests.ApiRequestError response = await _driveService.deleteFile(id);
    if (response != null) {
      print(response);
      driveContents.clear();
      updateList();
    }
  }

  void updateList() {
    _driveService.updateDriveContents().listen((contents) {
      driveContents.add(contents);
      _notify();
    });
  }

  void registerListener(Function notify) {
    _listener = notify;
  }

  static Drive of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(Drive));

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}
