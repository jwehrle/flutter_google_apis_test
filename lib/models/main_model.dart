import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_google_apis_test/app_drive_api/v3.dart' as drive;
import 'package:flutter_google_apis_test/controllers/drive_controller.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class MainModel extends Model {
  GoogleSignInAccount _googleSignInAccount;
  bool _signedIn = false;
  drive.DriveApi _driveApi;
  Map<String, drive.File> _metaMap = Map();
  Map<String, String> _contentMap = Map();
  String _selectedID = '';
  bool isLoading = true;
  bool signInCalled = false;

  bool get signedIn => _signedIn;
  Map<String, drive.File> get metaMap => _metaMap;

  Map<String, String> get contentMap => _contentMap;

  String get selectedID => _selectedID;

  set selectedID(String value) {
    _selectedID = value;
  }

  void signIn() async {
    if (_signedIn) {
      return;
    }
    try {
      signInCalled = true;
      GoogleSignIn gsi = GoogleSignIn(scopes: <String>[
        drive.DriveApi.DriveAppdataScope,
        drive.DriveApi.DriveFileScope
      ]);
      gsi.signIn().then((account) async {
        _googleSignInAccount = account;
        _signedIn = true;
        _googleSignInAccount.authHeaders.then((headers) {
          _driveApi = drive.DriveApi(http.Client(), headers);
          getMetaFiles();
        });
      });
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  void signOut() async {
    _googleSignInAccount = null;
    _signedIn = false;
    notifyListeners();
  }

  void getMetaFiles() async {
    isLoading = true;
    notifyListeners();
    try {
      _metaMap = await DriveController.getMetaFiles(_driveApi);
    } on Exception catch (e) {
      print(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  void getFileContent(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      String content = await DriveController.getFileContents(_driveApi, id);
      _contentMap[id] = content;
    } on Exception catch (e) {
      print(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  void addFile(String name, String content) async {
    isLoading = true;
    notifyListeners();
    try {
      drive.File metaFile =
          await DriveController.createFile(_driveApi, name, content);
      _metaMap[metaFile.id] = metaFile;
    } on Exception catch (e) {
      print(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  void deleteFile(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      _metaMap.remove(id);
      _contentMap.remove(id);
      await DriveController.deleteFile(_driveApi, id);
    } on Exception catch (e) {
      print(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  void updateFileContents(String id, String content) async {
    isLoading = true;
    notifyListeners();
    try {
      drive.File file = await DriveController.updateFileContents(
          _driveApi, _metaMap[id], content);
      _metaMap[id] = file;
      _contentMap[id] = content;
    } on Exception catch (e) {
      print(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  void renameFile(String oldID, String newName) async {
    isLoading = true;
    notifyListeners();
    try {
      await DriveController.deleteFile(_driveApi, oldID);
      drive.File metaFile = await DriveController.createFile(
          _driveApi, newName, _contentMap[oldID]);
      _metaMap[metaFile.id] = metaFile;
      _metaMap.remove(oldID);
      _contentMap[metaFile.id] = _contentMap[oldID];
      _contentMap.remove(oldID);
      if (_selectedID == oldID) {
        _selectedID = metaFile.id;
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  void renameAndUpdateFileContents(
      String oldID, String newName, String newContent) async {
    isLoading = true;
    notifyListeners();
    try {
      await DriveController.deleteFile(_driveApi, oldID);
      drive.File metaFile =
          await DriveController.createFile(_driveApi, newName, newContent);
      _metaMap[metaFile.id] = metaFile;
      _metaMap.remove(oldID);
      _contentMap[metaFile.id] = newContent;
      _contentMap.remove(oldID);
      if (_selectedID == oldID) {
        _selectedID = metaFile.id;
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }
}
