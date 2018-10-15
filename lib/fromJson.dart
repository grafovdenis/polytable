import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:polytable/Lesson.dart';

Future<Post> fetchPost() async {
  final response =
      await http.get('http://ruz2.spbstu.ru/api/v1/ruz/scheduler/27264');

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return Post.fromJson(json.decode(utf8.decode(response.bodyBytes)));
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}

class Post {
  final Map<String, dynamic> week;
  final List<dynamic> days;
  final Map<String, dynamic> group;

  //final List<Map<int, String>> dayOfWeek;

  Post({this.week, this.days, this.group});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      week: json['week'],
      days: json['days'],
      group: json['group'],
    );
  }
}

class fromJson extends StatefulWidget {
  @override
  _fromJsonState createState() => new _fromJsonState();
}

class _fromJsonState extends State {
  int day = 0;

  Widget build(BuildContext context) {
    return new FutureBuilder<Post>(
      future: fetchPost(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return new Scaffold(
              appBar: AppBar(
                title: Text(snapshot.data.group['name']),
              ),
              body: InkWell(
                onTap: () {
                  if (day == snapshot.data.days.length - 1)
                    day = 0;
                  else
                    day++;
                  setState(() {});
                },
                child: ListView.builder(
                    itemCount: snapshot.data.days[day]['lessons'] == null
                        ? 0
                        : snapshot.data.days[day]['lessons'].length,
                    itemBuilder: (context, index) {
                      String teacher = (snapshot.data.days[day]['lessons']
                                  [index]['teachers'] !=
                              null)
                          ? snapshot.data.days[day]['lessons'][index]
                              ['teachers'][0]['full_name']
                          : "";
                      return new Lesson(
                          title:
                              "${snapshot.data.days[day]['lessons'][index]['subject']}",
                          type:
                              "${snapshot.data.days[day]['lessons'][index]['typeObj']['name']}",
                          time_start:
                              "${snapshot.data.days[day]['lessons'][index]['time_start']}",
                          time_end:
                              "${snapshot.data.days[day]['lessons'][index]['time_end']}",
                          teacher: teacher,
                          place: "${snapshot.data.days[day]['lessons'][index]['auditories'][0]['building']['name']}" +
                              ", " +
                              "${snapshot.data.days[day]['lessons'][index]['auditories'][0]['name']}" +
                              " каб.");
                    }),
              ));
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
}
