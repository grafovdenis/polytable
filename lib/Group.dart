import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:polytable/templates/Header.dart';
import 'package:polytable/templates/Lesson.dart';
import 'package:polytable/templates/Calendar.dart';
import 'package:polytable/data/CalendarData.dart';

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
  int page = 2;

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

    PageController pageController = PageController(initialPage: page, keepPage: true);
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
            page = 1;
            days.insert(0, day);
            buildDays.insert(0, _buildDay(day));
            pageController.jumpToPage(1);
          });
        } else if (index == buildDays.length - 1) {
          Day day = await widget.calendar.get(widget.calendar.getDateKey(days[days.length - 1].date.add(Duration(days: 1))));
          setState(() {
            page = index;
            days.add(day);
            buildDays.add(_buildDay(day));
          });
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
