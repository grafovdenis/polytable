import 'package:flutter/material.dart';

class Lesson extends StatefulWidget {
  const Lesson(
      {this.title,
      this.type,
      this.time_start,
      this.time_end,
      this.teachers,
      this.teacher,
      this.places,
      this.place});

  final String title;
  final String type;
  final String time_start;
  final String time_end;
  final List<String> teachers;
  final String teacher;
  final List<String> places;
  final String place;

  @override
  _LessonState createState() => new _LessonState();
}

class _LessonState extends State<Lesson> {
  @override
  Widget build(BuildContext context) {
    return new Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
                child: (widget.title != null)
                    ? Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: TextStyle(fontSize: 18.0),
                      )
                    : Text("")),
            Container(
                child: (widget.type != null)
                    ? Text(
                        widget.type,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: TextStyle(fontSize: 14.0, color: Colors.blue),
                      )
                    : Text("")),
            Container(
              child: (widget.time_start != null && widget.time_end != null)
                  ? Text(
                      widget.time_start + " - " + widget.time_end,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontSize: 14.0),
                    )
                  : Text(""),
            ),
            Container(
                child: (widget.teacher != null)
                    ? Text(
                        widget.teacher,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: TextStyle(fontSize: 14.0),
                      )
                    : Text("")),
            Container(
                child: (widget.place != null)
                    ? Text(
                        widget.place,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: TextStyle(fontSize: 14.0),
                      )
                    : Text("")),
          ],
        ),
      ),
    );
  }
}
