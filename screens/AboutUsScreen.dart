import 'dart:convert';
import 'dart:io';

import 'package:cs308_project/entity/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart' as globals;
import 'AddAddressScreen.dart';
import 'package:url_launcher/url_launcher.dart';


class AboutUs extends StatefulWidget {
  @override
  about createState() => about();
}

class about extends State<AboutUs> {
  final String lat = "25.3622";
  final String lng = "86.0835";

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      color: Colors.amber,
      border: Border.all(
          width: 2.0
      ),
      borderRadius: BorderRadius.all(
          Radius.circular(30.0)
      ),
    );
  }
  BoxDecoration myBoxDecoration2() {
    return BoxDecoration(
      color: Colors.black,
      border: Border.all(
          color: Colors.amber,
          width: 2.0
      ),
      borderRadius: BorderRadius.all(
          Radius.circular(0)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
            return Scaffold(
                appBar: AppBar(
                  iconTheme: IconThemeData(
                    color: Colors.black, //change your color here
                  ),
                  title: Text("About Us", style: TextStyle(color: Colors.black),), centerTitle: true,
                  backgroundColor: Colors.amber,
                ),
                body:
                SingleChildScrollView(
                    /*decoration: BoxDecoration(
                        image: DecorationImage(
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                          image: AssetImage("assets/images/ducks.jpg"),
                          fit: BoxFit.cover,
                        )
                    ),*/
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 15,),
                        Text(
                          "QUACK",
                          style: TextStyle(
                              fontSize: 72.0,
                              letterSpacing: 2.0,
                              //fontWeight: FontWeight.bold,
                              color: Colors.amber,
                              fontFamily: 'Heebo',
                              shadows: [
                                Shadow( // bottomLeft
                                    offset: Offset(-2, -2),
                                    color: Colors.black
                                ),
                                Shadow( // bottomRight
                                    offset: Offset(2, -2),
                                    color: Colors.black
                                ),
                                Shadow( // topRight
                                    offset: Offset(2, 2),
                                    color: Colors.black
                                ),
                                Shadow( // topLeft
                                    offset: Offset(-2, 2),
                                    color: Colors.black
                                ),
                              ]
                          ),
                        ),
                        SizedBox(height: 10,),
                        //Text("About Quack:" , textAlign: TextAlign.center,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                        Divider(thickness: 2, color: Colors.amber),
                        /*Text("\n" + "Quack is a company in love with ducks! It has been created in 2021 and dedicated to sell only the products about ducks. "
                            "It has been created by Berk Turhan, Cihan Şentürk, Dilara Müstecep, Mehmet Yavuz Yalçın, Metin Berkay Ataklı, Nilay İrem Güçin and "
                            "Zeynep Kılınç. We have all types of products about ducks, such as rubber ducks, T-shirts and figures. We also have products "
                            "for collectors, that are unique hand-craft pieces of modern art. \n"
                            , textAlign: TextAlign.center,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),*/
                        Container(
                          margin: const EdgeInsets.all(15.0),
                          padding: const EdgeInsets.all(3.0),
                          decoration: myBoxDecoration(),
                          child: Column(
                            children: [
                              Text("\n" + "Quack is a company in love with ducks! It has been created in 2021 and dedicated to sell only the products about ducks. "
                                  "It has been created by Berk Turhan, Cihan Şentürk, Dilara Müstecep, Mehmet Yavuz Yalçın, Metin Berkay Ataklı, Nilay İrem Güçin and "
                                  "Zeynep Kılınç. We have all types of products about ducks, such as rubber ducks, T-shirts and figures. We also have products "
                                  "for collectors, that are unique hand-craft pieces of modern art. \n"
                                , textAlign: TextAlign.center,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ),
                        Divider(thickness: 2, color: Colors.amber),
                        Container(
                          margin: const EdgeInsets.all(15.0),
                          padding: const EdgeInsets.all(3.0),
                          decoration: myBoxDecoration(),
                          child: Column(
                            children: [
                              Text("\n" + "Where to find us?" + "\n" + "\n"
                                  + "Orta Mahalle, Üniversite Caddesi No:27 Tuzla, 34956 İstanbul" + "\n",
                                textAlign: TextAlign.center,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), ),
                            ],
                          ),
                        ),
                        Divider(thickness: 2, color: Colors.amber),
                        SizedBox(height: 15,),
                        Text('Our Center', textAlign: TextAlign.center,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), ),
                        SizedBox(height: 15,),
                        Image.asset('assets/images/sabanj.jpg', ),

                        /*Card(
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                            side: new BorderSide(color: Colors.blue, width: 2.0),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.navigation_outlined, color: Colors.white,),

                                SizedBox(width: 5,),
                                InkWell(
                                  onTap: () {_launchURL();},
                                  child: Text('Open map',style: TextStyle(
                                      color: Colors.white
                                  ),),
                                ),
                              ],
                            ),
                          ),
                        ),*/
                      ],
                    )
                )
            );
  }
}

_launchURL() async {
  const url = "https://g.page/sabanci_universitesi?share";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_launchMap(String lat, String lng) async {
  final String googleMapsUrl = "comgooglemaps://?center=$lat,$lng";
  final String appleMapsUrl = "https://maps.apple.com/?q=$lat,$lng";

  if (await canLaunch(googleMapsUrl)) {
    await launch(googleMapsUrl);
  }
  if (await canLaunch(appleMapsUrl)) {
    await launch(appleMapsUrl, forceSafariVC: false);
  } else {
    throw "Couldn't launch URL";
  }
}
