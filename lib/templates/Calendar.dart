import 'package:flutter/material.dart';
import 'package:polytable/calendar/flutter_calendar.dart';

class BottomCalendar extends StatefulWidget {
  BottomCalendar({Key key}) : super(key: key);

  final double heightHidden  = 96;
  final double heightOpened = 200;

  @override
 _BottomCalendarState createState() => _BottomCalendarState();
}

class _BottomCalendarState extends State<BottomCalendar> {
  double _currentHeight = 96;

  void _changeHeight () {
    print("Before: $_currentHeight");
    setState(() {
      _currentHeight = (_currentHeight == widget.heightHidden) ? widget.heightOpened : widget.heightHidden;
    });
    print("After $_currentHeight");
  }

  @override
  Widget build(BuildContext context) {

    Widget content = GestureDetector(
      onTap: _changeHeight,
      child: Container(
          height: _currentHeight,
          child: Calendar(
            isExpandable: true,
          )
      ),
    );

    return content;
  }

}
