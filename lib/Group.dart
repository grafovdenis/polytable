import 'package:flutter/material.dart';
import 'package:polytable/templates/Header.dart';
import 'package:polytable/templates/Lesson.dart';
import 'package:polytable/data/CalendarData.dart';
import 'package:polytable/calendar/flutter_calendar.dart';

class Group extends StatefulWidget {
  final String name;

  Group({this.name});

  @override
  _GroupState createState() => new _GroupState();
}

class _GroupState extends State<Group> {
  var currentWeekday = new DateTime.now().weekday - 1;
  CalendarData calendar;
  List<Widget> buildDays = List();
  List<Day> days = List();
  bool loaded = false;
  int page = 2;

  initState() {
    calendar = CalendarData(widget.name);
  }

  Widget build(BuildContext context) {
    if (!loaded) {
      calendar.load().then((data) {
        setState(() {
          data.forEach((day) {
            days.add(day);
            buildDays.add(_buildDay(day));
          });
          loaded = true;
        });
      });
      return Scaffold(
        appBar: Header(),
        backgroundColor: Colors.green,
        body: LinearProgressIndicator(),
      );
    } else
      return _buildDays();
  }

  _buildDays({AsyncSnapshot<List<Day>> snapshot}) {
    if (snapshot != null)
      snapshot.data.forEach((day) {
        days.add(day);
        buildDays.add(_buildDay(day));
      });

    PageController pageController = PageController(initialPage: page, keepPage: true);
    Calendar calendar = Calendar(
      onDateSelected: (DateTime date) async {
        List<Day> days = await this.calendar.getAcross(date);
        setState(() {
          this.days = List();
          this.buildDays = List();
          days.forEach((day) {
            this.days.add(day);
            buildDays.add(_buildDay(day));
            pageController.jumpToPage(2);
          });
        });
      },
    );
    PageView pageView = PageView.builder(
      itemCount: buildDays.length,
      itemBuilder: (BuildContext context, int index) {
        return buildDays[index];
      },
      controller: pageController,
      onPageChanged: (index) async {
        print("Before jump > ${pageController.offset}");
        if (index == 0) {
          Day day = await this.calendar.get(this.calendar.getDateKey(days[0].date.subtract(Duration(days: 1))));
          setState(() {
            page = 1;
            days.insert(0, day);
            buildDays.insert(0, _buildDay(day));
            pageController.jumpToPage(1);
            calendar.setDate(days[1].date);
          });
        } else if (index == buildDays.length - 1) {
          Day day = await this.calendar.get(this.calendar.getDateKey(days[days.length - 1].date.add(Duration(days: 1))));
          setState(() {
            page = index;
            days.add(day);
            buildDays.add(_buildDay(day));
          });
          calendar.setDate(days[index].date);
        } else {
          print("No update needded, index $index of ${buildDays.length}");
          calendar.setDate(days[index].date);
        }
        print("After jump > ${pageController.offset}");

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
      bottomNavigationBar: calendar
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
                            homework: day[lesson].homework,
                          );
                      }),
                ),
        ],
      ),
    );
  }
}
