import 'dart:convert';
import 'dart:io';
import 'package:cs308_project/entity/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart' as globals;

Future<User> getUserInfo () async {
  User myUser;
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
    //print(body["data"]);
    return myUser;
  }
  return null;
}

Future<bool> updateUserInfo (String fullname, String email, String address) async {
  print("edit called");
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/api/auth/editInformation");
  final response = await http.put(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader : "Bearer " + globals.accessToken,
      },
      body: jsonEncode(<String, String>{
        "fullname": fullname,
        "email": email,
        "address": address,
        },
  )
  );
  final body = jsonDecode(response.body);
  //print(body);
  return body["success"];
}

// ignore: must_be_immutable
class AddUserPage extends StatefulWidget {

  // ignore: non_constant_identifier_names
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  // ignore: non_constant_identifier_names
  User current_user;
  final name =  TextEditingController();
  final email =  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'User Information',
          style: const TextStyle(color: Colors.black,),
        ),
      ),
      body: FutureBuilder(
          future: getUserInfo(),
          builder: (context, snapshot){
            current_user = snapshot.data;
            if(snapshot.hasData){
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints:BoxConstraints(//minHeight: viewportConstraints.maxHeight
                  ),
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: MediaQuery.of(context).padding.bottom == 0
                            ? 20
                            : MediaQuery.of(context).padding.bottom),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height:50),
                        SizedBox(
                          height: 400,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      'Name',
                                      style: TextStyle(fontSize: 20, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  color: Colors.white,
                                ),
                                child: TextField(
                                  controller: name,
                                  decoration: InputDecoration(
                                      border: InputBorder.none, hintText: current_user.fullName),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      'Email',
                                      style: TextStyle(fontSize: 20, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  color: Colors.white,
                                ),
                                child: TextField(
                                  controller: email,
                                  decoration:
                                  InputDecoration(border: InputBorder.none, hintText: current_user.email),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      'Tax ID',
                                      style: TextStyle(fontSize: 20, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  color: Colors.white,
                                ),
                                child: TextField(
                                  decoration:
                                  InputDecoration(border: InputBorder.none, hintText: current_user.taxID.toString(),
                                  enabled: false),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        // ignore: deprecated_member_use
                        RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              child: const Text(
                                'Update',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            color: Colors.amber,
                            onPressed: () async {
                              if(name.text == "" && email.text != ""){
                                //print("a");
                                //print(name.text);
                                //print(email.text);
                                bool result = await updateUserInfo(current_user.fullName, email.text.toString(), current_user.address);
                                if (result)
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text('Successfully updated.')));
                                else
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text('Could not update.')));
                                Navigator.pop(context);
                              }
                              else if(name.text != "" && email.text == ""){
                                //print("b");
                                //print(name.text);
                                //print(email.text);
                                bool result = await updateUserInfo(name.text.toString(), current_user.email, current_user.address);
                                if (result)
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text('Successfully updated.')));
                                else
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text('Could not update.')));
                                Navigator.pop(context);
                              }
                              else if(name.text != "" && email.text != ""){
                                //print("c " + name.text.toString() + email.text.toString());
                                bool result = await updateUserInfo(name.text.toString(), email.text.toString(), current_user.address);
                                if (result)
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text('Successfully updated.')));
                                else
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text('Could not update.')));
                                Navigator.pop(context);
                              }
                              else if(name.text == "" && email.text == ""){
                                //print("d");
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text('Please enter something to update.')));
                              }
                            }
                        )
                      ],
                    ),
                  ),
                ),
              );}
            else {
              return Center(child: CircularProgressIndicator());
            }
          }
      ),
    );
  }
}