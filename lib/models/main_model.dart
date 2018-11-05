import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_google_apis_test/app_drive_api/v3.dart' as drive;
import 'package:flutter_google_apis_test/controllers/drive_controller.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_google_apis_test/controllers/local_storage_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainModel extends Model {
  SharedPreferences pref;
  GoogleSignInAccount _googleSignInAccount;
  bool _signedIn = false;
  drive.DriveApi _driveApi;
  String _selectedID = '';
  bool isLoading = true;
  bool signInCalled = false;

  bool get signedIn => _signedIn;

  String get selectedID => _selectedID;

  set selectedID(String value) {
    _selectedID = value;
  }

  static MainModel _instance;

  MainModel._() {
    SharedPreferences.getInstance().then((preferences) {
      pref = preferences;
    });
  }

  static MainModel getInstance() {
    if (_instance == null) {
      _instance = MainModel._();
    }
    return _instance;
  }

  bool isPrefLoading() {
    return pref == null;
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
          downloadMetaFiles();
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

  bool hasContent(String id) {
    return StorageController.getInstance().containsContent(pref, id);
  }

  String getFileContent(String id) {
    return StorageController.getInstance().getFileContent(pref, id);
  }

  drive.File getMetaFile(String id) {
    return StorageController.getInstance().getMetaFile(pref, id);
  }

  List<drive.File> getMetaFileList() {
    return StorageController.getInstance().getMetaFileList(pref);
  }

  void downloadMetaFiles() async {
    isLoading = true;
    notifyListeners();
    try {
      drive.FileList fileList =
          await DriveController.getMetaFileList(_driveApi);
      StorageController storage = StorageController.getInstance();
      for (drive.File file in fileList.files) {
        storage.putMetaFile(pref, file.id, file);
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  void downloadFileContent(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      String content = await DriveController.getFileContents(_driveApi, id);
      StorageController.getInstance().putFileContent(pref, id, content);
    } on Exception catch (e) {
      print(e.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  void uploadFile(String name, String content) async {
    isLoading = true;
    notifyListeners();
    try {
      drive.File metaFile =
          await DriveController.createFile(_driveApi, name, content);
      StorageController storage = StorageController.getInstance();
      storage.putMetaFile(pref, metaFile.id, metaFile);
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
      StorageController storage = StorageController.getInstance();
      storage.deleteMeta(pref, id);
      storage.deleteContent(pref, id);
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
      StorageController storage = StorageController.getInstance();
      drive.File file = await DriveController.updateFileContents(
          _driveApi, storage.getMetaFile(pref, id), content);
      storage.putMetaFile(pref, id, file);
      storage.putFileContent(pref, id, content);
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
      StorageController storage = StorageController.getInstance();
      drive.File metaFile = await DriveController.createFile(
          _driveApi, newName, storage.getFileContent(pref, oldID));
      storage.putMetaFile(pref, metaFile.id, metaFile);
      storage.deleteMeta(pref, oldID);
      storage.putFileContent(
          pref, metaFile.id, storage.getFileContent(pref, oldID));
      storage.deleteContent(pref, oldID);
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
      StorageController storage = StorageController.getInstance();
      storage.putMetaFile(pref, metaFile.id, metaFile);
      storage.deleteMeta(pref, oldID);
      storage.putFileContent(pref, metaFile.id, newContent);
      storage.deleteContent(pref, oldID);
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
