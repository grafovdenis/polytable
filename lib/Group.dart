import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:polytable/templates/Header.dart';
import 'package:polytable/templates/Lesson.dart';
import 'package:polytable/templates/Calendar.dart';

Future<Post> fetchPost(String name) async {
  var url = 'https://polytable.ru/action.php?action=calendar&group=';
  final response = await http.get(url + Uri.encodeComponent(name));

  if (response.statusCode == 200) {
    var res = json.decode(utf8.decode(response.bodyBytes));
    // If server returns an OK response, parse the JSON
    return Post.fromJson(res);
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}

class Post {
  final String groupName;
  final List<Map<String, dynamic>> weeks;

  //final List<Map<int, String>> dayOfWeek;

  Post({this.groupName, this.weeks});

  factory Post.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> week0 = new Map();
    Map<String, dynamic> week1 = new Map();
    Map<String, dynamic> days0 = json['data']['static'][0];
    Map<String, dynamic> days1 = json['data']['static'][1];

    void arraysToMaps(key, value, week) {
      var day = (value is Map)
          ? value
          : Map.fromIterable(value,
              key: (object) => object['lesson'], value: (object) => object);
      week.putIfAbsent(("$key"), () => day);
    }

    days0.forEach((key, value) => arraysToMaps(key, value, week0));
    days1.forEach((key, value) => arraysToMaps(key, value, week1));
    return Post(
      groupName: "33531/1",
      weeks: List.of([week0, week1]),
    );
  }
}

class Group extends StatefulWidget {
  const Group({this.name});

  final String name;

  @override
  _GroupState createState() => new _GroupState();
}

class _GroupState extends State<Group> {
  var currentWeekday = new DateTime.now().weekday - 1;

  Widget build(BuildContext context) {
    return new FutureBuilder<Post>(
      future: fetchPost(widget.name),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildDays(snapshot);
        } else if (snapshot.hasError)
          return Text("${snapshot.error}");
        else
          return Scaffold(
            appBar: Header(),
            backgroundColor: Colors.green,
            body: LinearProgressIndicator(),
          );
      },
    );
  }

  _buildDays(AsyncSnapshot<Post> snapshot) {
    List<Widget> buildDays = List();
    for (int i = 1; i <= 7; i++) {
      buildDays.add(_buildDay(snapshot, 0, i));
    }
    for (int i = 1; i <= 7; i++) {
      buildDays.add(_buildDay(snapshot, 1, i));
    }
    return Scaffold(
      appBar: Header(
        title: Center(
            child: Text(
          widget.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
      ),
      body: PageView(
        children: buildDays,
        controller: PageController(initialPage: currentWeekday),
      ),
      bottomNavigationBar: BottomCalendar()
    );
  }

  _buildDay(AsyncSnapshot<Post> snapshot, int week, int day) {
    var weekday = {
      1: "Понедельник",
      2: "Вторник",
      3: "Среда",
      4: "Четверг",
      5: "Пятница",
      6: "Суббота",
      7: "Воскресенье"
    };
    return Container(
      color: Colors.green[400],
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "${(week == 0) ? "Чётная неделя:" : "Нечётная неделя:"}\n${weekday[day]}",
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70),
            ),
          ),
          (snapshot.data.weeks[week]['$day'] == null)
              ? Container(
                  padding: EdgeInsets.only(top: 30.0),
                  alignment: Alignment.center,
                  child: Text(
                    "Похоже, что это выходной.\n*счастье*",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    style: TextStyle(fontSize: 30.0, color: Colors.white),
                  ),
                )
              : Flexible(
                  child: ListView.builder(
                      itemCount: snapshot.data.weeks[week].length,
                      itemBuilder: (context, lesson) {
                        if (snapshot.data.weeks[week]['$day']['$lesson'] !=
                            null) {
                          Map<String, dynamic> les =
                              snapshot.data.weeks[week]['$day']['$lesson'];
                          return Lesson(
                            title: les['subject'],
                            type: les['type'],
                            time_start: les['time_start'],
                            time_end: les['time_end'],
                            teachers: les['teachers'],
                            places: les['places'],
                          );
                        } else
                          return Lesson();
                      }),
                ),
        ],
      ),
    );
  }
}
