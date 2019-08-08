import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:buscador_gifs/ui/GifPage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  String _search;
  String src = "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif";
  int _offset;
  
  _getSearch() async {
    http.Response response;

    if( _search == null ) {
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=IHH6iXMg2iuKlA1m2ou6v8Zyf81DK51m&limit=20&rating=G");
    } else {
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=IHH6iXMg2iuKlA1m2ou6v8Zyf81DK51m&q=$_search&limit=19&offset=$_offset&rating=G&lang=en");
    }

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getSearch().then((map) {
      print(map);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
          backgroundColor: Colors.black,
          title: Image.network(src),
          centerTitle: true,
       ),
       
       backgroundColor: Colors.black,
       
       body: Column(
         children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                onSubmitted: (text){
                  setState(() {
                    _search = text;
                    _offset = 0;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Pesquise Aqui!",
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white
                    )
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white
                    )
                  )
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18
                ),
                textAlign: TextAlign.center
              )
            ),

          Expanded(
            child: FutureBuilder(
              future: _getSearch(),
              builder: (context, snapshot){
                switch (snapshot.connectionState){
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Container(
                      width: 150,
                      height: 150,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if( snapshot.hasError ){
                      return Container();
                    } else {
                      return _createGifTable( context, snapshot );
                    }
                }
              }
            ),
          ),

         ],
       ),
    );
  }

  int _getCount(List data) {
    if( _search == null ) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable( BuildContext context, AsyncSnapshot snapshot ) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: ( context, index ){
        if( _search == null || index < snapshot.data["data"].length ) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              fit: BoxFit.cover,
              height: 300
            ),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute( builder: (context) => GifPage(snapshot.data["data"][index]) )
              );
            },
            onLongPress: (){
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
          );
        } else {
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 50,
                  ),
                  Text(
                    "Carregar mais...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  )
                ],
              ),
              onTap: (){
                setState(() {
                  _offset += 19;
                });
              }
            )
          );
        }
      },
    );
  }
}