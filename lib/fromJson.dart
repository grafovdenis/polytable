import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:polytable/main.dart';

Future<Post> fetchPost() async {
  final response = await http
      .get('http://ruz2.spbstu.ru/api/v1/ruz/scheduler/26639?date=2018-10-8');

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return Post.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}

class Post {
  // ignore: non_constant_identifier_names
  final List<String> week;
  final List<String> days;
  final String group;

  // ignore: non_constant_identifier_names
  Post({this.week, this.days, this.group});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(group: json['group']['name']);
  }
}

class fromJson extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Polytable',
      theme: new ThemeData(
        primaryColor: Color.fromARGB(255, 66, 165, 245),
      ),
      home: Scaffold(
        appBar: new AppBar(
          leading: InkWell(
            child: Icon(Icons.arrow_back),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyHomePage()));
            },
          ),
          title: FutureBuilder<Post>(
            future: fetchPost(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(child: Text(snapshot.data.group + " <= JSON"));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner
              return CircularProgressIndicator();
            },
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.account_circle),
            )
          ],
        ),
        body: Container(
          color: Colors.green,
          child: FutureBuilder<Post>(
            future: fetchPost(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(
                  child: Column(
                    children: <Widget>[
                      Material(
                        child: Container(
                          height: 100.0,
                          color: Colors.blueGrey,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                print('I was tapped!');
                              },
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.hotel),
                                  ),
                                  Image.network(
                                      "https://polytable.ru/assets/images/logo3.png"),
                                  Center(
                                    child: Text(
                                      'Hello!',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
