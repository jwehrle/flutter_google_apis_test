import 'dart:core';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class Task {
  static const String ID = 'id';
  static const String CREATED = 'created';
  static const String START = 'start';
  static const String END = 'end';
  static const String NAME = 'name';
  static const String DESCRIPTION = 'description';
  static const String COMPLETED = 'completed';
  static const String NOTIFICATIONS = 'notifications';
  static const String TAGS = 'tags';

  String _id; // Set by Google Drive.
  DateTime created;
  DateTime start;
  DateTime end;
  String name;
  String description;
  bool completed;
  List<String> notifications;
  List<String> tags;

  Task(
      {@required this.created,
      @required this.start,
      @required this.end,
      @required this.name,
      @required this.description,
      @required this.completed,
      @required this.notifications,
      @required this.tags});

  Task.fromJson(Map<String, dynamic> json)
      : _id = json[ID],
        created = DateTime.parse(json[CREATED]),
        start = DateTime.parse(json[START]),
        end = DateTime.parse(json[END]),
        name = json[NAME],
        description = json[DESCRIPTION],
        completed = json[COMPLETED],
        notifications = json[NOTIFICATIONS],
        tags = json[TAGS];

  Map<String, dynamic> toJson() => {
        CREATED: created.toIso8601String(),
        START: start.toIso8601String(),
        END: end.toIso8601String(),
        NAME: name,
        DESCRIPTION: description,
        COMPLETED: completed,
        NOTIFICATIONS: notifications,
        TAGS: tags
      };

  String toJsonString() {
    return json.encode(toJson());
  }

  String get id => _id;

  set id(String id) {
    _id = id;
  }
}
