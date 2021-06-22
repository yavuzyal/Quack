import 'dart:convert';
import 'dart:io';

import 'package:cs308_project/entity/User.dart';
import 'package:cs308_project/globals/GlobalVariables.dart';
import 'package:cs308_project/screens/AboutUsScreen.dart';
import 'package:cs308_project/screens/AddAddressScreen.dart';
//import 'package:cs308_project/screens/CreditCardKnownScreen.dart';
import 'package:cs308_project/screens/LoginScreen.dart';
import 'package:cs308_project/screens/PastOrdersScreen.dart';
import 'package:cs308_project/screens/UserEditScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart' as globals;

import 'ShowAddressScreen.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

Future<User> getUserInfo () async {
  User myUser;
  //List<User> temp = [];
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/api/auth/getUserById");
  final response = await http.get(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader : "Bearer " + globals.accessToken,
      }
  );
  final body = jsonDecode(response.body);
  //print(body["data"]);
  //print(body);

  if (body["status"] == true) {
    myUser = User.fromJson(body["data"]);
    //temp.add(myUser);
    return myUser;
  }
  return null;
}

class _ProfilePageState extends State<ProfilePage> {
  User currentUser;

  // ignore: non_constant_identifier_names
  void RefreshPage() async {
    User updatedUser = await getUserInfo();
    currentUser = updatedUser;
    setState(() {
      currentUser = updatedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff9f9f9),
      body: !isLoggedIn ?
      Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/nologin-profile-background.jpg"),
                fit: BoxFit.cover,
              )
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 130.0),
                // ignore: deprecated_member_use
                FlatButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LoginScreen()));
                  },
                  icon: Icon(Icons.login_sharp),
                  label: Text(
                      "GO TO LOGIN PAGE",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: 'Heebo',
                      )
                  ),
                  color: Colors.amber,
                  shape: RoundedRectangleBorder
                    (side: BorderSide(
                      color: Colors.black,
                      width: 3,
                      style: BorderStyle.solid
                  ), borderRadius: BorderRadius.circular(0)
                  ),
                ),
              ],
            ),
          )
      )
          :
      FutureBuilder(
          future: getUserInfo(),
          builder:(context, snapshot) {
            if (snapshot.hasData)
            {
              currentUser = snapshot.data;
              return SafeArea(
                top: true,
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                    EdgeInsets.only(left: 16.0, right: 16.0, top: kToolbarHeight),
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          maxRadius: 56,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage("assets/images/pp.jpg"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            currentUser.fullName,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                        ),
                        Divider(thickness: 5, color: Colors.amber),
                        ListTile(
                          title: Text('User Information', style: TextStyle(fontSize: 18),),
                          subtitle: Text('Personal Information', style: TextStyle(fontSize: 15),),
                          leading: Icon(Icons.account_circle, size: 35),//Image.asset('assets/icons/settings_icon.png', fit: BoxFit.scaleDown, width: 30, height: 30,),
                          trailing: Icon(Icons.chevron_right, size:24, ), //color: Colors.amber
                          onTap: ()=> Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => AddUserPage())).then((value) => RefreshPage()),
                        ),
                        Divider(thickness: 2, color: Colors.amber),
                        ListTile(
                          title: Text('Address' , style: TextStyle(fontSize: 18),),
                          subtitle: Text('Select address',style: TextStyle(fontSize: 15),),
                          leading: Icon(Icons.home, size: 35,),//Image.asset('assets/icons/settings_icon.png', fit: BoxFit.scaleDown, width: 30, height: 30,),
                          trailing: Icon(Icons.chevron_right, size: 24,),
                          onTap: () async{
                            if(currentUser.address == null) {
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => AddAddressPage())).then((value) => RefreshPage());
                            }
                            else {
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => ShowAddress())).then((value) => RefreshPage());
                            }
                          },
                        ),
                        Divider(thickness: 2, color: Colors.amber),
                        ListTile(
                          title: Text('Orders', style: TextStyle(fontSize: 18),),
                          subtitle: Text('My previous orders', style: TextStyle(fontSize: 15),),
                          leading: Icon(Icons.local_shipping,size: 35, ),//Image.asset('assets/icons/settings_icon.png', fit: BoxFit.scaleDown, width: 30, height: 30,),
                          trailing: Icon(Icons.chevron_right, size: 24,),
                          onTap: ()=> Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => PastOrders())),
                        ),
                        Divider(thickness: 2, color: Colors.amber),
                        ListTile(
                          title: Text('About Quack', style: TextStyle(fontSize: 18),),
                          subtitle: Text('Who are we?', style: TextStyle(fontSize: 15),),
                          leading: Icon(Icons.face,size: 35, ),//Image.asset('assets/icons/settings_icon.png', fit: BoxFit.scaleDown, width: 30, height: 30,),
                          trailing: Icon(Icons.chevron_right, size: 24,),
                          onTap: ()=> Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => AboutUs())),
                        ),
                        Divider(thickness: 2, color: Colors.amber),
                      ],
                    ),
                  ),
                ),
              );
            }
            else return Center(child: CircularProgressIndicator());
          }
      ),
    );
  }
}