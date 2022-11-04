import 'dart:convert';
import 'dart:io';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:gif_search/gif_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gif_search/gif_page.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var _apiKey = dotenv.env['APIKEY'];
  String _search = "";
  int _offset = 0;

  int _getCount(List data){
    if (_search == null){
      return data.length ;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
        padding: EdgeInsets. all (10.0) ,
        gridDelegate : SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing : 10.0,
            mainAxisSpacing: 10.0
        ),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index){
          if(_search == null || index < snapshot.data["data"].length)
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder : kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"], height : 300.0, fit : BoxFit.cover,
            ),
            onTap: (){
               Navigator.push(context,
                 MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))
               );
            },
          );
          else return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.white, size: 70.0),
                  Text("More", style: TextStyle(color: Colors.white, fontSize: 22.0))
                ],
              ),
              onTap: (){
                setState(() {
                  _offset += 25;
                });
              },
              onLongPress: (){
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);;
              },
            ),
          );
    });
  }

  Future<Map> _getGif() async{
    http.Response response;
    if(_search == ''){
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/trending?"+"$_apiKey"+"&limit=25&offset=$_offset&rating=r"));
    } else {
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/search?"+"$_apiKey"+"&q=$_search&limit=25&offset=$_offset&rating=r&lang=en"));
    }
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network('https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search Here",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(width:3, color: Colors.white))
              ),
              style: TextStyle(color: Colors.white, fontSize: 15.0),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
              child: FutureBuilder(
                future: _getGif(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    switch(snapshot.connectionState){
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        return SingleChildScrollView(
                          child: Container(
                              width: 200.0,
                              height : 200.0,
                              alignment: Alignment.center,
                              child : CircularProgressIndicator (
                                valueColor : AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 5.0,
                              )
                          ),
                        );
                        default:
                          if(snapshot.hasError) return Container();
                          else return _createGifTable(context, snapshot);
                    }
                  },
              ),
          )
        ],
      ),
    );
  }
}