import 'dart:convert';

import 'dart:typed_data';

import 'app_drive_api/v3.dart' as drive;
import 'app_drive_api/clients.dart' as clients;
import 'app_drive_api/requests.dart' as requests;
import 'package:flutter/foundation.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
//show BaseRequest, IOClient, Response, StreamedResponse;

import 'dart:convert' show json;
import 'dart:io' as io;

class DriveHelper {
  DriveClient _driveClient;
  drive.DriveApi _driveApi;

  DriveHelper({@required Map<String, String> headers}) {
    _driveClient = new DriveClient(headers);
    _driveApi = new drive.DriveApi(new http.Client(), headers);
  }

  Future<drive.FileList> listAppDataFiles() async {
    drive.FileList list = await _driveApi.files.list(
        spaces: 'appDataFolder',
        $fields: 'files(id, name, parents)',
        pageSize: 10);
    return list;
  }

  Future<List<int>> _getBytes(String text) async {
    return text.codeUnits;
  }

  Future<drive.File> createAppDataFile(String title, String content) async {
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
      print('Failed to upload file: ' + e);
    });
    return createdFile;
  }

  // TODO try this out tomorrow. Will need to adjust UI widgets first.
  Future getAppDataFile({@required String fileId}) async {
    requests.Media download = await _driveApi.files
        .get(fileId, downloadOptions: requests.DownloadOptions.FullMedia);
    return download;
  }

  Future<drive.File> updateAppDataFile({@required drive.File appDataFile}) {}

  Future watchAppDataFile({@required String fileId}) {
    // TODO this may need to be implemented in native code.
    // Can be done later. Can use pull-to-update for now.
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
