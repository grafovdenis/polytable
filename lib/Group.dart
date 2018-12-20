import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:polytable/templates/Header.dart';
import 'package:polytable/templates/Lesson.dart';
import 'package:polytable/templates/Calendar.dart';
import 'package:polytable/data/CalendarData.dart';

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
    print(json['data']['static'] is List);

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
  final CalendarData calendar;
  final String name;

  Group({this.name}) : calendar = CalendarData(name);

  @override
  _GroupState createState() => new _GroupState();
}

class _GroupState extends State<Group> {
  var currentWeekday = new DateTime.now().weekday - 1;
  List<Widget> buildDays = List();
  List<Day> days = List();
  bool loaded = false;


  Widget build(BuildContext context) {
    if (!loaded) {
      return new FutureBuilder<List<Day>>(
        future: widget.calendar.load(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            loaded = true;
            return _buildDays(snapshot: snapshot);
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
    } else {
      return _buildDays();
    }
  }

  _buildDays({AsyncSnapshot<List<Day>> snapshot}) {
    if (snapshot != null)
      snapshot.data.forEach((day) {
        days.add(day);
        buildDays.add(_buildDay(day));
      });

    PageController pageController = PageController(initialPage: 1);
    PageView pageView = PageView.builder(
      itemCount: buildDays.length,
      itemBuilder: (BuildContext context, int index) {
        return buildDays[index];
      },
      controller: pageController,
      onPageChanged: (index) async {
        if (index == 0) {
          Day day = await widget.calendar.get(widget.calendar.getDateKey(days[0].date.subtract(Duration(days: 1))));
          setState(() {
            days.insert(0, day);
            buildDays.insert(0, _buildDay(day));
            //pageController.animateToPage(1, duration: Duration(microseconds: 500), curve: Curves.easeInOut);
          });

        } else if (index == buildDays.length - 1) {

        } else {
          print("No update needded, index $index of ${buildDays.length}");
        }
      },
    );
    
    
    return Scaffold(
      appBar: Header(
        title: Center(
            child: Text(
          widget.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
      ),
      body: pageView,
      bottomNavigationBar: BottomCalendar()
    );
  }

  _buildDay(Day day) {
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
              "${(!day.isOdd) ? "Чётная неделя:" : "Нечётная неделя:"}\n${weekday[day.weekday]}(${day.dateKey})",
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70),
            ),
          ),
          (day.lessons.isEmpty)
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
                      itemCount: day.lessons.length,
                      itemBuilder: (context, lesson) {
                          return Lesson(
                            title: day[lesson].subject,
                            type: day[lesson].type,
                            time_start: day[lesson].timeStart,
                            time_end: day[lesson].timeEnd,
                            teachers: day[lesson].teachers,
                            places: day[lesson].places,
                          );
                      }),
                ),
        ],
      ),
    );
  }
}
