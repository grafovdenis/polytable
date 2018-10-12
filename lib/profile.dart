import 'package:flutter/material.dart';
import 'package:polytable/Header.dart';

class profile extends StatefulWidget {
  @override
  profileState createState() => profileState();
}

class profileState extends State {
  Widget header;

  profile() {
    this.header = Header();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Profile")),
        body: Center(child: Text("Hi there")));
  }
}
