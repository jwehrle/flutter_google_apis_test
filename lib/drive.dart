import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'app_drive_api/v3.dart' as drive;
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
    updateFile = await updateFileContent(updateFile, content);
    map[Drive.ID] = updateFile.id;
    map[Drive.NAME] = updateFile.name;
    map[Drive.CONTENT] = content;
    return map;
  }

  Future<drive.File> updateFileContent(drive.File file, String content) async {
    var media = requests.Media(
        Stream.fromFuture(_getBytes(content)), content.codeUnits.length);
    _driveApi.files
        .update(file, file.id, uploadMedia: media) // $fields: 'id, name'
        .then((drive.File f) {
      print('Successful update. ID: ' +
          f.id); //', parent: ' + f.parents.toString()
      file = f;
    }, onError: (e) {
      file = null;
      print('Failed to upload file: ' + e.toString());
    });
    return file;
  }

//  Future<drive.File> createFile(String title, String content) async {
//    Map<String, String> map;
//    drive.File file = await _createAppDataFile(title, content);
//    map = Map();
//    map[Drive.ID] = file.id;
//    map[Drive.NAME] = file.name;
//    map[Drive.CONTENT] = content;
//    return map;
//  }

  Future<List<int>> _getBytes(String text) async {
    return text.codeUnits;
  }

  Future<drive.File> createFile(String title, String content) async {
    drive.File createdFile = new drive.File();
    createdFile.name = title;
    createdFile.parents = ['appDataFolder'];
    createdFile.mimeType = 'application/json';
    var media = requests.Media(
        Stream.fromFuture(_getBytes(content)), content.codeUnits.length);
    createdFile = await _driveApi.files.create(createdFile,
        uploadMedia: media,
        $fields: 'id, name, parents',
        useContentAsIndexableText: true);
//    .then((drive.File f) {
//    print('Successful upload. Name: ' +
//    f.name +
//    ', ID: ' +
//    f.id); // + ', parent: ' + f.parents.toString()
//    createdFile = f;
//    }, onError: (e) {
//    createdFile = null;
//    print('Failed to upload file: ' + e.toString());
//    })
    return createdFile;
  }

  Future<dynamic> deleteFile(String id) async {
    return _driveApi.files.delete(id);
  }

  void initialize(Map<String, String> headers) {
    _driveApi = drive.DriveApi(new http.Client(), headers);
  }

  Stream<Map<String, drive.File>> getMetaFiles() async* {
    if (_driveApi != null) {
      try {
        drive.FileList fileList = await _driveApi.files.list(
            spaces: 'appDataFolder', $fields: 'files(id, name)', pageSize: 10);
        Map<String, drive.File> metaMap = Map();
        for (var meta in fileList.files) {
          metaMap[meta.id] = meta;
        }
        yield metaMap;
      } on Exception catch (e) {
        print(e.toString());
      }
    }
  }

  Future<String> getFileContents(String id) async {
    requests.Media mediaFile = await _driveApi.files
        .get(id, downloadOptions: requests.DownloadOptions.FullMedia);
    return await _getStringFromStream(mediaFile.stream);
  }

  Stream<Map<String, String>> updateDriveContents() async* {
    Map<String, String> contents = Map();
    if (_driveApi == null) {
      yield contents;
    }
    _fileList = await _driveApi.files.list(
        spaces: 'appDataFolder', $fields: 'files(id, name)', pageSize: 10);
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
    }
  }

  Future<drive.FileList> getDriveMetaData() async {
    return await _driveApi.files.list(
        spaces: 'appDataFolder', $fields: 'files(id, name)', pageSize: 10);
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
  String _selected = "";

  Map<String, drive.File> metaMap = Map();
  Map<String, String> contentMap = Map();

  Function _metaFilesListener;
  Map<String, Function> _contentListenerMap = Map();

  Drive({Key key, Widget child}) : super(child: child, key: key) {
    _authService.signIn().listen((GoogleSignInAccount account) async {
      _driveService.initialize(await account.authHeaders);
      subscribeToMetaFiles();
    });
  }

  void _notifyMetaFilesListener() {
    if (_metaFilesListener != null) {
      _metaFilesListener();
    }
  }

  void _notifyContentListener(String id) {
    if (_contentListenerMap.containsKey(id)) {
      _contentListenerMap[id]();
    }
  }

  void renameFile(String oldID, String newName) async {
    drive.File newFile =
        await _driveService.createFile(newName, contentMap[oldID]);
    await _driveService.deleteFile(oldID);
    metaMap[newFile.id] = newFile;
    metaMap.remove(oldID);
    contentMap[newFile.id] = contentMap[oldID];
    contentMap.remove(oldID);
    _contentListenerMap[newFile.id] = _contentListenerMap[oldID];
    _contentListenerMap.remove(oldID);
    _selected = newFile.id;
//    if (getSelected() != null) {
//      if (getSelected()[ID] == oldID) {
//        selectFile(newFile.id);
//      }
//    }
    _notifyMetaFilesListener();
    _notifyContentListener(newFile.id);
  }

  void updateContent(String id, String content) async {
    drive.File updatedMetaFile =
        await _driveService.updateFileContent(metaMap[id], content);
    metaMap[id] =
        updatedMetaFile; // id is the same but other fields have changed.
    contentMap[id] = content;
    _notifyContentListener(id);
  }

  void renameAndUpdateContent(
      String oldID, String newName, String newContent) async {
    drive.File newFile = await _driveService.createFile(newName, newContent);
    await _driveService.deleteFile(oldID);
    metaMap[newFile.id] = newFile;
    metaMap[newFile.id] = newFile;
    metaMap.remove(oldID);
    contentMap[newFile.id] = newContent;
    contentMap.remove(oldID);
    _contentListenerMap[newFile.id] = _contentListenerMap[oldID];
    _contentListenerMap.remove(oldID);
    _selected = newFile.id;
    _notifyMetaFilesListener();
    _notifyContentListener(newFile.id);
    _notifyMetaFilesListener();
    _notifyContentListener(newFile.id);
  }

  void addFile(String title, String content) async {
    drive.File addedFile = await _driveService.createFile(title, content);
    metaMap[addedFile.id] = addedFile;
    _notifyMetaFilesListener();
  }

  void selectFile(String id) {
    _selected = id;
    subscribeToFileContent(id);
//    Map<String, String> selected = Map();
//    selected[ID] = id;
//    selected[NAME] = metaMap[id].name;
//    if (contentMap.containsKey(id)) {
//      selected[CONTENT] = contentMap[id];
//      _SelectedFile.setSelected(selected);
//    } else {
//      _SelectedFile.setSelected(selected);
//      subscribeToFileContent(id);
//    }
  }

//  void unselectFile() {
//    _SelectedFile.unselect();
//  }

  String getSelected() {
    return _selected;
  }

  void delete(String id) async {
    metaMap.remove(id);
    contentMap.remove(id);
    requests.ApiRequestError error = await _driveService.deleteFile(id);
    if (error != null) {
      print(error);
      metaMap.clear();
      contentMap.clear();
      subscribeToMetaFiles();
    }
  }

//  void updateList() {
//    _driveService.updateDriveContents().listen((contents) {
//      driveContents.add(contents);
//      _notifyMetaFilesListener();
//    });
//  }

  void registerMetaFilesListener(Function notify) {
    _metaFilesListener = notify;
  }

  void registerContentListener(Function notify, String id) {
    _contentListenerMap[id] = notify;
  }

  void subscribeToMetaFiles() {
    _driveService.getMetaFiles().listen((map) {
      metaMap = map;
      _notifyMetaFilesListener();
    });
  }

  void subscribeToFileContent(String id) async {
    //String content = await _driveService.getFileContents(id);
    contentMap[id] = await _driveService.getFileContents(id);
//    if (_SelectedFile.getSelected() != null) {
//      if (!_SelectedFile.getSelected().containsKey(CONTENT)) {
//        _SelectedFile.getSelected()[CONTENT] = content;
//      }
//    }
    _notifyContentListener(id);
  }

  List<drive.File> getMetaFiles() {
    List<drive.File> list = [];
    for (var entry in metaMap.entries) {
      list.add(entry.value);
    }
    return list;
  }

  static Drive of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(Drive));

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}
