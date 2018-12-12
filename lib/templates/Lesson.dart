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
  Container buildField(String field, Color textColor, double fontSize) {
    return Container(
        child: (field != null)
            ? Text(
                field,
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
                style: TextStyle(fontSize: fontSize, color: textColor),
              )
            : Text(""));
  }

  Container buildFields(List<dynamic> fields, double fontSize) {
    return Container(
        child: (fields.toString() != "[]")
            ? (fields.length == 2)
                ? Column(children: [
                    Text(
                      fields[0]['name'],
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontSize: fontSize),
                    ),
                    Text(
                      fields[1]['name'],
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontSize: fontSize),
                    )
                  ])
                : Text(
                    fields[0]['name'],
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    style: TextStyle(fontSize: fontSize),
                  )
            : Text(""));
  }

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
          return Colors.green;
          break;
      }
    }

    return (widget.title != null)
        ? InkWell(
            onTap: () {
              setState(() {
                print('Lesson ${widget.title} tapped');
              });
            },
            child: new Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    buildField(widget.title, Colors.black, 18.0),
                    buildField(widget.type, typeColor(), 16.0),
                    buildField(widget.time_start + " - " + widget.time_end,
                        Colors.black, 16.0),
                    buildFields(widget.teachers, 16.0),
                    buildFields(widget.places, 16.0)
                  ],
                ),
              ),
            ),
          )
        : new Container(width: 0.0, height: 0.0);
  }
}
