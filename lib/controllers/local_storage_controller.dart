import 'package:flutter_google_apis_test/models/event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_google_apis_test/app_drive_api/v3.dart' as drive;
import 'dart:convert';

class StorageController {
  static const String FILE_CONTENT_PREFIX = 'content_';
  static const String FILE_META_PREFIX = 'meta_';
  static const String TASK_PREFIX = 'task_';
  static const String TAG_PREFIX = 'tag_';
  static const String CHANGE_LOG = 'change_log';

  static StorageController _instance;

  StorageController._();

  static StorageController getInstance() {
    if (_instance == null) {
      _instance = StorageController._();
    }
    return _instance;
  }

  bool containsTag(SharedPreferences pref, String id) {
    Set<String> keys = pref.getKeys();
    return keys.contains(TAG_PREFIX + id);
  }

  bool containsTask(SharedPreferences pref, String id) {
    Set<String> keys = pref.getKeys();
    return keys.contains(TASK_PREFIX + id);
  }

  bool containsMeta(SharedPreferences pref, String id) {
    Set<String> keys = pref.getKeys();
    return keys.contains(FILE_META_PREFIX + id);
  }

  bool containsContent(SharedPreferences pref, String id) {
    Set<String> keys = pref.getKeys();
    return keys.contains(FILE_CONTENT_PREFIX + id);
  }

  List<String> getAllTags(SharedPreferences pref) {
    Set<String> keys = pref.getKeys();
    List<String> tags = [];
    keys.forEach((id) {
      if (id.startsWith(TAG_PREFIX)) {
        tags.add(pref.getString(id));
      }
    });
    return tags;
  }

  List<Task> getIntersectionTaggedTasks(
      SharedPreferences pref, List<String> tagList) {
    List<Task> tasks = [];

    Set<String> allUniqueTagIds = Set();

    Map<String, Set<String>> allTagMap = Map();

    for (String tag in tagList) {
      List<String> taggedIds = getTaggedIds(pref, tag);
      for (String id in taggedIds) {
        allUniqueTagIds.add(id);
        allTagMap[tag].add(id);
      }
    }

    Set<String> intersection = Set.from(allUniqueTagIds);

    for (String uniqueId in allUniqueTagIds) {
      allTagMap.forEach((tag, idSet) {
        if (!idSet.contains(uniqueId)) {
          intersection.remove(uniqueId);
        }
      });
    }

    for (String id in intersection) {
      tasks.add(getTask(pref, id));
    }

    return tasks;
  }

  Future<List<Task>> getUnionTaggedTasks(
      SharedPreferences pref, List<String> tagList) async {
    List<Task> tasks = [];
    for (String tag in tagList) {
      List<Task> taggedTasks = await getTaggedTasks(pref, tag);
      if (taggedTasks != null) {
        tasks.addAll(taggedTasks);
      }
    }
    return tasks;
  }

  List<Task> getTaggedTasks(SharedPreferences pref, String tag) {
    List<String> taggedIds = getTaggedIds(pref, tag);
    List<Task> taggedTasks = [];
    for (String tid in taggedIds) {
      Task task = getTask(pref, tid);
      if (task != null) {
        taggedTasks.add(task);
      }
    }
    return taggedTasks;
  }

  void putTag(SharedPreferences pref, String tag, List<String> taggedIds) {
    pref.setStringList(TAG_PREFIX + tag, taggedIds);
  }

  List<String> getTaggedIds(SharedPreferences pref, String tag) {
    return pref.getStringList(TAG_PREFIX + tag);
  }

  void putTask(SharedPreferences pref, String id, Task task) {
    String jsonString = json.encode(task.toJson());
    pref.setString(TASK_PREFIX + id, jsonString);
  }

  Task getTask(SharedPreferences pref, String id) {
    String jsonString = pref.getString(TASK_PREFIX + id) ?? '';
    if (jsonString.isEmpty) {
      return null;
    }
    return Task.fromJson(json.decode(jsonString));
  }

  void deleteTask(SharedPreferences pref, String id) {
    pref.remove(TASK_PREFIX + id);
  }

  void deleteTag(SharedPreferences pref, String id) {
    pref.remove(TAG_PREFIX + id);
  }

  void deleteMeta(SharedPreferences pref, String id) {
    pref.remove(FILE_META_PREFIX + id);
  }

  void deleteContent(SharedPreferences pref, String id) {
    pref.remove(FILE_CONTENT_PREFIX + id);
  }

  void putFileContent(SharedPreferences pref, String id, String content) {
    pref.setString(FILE_CONTENT_PREFIX + id, content);
  }

  String getFileContent(SharedPreferences pref, String id) {
    String content = pref.getString(FILE_CONTENT_PREFIX + id);
    if (content == null) {
      return null;
    }
    return pref.getString(FILE_CONTENT_PREFIX + id);
  }

  List<drive.File> getMetaFileList(SharedPreferences pref) {
    List<drive.File> metaFileList = [];
    Set<String> keys = pref.getKeys();
    for (String key in keys) {
      if (key.startsWith(FILE_META_PREFIX)) {
        metaFileList.add(drive.File.fromJson(json.decode(pref.getString(key))));
      }
    }
    return metaFileList;
  }

  void putMetaFile(SharedPreferences pref, String id, drive.File file) {
    var fileMap = file.toJson();
    String fileString = json.encode(fileMap);
    pref.setString(FILE_META_PREFIX + id, fileString);
  }

  drive.File getMetaFile(SharedPreferences pref, String id) {
    String metaString = pref.getString(FILE_META_PREFIX + id);
    if (metaString == null) {
      return null;
    }
    if (metaString.isEmpty) {
      return new drive.File();
    }
    return drive.File.fromJson(json.decode(metaString));
  }
}
