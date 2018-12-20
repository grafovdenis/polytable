import 'package:flutter/material.dart';
import 'package:polytable/templates/Header.dart';

class Profile extends StatefulWidget {
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: Header(), body: Container());
  }
}
