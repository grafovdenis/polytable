import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:polytable/Constants.dart';
import 'package:polytable/fromJson.dart';
import 'package:polytable/templates/Header.dart';

class profile extends StatefulWidget {
  @override
  profileState createState() => profileState();
}

class profileState extends State {
  void choiceAction(String choice) {
    if (choice == Constants.Group) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => fromJson()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(choiceAction: choiceAction),
        body: new Calendar(
          isExpandable: true,
        ));
  }
}
