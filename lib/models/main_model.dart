import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_google_apis_test/app_drive_api/v3.dart' as drive;
import 'package:flutter_google_apis_test/controllers/drive_controller.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_google_apis_test/controllers/storage_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_google_apis_test/models/change.dart';
import 'dart:convert';

class MainModel extends Model {
  final String CHANGE_LOG_REF = 'changeLog';
  SharedPreferences pref;
  GoogleSignInAccount _googleSignInAccount;
  String accessToken;
  String idToken;

  FirebaseUser _firebaseUser;
  FirebaseAuth _firebaseAuth;
  var changeLogStream;
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
    _firebaseAuth = FirebaseAuth.instance;
    SharedPreferences.getInstance().then((preferences) {
      pref = preferences;
      Storage.initStorage(pref);
    });
  }

  static MainModel getInstance() {
    if (_instance == null) {
      _instance = MainModel._();
    }
    return _instance;
  }

  Future _saveToChangeLog(String action, String id) async {
    Change change = Change(action, id);
    Storage.saveChange(pref, change);
    FirebaseDatabase.instance
        .reference()
        .child(_firebaseUser.uid)
        .push()
        .set(change.toJsonString())
        .then((resp) {
      print('Saved change to ChangeLog');
    }, onError: (e) {
      print(e.toString());
    });
  }

  void _startedLoading() {
    isLoading = true;
    notifyListeners();
  }

  void _finishedLoading() {
    isLoading = false;
    notifyListeners();
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
      GoogleSignIn googleSignIn = GoogleSignIn(scopes: <String>[
        drive.DriveApi.DriveAppdataScope,
        drive.DriveApi.DriveFileScope
      ]);
      googleSignIn.signIn().then((account) async {
        _googleSignInAccount = account;
        _googleSignInAccount.authHeaders.then((headers) {
          _driveApi = drive.DriveApi(http.Client(), headers);
          _googleSignInAccount.authentication
              .then((googleSignInAuthentication) {
            idToken = googleSignInAuthentication.idToken;
            accessToken = googleSignInAuthentication.accessToken;
            _firebaseAuth
                .signInWithGoogle(
                    idToken: googleSignInAuthentication.idToken,
                    accessToken: googleSignInAuthentication.accessToken)
                .then((user) {
              _firebaseUser = user;
              _signedIn = true;
              downloadMetaFiles();
//              Storage.deleteChangeLogs(pref); //Delete old change logs at start
//              Storage.deleteLocalFileContents(
//                  pref); // One copy of data and it lives on GDrive.
              changeLogStream = FirebaseDatabase.instance
                  .reference()
                  .child(_firebaseUser.uid)
                  .onChildAdded
                  .listen((changeEvent) {
                //_handleChangeEvent(changeEvent);//TODO this is being called for everything.
              });
            });
          });
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

  void _handleChangeEvent(Event changeEvent) async {
    if (changeEvent == null) {
      return;
    }
    if (changeEvent.snapshot == null) {
      return;
    }
    if (changeEvent.snapshot.value == null) {
      return;
    }
    Change change = Change.fromJson(json.decode(changeEvent.snapshot.value));
    var changeMap = await Storage.getLocalChanges(pref);
    if (changeMap.containsKey(change.changeID)) {
      return;
    }
    switch (change.action) {
      case Change.CREATED:
        Drive.getMetaFile(_driveApi, change.fileID).then((metaFile) {
          Storage.saveChange(pref, change);
          Storage.putMetaFile(pref, metaFile.id, metaFile);
          notifyListeners();
        });
        break;
      case Change.UPDATED:
        if (Storage.containsContent(pref, change.fileID)) {
          Drive.getFileContents(_driveApi, change.fileID).then((content) {
            Storage.saveChange(pref, change);
            Storage.putFileContent(pref, change.fileID, content);
            notifyListeners();
          });
        }
        break;
      case Change.DELETED:
        Storage.deleteMeta(pref, change.fileID);
        Storage.deleteContent(pref, change.fileID);
        Storage.saveChange(pref, change);
        notifyListeners();
        break;
    }
  }

  bool hasContent(String id) {
    return Storage.containsContent(pref, id);
  }

  String getFileContent(String id) {
    return Storage.getFileContent(pref, id);
  }

  drive.File getMetaFile(String id) {
    return Storage.getMetaFile(pref, id);
  }

  List<drive.File> getMetaFileList() {
    return Storage.getMetaFileList(pref);
  }

  void syncFromChangeLog() {}

  void downloadMetaFiles() async {
    _startedLoading();
    Drive.getMetaFileList(_driveApi).then((fileList) {
      fileList.files.forEach((file) {
        Storage.putMetaFile(pref, file.id, file);
      });
      _finishedLoading();
    }, onError: () {
      print('PROBLEM DOWNLOADING META FILES.');
      _finishedLoading();
    });
  }

  void downloadFileContent(String id) async {
    _startedLoading();
    Drive.getFileContents(_driveApi, id).then((content) {
      Storage.putFileContent(pref, id, content);
      _finishedLoading();
    }, onError: () {
      print('PROBLEM DOWNLOADING FILE CONTENT.');
      _finishedLoading();
    });
  }

  void uploadNewFile(String name, String content) async {
    _startedLoading();
    Drive.createFile(_driveApi, name, content).then((metaFile) {
      Storage.putMetaFile(pref, metaFile.id, metaFile);
      _saveToChangeLog(Change.CREATED, metaFile.id);
      _finishedLoading();
    }, onError: () {
      print('PROBLEM UPLOADING NEW FILE.');
      _finishedLoading();
    });
  }

  void deleteFile(String id) async {
    _startedLoading();
    Drive.deleteFile(_driveApi, id).then((_) {
      _saveToChangeLog(Change.DELETED, id);
      Storage.deleteMeta(pref, id);
      Storage.deleteContent(pref, id);
      _finishedLoading();
    }, onError: () {
      print('PROBLEM DELETING FILE.');
      _finishedLoading();
    });
  }

  void updateFileContents(String id, String name, String content) async {
    _startedLoading();
    Drive.updateFileContents(
        _driveApi, id, name, content, _onFileUpdated, _onUpdateFailed);
  }

  void _onFileUpdated(drive.File file, String content) {
    Storage.putMetaFile(pref, file.id, file);
    Storage.putFileContent(pref, file.id, content);
    _saveToChangeLog(Change.UPDATED, file.id);
    _finishedLoading();
  }

  void _onUpdateFailed() {
    _finishedLoading();
  }

  void renameFile(String oldID, String newName) async {
    _startedLoading();
    Drive.createFile(_driveApi, newName, Storage.getFileContent(pref, oldID))
        .then((metaFile) {
      Drive.deleteFile(_driveApi, oldID).then((_) {
        Storage.putMetaFile(pref, metaFile.id, metaFile);
        Storage.deleteMeta(pref, oldID);
        Storage.putFileContent(
            pref, metaFile.id, Storage.getFileContent(pref, oldID));
        Storage.deleteContent(pref, oldID);
        if (_selectedID == oldID) {
          _selectedID = metaFile.id;
        }
        _saveToChangeLog(Change.CREATED, metaFile.id).then((_) {
          _saveToChangeLog(Change.DELETED, oldID).then((_) {
            _finishedLoading();
          }, onError: () {
            print('PROBLEM SAVING DELETED CHANGE.');
            _finishedLoading();
          });
        }, onError: () {
          print('PROBLEM SAVING CREATED CHANGE.');
          _finishedLoading();
        });
      }, onError: () {
        print('PROBLEM DELETING THE OLD FILE.');
        _finishedLoading();
      });
    }, onError: () {
      print('PROBLEM CREATING THE RENAMED FILE.');
      _finishedLoading();
    });
  }

  void renameAndUpdateFileContents(
      String oldID, String newName, String newContent) async {
    _startedLoading();
    Drive.createFile(_driveApi, newName, newContent).then((metaFile) {
      Drive.deleteFile(_driveApi, oldID).then((_) {
        Storage.putMetaFile(pref, metaFile.id, metaFile);
        Storage.deleteMeta(pref, oldID);
        Storage.putFileContent(pref, metaFile.id, newContent);
        Storage.deleteContent(pref, oldID);
        if (_selectedID == oldID) {
          _selectedID = metaFile.id;
        }
        _saveToChangeLog(Change.CREATED, metaFile.id).then((_) {
          _saveToChangeLog(Change.DELETED, oldID).then((_) {
            _finishedLoading();
          }, onError: () {
            print('PROBLEM SAVING DELETED CHANGE.');
            _finishedLoading();
          });
        }, onError: () {
          print('PROBLEM SAVING CREATED CHANGE.');
          _finishedLoading();
        });
      }, onError: () {
        print('PROBLEM DELETING THE OLD FILE.');
        _finishedLoading();
      });
    }, onError: () {
      print('PROBLEM CREATING THE RENAMED FILE.');
      _finishedLoading();
    });
  }
}
