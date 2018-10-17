import 'dart:async';
import 'dart:collection';
//import 'package:googleapis/drive/v3.dart';
import 'package:flutter/foundation.dart';
import 'app_drive_api/v3.dart';
import 'app_drive_api/clients.dart' as clients;
import 'app_drive_api/requests.dart' as requests;
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
//show BaseRequest, IOClient, Response, StreamedResponse;

class DriveBloc extends Bloc<dynamic, dynamic> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _firebaseUser;
  GoogleSignIn _googleSignIn = new GoogleSignIn(
      scopes: <String>[DriveApi.DriveAppdataScope, DriveApi.DriveFileScope]);
  GoogleSignInAccount _googleSignInAccount;
  Future<FirebaseUser> _signIn() async {
    FirebaseUser firebaseUser;
    try {
      _googleSignIn.signIn().then((account) {
        _googleSignInAccount = account;
        _googleSignInAccount.authentication.then((gsa) {
          _googleSignInAccount.authHeaders.then((headers) {
            _client = DriveClient(headers);
            _driveApi = DriveApi(new http.Client(), headers);
          }, onError: (e) {
            print(e);
          });

          _auth
              .signInWithGoogle(
                  idToken: gsa.idToken, accessToken: gsa.accessToken)
              .then((user) {
            print("Signed in as : ${user.displayName}");
            firebaseUser = user;
          }, onError: (e) {
            print(e);
          });
        }, onError: (e) {
          print(e);
        });
      }, onError: (e) {
        print(e);
      });
      return firebaseUser;
    } on Exception catch (e) {
      return null;
    }
  }

  Stream<List<Map<String, String>>> get driveContents =>
      _driveContentsStream.stream;
  var _driveContentsStream = BehaviorSubject<List<Map<String, String>>>();
  var _driveContents = <Map<String, String>>[];

  Stream<List<File>> get metaFiles => _metaFiles.stream;
  final _metaFiles = BehaviorSubject<List<File>>();

  Stream<List<requests.Media>> get mediaFiles => _mediaFilesStream.stream;
  var _mediaFilesStream = BehaviorSubject<List<requests.Media>>();

  var _medias = <requests.Media>[];

  DriveClient _client;
  DriveApi _driveApi;

  DriveBloc() {
    updateMediaFiles().then((_) {
      _mediaFilesStream.add(_medias);
    });
  }

  Future<List<File>> getMetaFiles() async {
    FileList list = await _driveApi.files.list(
        spaces: 'appDataFolder',
        $fields: 'files(id, name, parents)',
        pageSize: 10);
    return list.files;
  }

  Future<Null> updateMediaFiles() async {
    if (_firebaseUser == null) {
      // Sign in.
      _firebaseUser = await _signIn();
      if (_firebaseUser == null) {
        print('Failed to sign in');
        return null;
      }
    }
    // Get meta files
    final metaFiles = await getMetaFiles();

    // Get media files
    List<requests.Media> mediaList = [];
    for (var metaFile in metaFiles) {
      requests.Media mediaFile = await _driveApi.files.get(metaFile.id,
          downloadOptions: requests.DownloadOptions.FullMedia);
      mediaList.add(mediaFile);
    }

    // Decode media files
    List<Map<String, String>> contents = [];
    for (int i = 0; i < mediaList.length; i++) {
      Map<String, String> entry = Map();
      entry['name'] = metaFiles[i].name;
      entry['content'] = await _getStringFromStream(mediaList[i].stream);
      contents.add(entry);
    }
    _driveContents = contents;
    return null;
  }

  Future<String> _getStringFromStream(Stream<List<int>> stream) async {
    List<int> byteArray = [];
    await for (var b in stream) {
      byteArray = b;
    }
    return String.fromCharCodes(byteArray);
  }

  @override
  Stream<dynamic> mapEventToState(state, event) {
    //List<Map<String, String>>
    // TODO: implement mapEventToState
  }
}

///Initial, Loading, Success, Failure
class DriveContentsState {
  final bool isLoading;
  final String error;
  final List<Map<String, String>> driveContents;

  DriveContentsState(
      {@required this.isLoading,
      @required this.driveContents,
      @required this.error});

  factory DriveContentsState.initial() {
    return DriveContentsState(isLoading: false, driveContents: null, error: '');
  }

  factory DriveContentsState.loading() {
    return DriveContentsState(isLoading: true, driveContents: null, error: '');
  }

  factory DriveContentsState.success(List<Map<String, String>> contents) {
    return DriveContentsState(
        isLoading: false, driveContents: contents, error: '');
  }

  factory DriveContentsState.failure(String error) {
    return DriveContentsState(
        isLoading: false, driveContents: null, error: error);
  }
}

/// Selected, Unselected
class FileSelectionState {
  final Map<String, String> selectedFile;

  FileSelectionState({@required this.selectedFile});

  factory FileSelectionState.selected(Map<String, String> selected) {
    return FileSelectionState(selectedFile: selected);
  }

  factory FileSelectionState.unSelected() {
    return FileSelectionState(selectedFile: null);
  }
}

class DriveClient extends http.BaseClient {
  Map<String, String> _headers;

  DriveClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      send(request..headers.addAll(_headers));

  @override
  Future<http.Response> head(Object url, {Map<String, String> headers}) =>
      head(url, headers: headers..addAll(_headers));
}
