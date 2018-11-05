import 'package:flutter_google_apis_test/app_drive_api/v3.dart' as drive;
import 'package:flutter_google_apis_test/app_drive_api/requests.dart'
    as requests;

class DriveController {
  static Future<drive.FileList> getMetaFileList(drive.DriveApi driveApi) async {
    return await driveApi.files.list(
        spaces: 'appDataFolder', $fields: 'files(id, name)', pageSize: 10);
  }

  static Future<Map<String, drive.File>> getMetaFiles(
      drive.DriveApi driveApi) async {
    drive.FileList fileList = await driveApi.files.list(
        spaces: 'appDataFolder', $fields: 'files(id, name)', pageSize: 10);
    Map<String, drive.File> metaMap = Map();
    for (var meta in fileList.files) {
      metaMap[meta.id] = meta;
    }
    return metaMap;
  }

  static Future<String> getFileContents(
      drive.DriveApi driveApi, String id) async {
    requests.Media mediaFile = await driveApi.files
        .get(id, downloadOptions: requests.DownloadOptions.FullMedia);
    return await _getStringFromStream(mediaFile.stream);
  }

  static Future<String> _getStringFromStream(Stream<List<int>> stream) async {
    List<int> byteArray = [];
    await for (var b in stream) {
      byteArray = b;
    }
    return String.fromCharCodes(byteArray);
  }

  static Future<drive.File> createFile(
      drive.DriveApi driveApi, String name, String content) async {
    drive.File createdFile = new drive.File();
    createdFile.name = name;
    createdFile.parents = ['appDataFolder'];
    createdFile.mimeType = 'application/json';
    var media = requests.Media(
        Stream.fromFuture(_getBytes(content)), content.codeUnits.length);
    createdFile = await driveApi.files.create(createdFile,
        uploadMedia: media,
        $fields: 'id, name, parents',
        useContentAsIndexableText: true);
    return createdFile;
  }

  static Future<List<int>> _getBytes(String text) async {
    return text.codeUnits;
  }

  static Future<dynamic> deleteFile(drive.DriveApi driveApi, String id) async {
    return driveApi.files.delete(id);
  }

  static Future<drive.File> updateFileContents(
      drive.DriveApi driveApi, drive.File file, String content) async {
    var media = requests.Media(
        Stream.fromFuture(_getBytes(content)), content.codeUnits.length);
    driveApi.files
        .update(file, file.id,
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
}
