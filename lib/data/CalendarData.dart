import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class CalendarData {
  static final String POLYTABLE_API_URL = "https://polytable.ru/action.php?action=calendar&group=";

  static final DateFormat _dateFormat = DateFormat("yyyy-MM-dd");
  static final MethodChannel _channel = MethodChannel("polytable.flutter.io/week");

  final String groupName;
  int staticStartWeek;

  DateTime _timetableStart;
  DateTime _timetableEnd;
  DateTime _staticStart;
  DateTime _staticEnd;

  Week _odd;
  Week _even;
  Map<String, Day> _dynamic = Map();
  Map<String, Day> _ready = Map();

  CalendarData(String groupName) : this.groupName = groupName;

  Future<List<Day>> load () async {
    await http.get("$POLYTABLE_API_URL$groupName").then((response) async {
      Map<String, dynamic> res = json.decode(utf8.decode(response.bodyBytes))['data'];
      _timetableStart = DateTime.parse(res['timetable_start']);
      _timetableEnd = DateTime.parse(res['timetable_end']);
      _staticStart = DateTime.parse(res['static_start']);
      _staticEnd = DateTime.parse(res['static_end']);
      staticStartWeek = await getWeek(res['static_start']);
      _even = Week(res["static"][0]);
      _odd = Week(res['static'][1]);
      try {
        _dynamic = (res['dynamic'] as Map<String, dynamic>).map((key, day) =>
            MapEntry(key, Day.static(day)));
      } catch (e) {
        print("Dynamic cache not present");
      }
    }).catchError((e) => print(e));
    DateTime now = DateTime.now();
    return [
      await this.get(_dateFormat.format(now.subtract(Duration(days: 1)))),
      await this.get(_dateFormat.format(now)),
      await this.get(_dateFormat.format(now.add(Duration(days: 1))))
    ];
  }

  Future<Day> get(String key) async {
    if (_ready.containsKey(key))
      return _ready[key];
    else {
      DateTime date = DateTime.parse(key);
      bool isOdd =  (await getWeek(key) - staticStartWeek) % 2 == 0;
      int dateInt = date.millisecondsSinceEpoch;
      if (dateInt >= _timetableStart.millisecondsSinceEpoch && dateInt <= _timetableEnd.millisecondsSinceEpoch) {
        if (dateInt >= _staticStart.millisecondsSinceEpoch && dateInt <= _staticEnd.millisecondsSinceEpoch) {
          Map<int, LessonData> lessons = Map();
          if (_dynamic.containsKey(key))
            lessons.addAll(_dynamic[key].lessons.asMap().map((key, value) => MapEntry(value.lesson, value)));
          lessons.addAll(((isOdd) ? _odd : _even)
              .days[date.weekday - 1]
              .lessons
              .where((lesson) => !lessons.containsKey(lesson.lesson))
              .toList().asMap()
              .map((key, value) => MapEntry(value.lesson, value)));
          lessons.removeWhere((key, lesson) => lesson.erase);
          return _ready[key] = Day(lessons, date, isOdd);
        } else
          if (_dynamic.containsKey(key))
            return _ready[key] = _dynamic[key];
      }
    }
    return _ready[key] = Day.empty();
  }

  static Future<int> getWeek(String date) async {
    int weekday = -1;

    await _channel.invokeMethod("getWeekNumber", <String, String>{
      "date" : date
    }).then((v) => weekday = v);

    return weekday;
  }

}

class Week {
    List<Day> days = List();
    Week(Map<String, dynamic> days) { days.values.forEach((day) => this.days.add(Day.static(day))); }

    operator [](int key) => days[key];
}

class Day {
  static final DateFormat _dateFormat = DateFormat("yyyy-MM-dd");

  List<LessonData> lessons;
  DateTime date;
  String dateKey;
  int weekday;
  bool isOdd;

  Day (Map<int, LessonData> lessons, DateTime date, bool isOdd) {
    this.lessons = List();
    lessons.values.forEach((lesson) => this.lessons.add(lesson));
    this.date = date;
    this.dateKey = _dateFormat.format(date);
    this.isOdd = isOdd;
    this.weekday = date.weekday;
  }
  Day.static(dynamic lessons) {
    this.lessons = List();
    (((lessons is Map) ? (lessons as Map<String, dynamic>).values : lessons) as Iterable<dynamic>)
        .forEach((lesson) => this.lessons.add(LessonData(lesson)));
  }
  Day.empty() {
    this.lessons = [];
  }

  LessonData operator [](int key) => lessons[key];
}

class LessonData {
  bool isOdd;
  int lesson;
  int weekday;
  String subject;
  String type;
  String timeStart;
  String timeEnd;
  List<Teacher> teachers;
  List<Building> places;

  bool erase = false;

  LessonData(Map<String, dynamic> json) {
    this.isOdd = (json['is_odd'] == "0") ? false : true;
    this.lesson = int.parse(json['lesson']);
    this.weekday = int.parse(json['weekday']);
    this.subject = json['subject'];
    this.type = json['type'];
    this.timeStart = json['time_start'];
    this.timeEnd = json['time_end'];
    this.teachers = List<Teacher>();
    (json['teachers'] as List<dynamic>).forEach((teacherData) => this.teachers.add(Teacher(teacherData)));
    this.places = List<Building>();
    (json['places'] as List<dynamic>).forEach((place) => this.places.add(Building(place)));

    this.erase = (json.containsKey('action') && json['action'] == "ERASE");
  }
}

class Building {
  String name;
  int buildingId;
  int roomId;

  Building(Map<String, dynamic> json) {
    this.name = json['name'];
    this.buildingId = json['building_id'];
    this.roomId = json['room_id'];
  }
}

class Teacher {
  String name;
  int id;

  Teacher(Map<String, dynamic> json) {
    this.name = json['name'];
    this.id = json['id'];
  }
}
