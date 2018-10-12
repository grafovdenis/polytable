import 'package:flutter/material.dart';
import 'dart:math';

import 'package:polytable/Constants.dart';
import 'package:polytable/fromJson.dart';
import 'package:polytable/profile.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Polytable',
      theme: ThemeData(
        primaryColor: Colors.green,
      ),
      home: new MyHomePage(title: 'Polytable'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void choiceAction(String choice) {
    if (choice == Constants.Profile) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => profile()));
    } else if (choice == Constants.Group) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => fromJson()));
    }
  }

  //TODO Добавить рарки
  final phrases = new List.from([
    "Ищешь свою пару?",
    "Не падаем!",
    "Сегодня физра в 8?",
    "У пас пара, возможно лаба, по коням!",
    "Осталась пара вопросов",
    "Закройте окно!",
    "С легкой парой!",
    "Запарная неделя!"
  ]);

  void _findGroups(String group) {
    //TODO Поиск по groups.json
    print(group);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Color.fromRGBO(16, 93, 59, 1.0),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromRGBO(16, 93, 59, 1.0),
        actions: <Widget>[
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.account_circle,
                  size: 40.0,
                ),
                onSelected: choiceAction,
                itemBuilder: (BuildContext context) {
                  return Constants.choices.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ),
          )
        ],
      ),
      //TODO Сделать общий Header
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                children: <Widget>[
                  InkWell(
                    child: Image(
                      image: new AssetImage('assets/images/biglogo.png'),
                      width: 300.0,
                    ),
                    onTap: () {
                      setState(() {});
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
                        phrases[new Random().nextInt(phrases.length)],
                        style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: new TextField(
                onSubmitted: _findGroups,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Группа",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
