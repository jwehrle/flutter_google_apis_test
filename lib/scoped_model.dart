//import 'package:googleapis/drive/v3.dart';
import 'app_drive_api/v3.dart';
import 'app_drive_api/clients.dart' as clients;
import 'app_drive_api/requests.dart' as requests;
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
//show BaseRequest, IOClient, Response, StreamedResponse;

import 'drive_helper.dart';

class MainModel extends Model {
  FileList fileList;

  requests.Media selected;
  File selectedFile;
  //DriveHelper driveHelper;
  DriveApi _driveApi;
//  Map<String, String> headers;
//  _DriveClient _client;

//  void setDriveHelper(DriveHelper driveHelper) {
//    this.driveHelper = driveHelper;
//  }

  void setAuthHeaders(Map<String, String> headers) {
    _driveApi = new DriveApi(new http.Client(), headers);
  }

  void getFilesFromDrive() {
    _driveApi.files
        .list(spaces: 'appDataFolder', $fields: 'files(id, name)', pageSize: 10)
        .then((fileList) {
      this.fileList = fileList;
      print('AppDataFiles has size of: ' + fileList.toString());
      notifyListeners();
    });

//    driveHelper.listAppDataFiles().then((fileList) {
//      this.fileList = fileList;
//      print('AppDataFiles has size of: ' + fileList.toString());
//      notifyListeners();
//    });
//        .then((FileList fileList) {
//      this.fileList = fileList;
//      notifyListeners();
//    }, onError: (e) {
//      notifyListeners();
//      print(e);
//    });
  }

  void setFileList(FileList fileList) {
    this.fileList = fileList;
    notifyListeners();
  }

  void selectFile(File file) {
    selectedFile = file;
    notifyListeners();
  }

  File getSelectedFile() {
    return selectedFile;
  }

  void setSelectedFie(int index) {
    if (fileList.files == null) {
      return;
    }
    if (fileList.files.length <= index) {
      return;
    }
    selectedFile = fileList.files[index];
    notifyListeners();
  }

  void setSelected(requests.Media select) {
    selected = select;
    notifyListeners();
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
