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
  final List<dynamic> teachers;
  final String teacher;
  final List<dynamic> places;
  final String place;

  @override
  _LessonState createState() => new _LessonState();
}

class _LessonState extends State<Lesson> {
  @override
  Widget build(BuildContext context) {
    Color typeColor() {
      switch (widget.type) {
        case "Лекции":
          return Colors.green;
          break;
        case "Лабораторные":
          return Colors.blue;
          break;
        case "Практика":
          return Colors.blue[400];
          break;
        default:
          return Colors.red[400];
          break;
      }
    }

    return (widget.title != null)
        ? new Card(
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
                              style:
                                  TextStyle(fontSize: 14.0, color: typeColor()),
                            )
                          : Text("")),
                  Container(
                    child:
                        (widget.time_start != null && widget.time_end != null)
                            ? Text(
                                widget.time_start + " - " + widget.time_end,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.clip,
                                style: TextStyle(fontSize: 14.0),
                              )
                            : Text(""),
                  ),
                  Container(
                      child: (widget.teachers.toString() != "[]")
                          ? Text(
                              (widget.teachers.length == 2)
                                  ? [
                                      widget.teachers[0]['name'],
                                      widget.teachers[1]['name']
                                    ].join(",\n")
                                  : widget.teachers[0]['name'],
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              style: TextStyle(fontSize: 14.0),
                            )
                          : Text("")),
                  Container(
                      child: (widget.places.toString() != "[]")
                          ? Text(
                              (widget.places.length == 2)
                                  ? [
                                      widget.places[0]['name'],
                                      widget.places[1]['name']
                                    ].join(",\n")
                                  : widget.places[0]['name'],
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              style: TextStyle(fontSize: 14.0),
                            )
                          : Text("")),
                ],
              ),
            ),
          )
        : new Container(width: 0.0, height: 0.0);
  }
}
