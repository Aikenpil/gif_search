import "package:flutter/material.dart";
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search = "";

  _getGif() async{
    http.Response response;
    if(_search == null){
      response = await http.get(Uri.parse("https://giphy.com/trending-gifs"));
    } else {
      response = await http.get(Uri.parse("https://giphy.com/_search"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}