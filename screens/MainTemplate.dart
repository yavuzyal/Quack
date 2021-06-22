import 'dart:convert';
import 'dart:io';

import 'package:cs308_project/entity/PageItem.dart';
import 'package:cs308_project/globals/GlobalVariables.dart';
import 'package:cs308_project/screens/HomeScreen.dart';
import 'package:cs308_project/screens/ProductScreen.dart';
import 'package:cs308_project/screens/ProfileScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'CartScreen.dart';

AndroidNotificationChannel channel;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class Template extends StatefulWidget{
  TemplateHome createState() => TemplateHome();
}

Future<PageItem> getProductForProductPage(String id) async {
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/product/" + id);
  dynamic response;
  if (isLoggedIn)
  {
    response = await http.get(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader : "Bearer " + accessToken,
      },
    );
  }
  else {
    response = await http.get(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }
  final body = jsonDecode(response.body);
  //print(body);
  return PageItem.fromJson(body);
}

class TemplateHome extends State<Template> {

  int currentIndex = 0;
  @override
  void initState() {
    super.initState();
    keepLoggedIn();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        //print(message);
        //Navigator.pushNamed(context, '/');
      }
    });

    FirebaseMessaging.instance.subscribeToTopic('discount').then((value) =>
    {});

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //print("on message listen");
      RemoteNotification notification = message.notification;
      //AndroidNotification android = message.notification?.android;
      String title = notification.title;
      String body = notification.body;
      String productId = message.data['productId'];
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              backgroundColor: Colors.white,
              title: Text(
                  title,
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Heebo',
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,),
              content: Container(
                height: 400,
                width: 400,
                child: FutureBuilder(
                      future: getProductForProductPage(productId),
                      builder: (context, snapshot) {
                        PageItem item = snapshot.data;
                        if (snapshot.hasData)
                        {
                          return Container(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Image(
                                    width: 200,
                                    height: 200,
                                    image: NetworkImage(item.imageURL),
                                  ),
                                  SizedBox(height: 5,),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      body,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: 'Heebo',
                                      ),
                                    ),
                                  ),
                                  // ignore: deprecated_member_use
                                  FlatButton.icon(
                                    label: Text("Go to Product"),
                                    icon: Icon(Icons.arrow_forward_ios),
                                    color: Colors.amber,
                                    shape: RoundedRectangleBorder
                                      (side: BorderSide(
                                        color: Colors.black,
                                        width: 3,
                                        style: BorderStyle.solid
                                    ), borderRadius: BorderRadius.circular(10)
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => ProductScreen(productId))); //CALISMAZSA BURAYA BAK.
                                    },
                                  ),
                                  // ignore: deprecated_member_use
                                  FlatButton.icon(
                                    label: Text("OK"),
                                    icon: Icon(Icons.thumb_up),
                                    color: Colors.amber,
                                    shape: RoundedRectangleBorder
                                      (side: BorderSide(
                                        color: Colors.black,
                                        width: 3,
                                        style: BorderStyle.solid
                                    ), borderRadius: BorderRadius.circular(10)
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        else return Container();
                      },
                  ),
              ),
              );
          });

    });
    //onLaunch and onResume
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      String id = message.data['productId'];
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductScreen(id)));
    });

  }

  final List<Widget> _children = [
    HomeScreen(),
    CartScreen(),
    ProfilePage(),
  ];


  keepLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('loggedIn') != null ? prefs.getBool('loggedIn') : false;
      accessToken = prefs.getString('access') != null ? prefs.getString('access') : "";
      nonLoggedInItems = prefs.getStringList('notLoginItems') != null ? prefs.getStringList('notLoginItems') : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "QUACK",
          style: TextStyle(
              fontSize: 36.0,
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
        centerTitle: false,
        backgroundColor: Colors.grey[900],
        actions: <Widget>[
          // ignore: deprecated_member_use
          isLoggedIn ? FlatButton.icon(
          onPressed: () async{
          isLoggedIn = false;
          accessToken = "";
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('access', accessToken);
          prefs.setBool('loggedIn', isLoggedIn);
          setState(() {
            currentIndex = 0;
          });
          Navigator.pushNamedAndRemoveUntil(context, '/', ModalRoute.withName('/'));
          },
          icon: Icon(Icons.logout, color: Colors.amber),
          label: Text(
          "Log Out",
          style: TextStyle(
            fontSize: 16.0,
            letterSpacing: 1.0,
            color: Colors.amber,
            fontFamily: 'Heebo',
              ),
          ),
            color: Colors.grey[900],
  // ignore: deprecated_member_use
  ) : FlatButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            icon: Icon(Icons.login_sharp, color: Colors.amber,),
            label: Text(
                "Login",
                style: TextStyle(
                  fontSize: 18.0,
                  letterSpacing: 1.0,
                  color: Colors.amber,
                  fontFamily: 'Heebo',
                )
            ),
            color: Colors.grey[900],
          ),
        ],
        automaticallyImplyLeading: false,
      ),

      body: _children[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex, // new
        type : BottomNavigationBarType.fixed,
        iconSize: 30,
        backgroundColor: Colors.grey[900],
        elevation: 25.0,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home, color: Colors.amber,),
            // ignore: deprecated_member_use
            title: new Text('Home', style: TextStyle(color: Colors.amber,
              fontFamily: 'Heebo',),),
            backgroundColor: Colors.amber,
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.shopping_bag_rounded, color: Colors.amber,),
            // ignore: deprecated_member_use
            title: new Text('Basket', style: TextStyle(color: Colors.amber,
              fontFamily: 'Heebo',),),
            backgroundColor: Colors.orange,
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.amber,),
              // ignore: deprecated_member_use
              title: Text('Profile', style: TextStyle(color: Colors.amber,
                fontFamily: 'Heebo',),),
            backgroundColor: Colors.blue,
          )
        ],
          onTap: (index){
            setState((){
              currentIndex = index;
            });
          }
      ),
    );
  }
}

