import 'dart:convert';
import 'package:uuid/uuid.dart';

class Change {
  static const String CHANGE_ID_KEY = 'change_id';
  static const String ACTION_KEY = 'action';
  static const String FILE_ID_KEY = 'file_id';
  static const String CREATED_AT_KEY = 'created_at';
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
  static const String RENAMED = 'renamed';
  static const String UPDATED_AND_RENAMED = 'update_rename';

  String changeID;
  String action;
  String fileID;
  String createdAt;

  Change(action, fileID) {
    this.action = action;
    this.fileID = fileID;
    changeID = Uuid().v4();
    createdAt = DateTime.now().toIso8601String();
  }

  Change.fromJson(Map<String, dynamic> json)
      : changeID = json[CHANGE_ID_KEY],
        action = json[ACTION_KEY],
        fileID = json[FILE_ID_KEY],
        createdAt = json[CREATED_AT_KEY];

  Map<String, dynamic> toJson() => {
        CHANGE_ID_KEY: changeID,
        ACTION_KEY: action,
        FILE_ID_KEY: fileID,
        CREATED_AT_KEY: createdAt
      };

  String toJsonString() {
    return json.encode(toJson());
  }
}
