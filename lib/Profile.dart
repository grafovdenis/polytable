import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:polytable/templates/Header.dart';

class Profile extends StatefulWidget {
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(),
        body: new Calendar(
          isExpandable: true,
        ));
  }
}
