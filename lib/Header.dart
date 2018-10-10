import 'package:flutter/material.dart';

class Header extends AppBar {
  Widget build(BuildContext context) {
    return new AppBar(
      elevation: 0.0,
      backgroundColor: Color.fromRGBO(16, 93, 59, 1.0),
      actions: <Widget>[
        InkWell(
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
          onTap: () {
            print("Profile icon tapped");
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Icon(
              Icons.account_circle,
              size: 40.0,
              color: Colors.green,
            ),
          ),
        )
      ],
    );
  }
}