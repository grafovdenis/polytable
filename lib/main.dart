import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:polytable/Constants.dart';
import 'package:polytable/Group.dart';
import 'package:polytable/templates/Header.dart';
import 'package:polytable/templates/SearchResult.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  //TODO fix navigation
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
  static var context;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void choiceAction(String choice) {
    if (choice == Constants.Group) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => new Group(name: "33531/1")));
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

  List<SearchResult> results = new List();

  void _findGroups(String group) async {
    results = List();
    final String url = "https://polytable.ru/search.php?query=";
    String query = url + group.trim();
    final response = await http.get(query);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      List<dynamic> res = json.decode(utf8.decode(response.bodyBytes));
      res.forEach((element) => results.add(new SearchResult(
          name: res[res.indexOf(element)]['name'],
          faculty_abbr: res[res.indexOf(element)]['faculty_abbr'])));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Color.fromRGBO(16, 93, 59, 1.0),
      appBar: Header(
        choiceAction: choiceAction,
        elevation: 0.0,
      ),
      body: new ListView(
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0, bottom: 30.0),
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
          SizedBox(
            //TODO задать относительный размер
            height: 240.0,
            child: ListView(
              children: results,
            ),
          )
        ],
      ),
    );
  }
}
