import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:polytable/templates/Header.dart';
import 'package:polytable/templates/Lesson.dart';

Future<Post> fetchPost() async {
  final response = await http
      .get('https://polytable.ru/action.php?action=calendar&group=33531%2F2');

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

class WeekFromAPI extends StatefulWidget {
  @override
  _weekFromAPIState createState() => new _weekFromAPIState();
}

class _weekFromAPIState extends State {
  Widget build(BuildContext context) {
    return new FutureBuilder<Post>(
      future: fetchPost(),
      builder: (context, snapshot) {
        var weekday = [
          {1: "Понедельник"},
          {2: "Вторник"},
          {3: "Среда"},
          {4: "Четверг"},
          {5: "Пятница"},
          {6: "Суббота"},
        ];
        if (snapshot.hasData) {
          return new Scaffold(appBar: Header(), body: _buildDays(snapshot));
        } else if (snapshot.hasError)
          return Text("${snapshot.error}");
        else
          return Container(
            height: 100.0,
            child: LinearProgressIndicator(
              backgroundColor: Colors.green,
            ),
          );
      },
    );
  }

  _buildDays(AsyncSnapshot<Post> snapshot) {
    return PageView(
      children: <Widget>[
        _buildDay(snapshot, 0, 1),
        _buildDay(snapshot, 0, 2),
        _buildDay(snapshot, 0, 3),
        _buildDay(snapshot, 0, 4),
        _buildDay(snapshot, 0, 5),
        _buildDay(snapshot, 0, 6),
        _buildDay(snapshot, 1, 1),
        _buildDay(snapshot, 1, 2),
        _buildDay(snapshot, 1, 3),
        _buildDay(snapshot, 1, 4),
        _buildDay(snapshot, 1, 5),
        _buildDay(snapshot, 1, 6),
      ],
    );
  }

  _buildDay(AsyncSnapshot<Post> snapshot, int week, int day) {
    return Container(
      color: (week == 0) ? Colors.purple : Colors.blue,
      child: ListView.builder(
          itemCount: (snapshot.data.weeks[week]['$day'] == null)
              ? 1
              : snapshot.data.weeks[week].length,
          itemBuilder: (context, lesson) {
            if (snapshot.data.weeks[week]['$day'] == null) {
              return Card(
                child: Text(
                  "ВЫХОДНОЙ",
                  style: TextStyle(fontSize: 30.0),
                ),
              );
            }
            if (snapshot.data.weeks[week]['$day']['$lesson'] != null) {
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
    );
  }
}
