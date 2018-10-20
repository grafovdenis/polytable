import 'package:flutter/material.dart';
import 'package:polytable/group.dart';

class SearchResult extends StatelessWidget {
  const SearchResult({this.name, this.faculty_abbr});

  final String name;
  final String faculty_abbr;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => new group(name)));
        },
        title: Text(name),
        subtitle: (faculty_abbr != null) ? Text(faculty_abbr) : Text(""),
      ),
    );
  }
}
