import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

bool validatePassword(String pw)
{
  String  pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$';
  RegExp regExp = new RegExp(pattern);
  return regExp.hasMatch(pw);
}

// ignore: non_constant_identifier_names
Future<bool> LoginFunction (String email, String password, List<String> items, PrimitiveWrapper loginResponse) async{
  // ignore: deprecated_member_use
  List<Map<String, dynamic>> toSend = new List<Map<String, dynamic>>();
  for (String item in items)
  {
    Map<String, dynamic> itemMap = new Map<String, dynamic>();
    String key1 = item.substring(item.indexOf('{') + 1, item.indexOf(':'));
    String newItem = item.substring(item.indexOf(':')+2);
    String value1 = newItem.substring(0, newItem.indexOf(','));
    newItem = newItem.substring(newItem.indexOf(',')+2);
    String key2 = newItem.substring(0, newItem.indexOf(':'));
    String value2 = newItem.substring(newItem.indexOf(':')+2, newItem.indexOf('}'));
    itemMap[key1] = value1;
    itemMap[key2] = value2;
    toSend.add(itemMap);
  }
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/api/auth/login");
  final response = await http.post(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "email": email,
        "password": password,
        "cart": toSend,
      }
      )
  );
  final body = jsonDecode(response.body);
  //print(response.headers['set-cookie']);
  if (body["success"])
  {
    globals.accessToken = body["accessToken"];
    //globals.cookie = response.headers['set-cookie'];
    globals.cookie = Cookie.fromSetCookieValue(response.headers['set-cookie']).value;
    print(globals.cookie);
    //print(globals.cookie);
    globals.isLoggedIn = true;
    globals.nonLoggedInItems.clear();
    //print(body);
    return body["success"];
  }
  else{
    loginResponse.value = body["error"];
    return body["success"];
  }

}

class PrimitiveWrapper {
  var value;
  PrimitiveWrapper(this.value);
}

class _LoginScreenState extends State<LoginScreen> {

  String email, password;
  final emailBox = TextEditingController();
  final passBox = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var loginResponse = new PrimitiveWrapper("");

  @override
  Widget build(BuildContext context) {

    final emailField = TextFormField(
      autofocus: false,
      controller: emailBox,
      validator: (text) {
        if (!EmailValidator.validate(text))
          return "Enter a valid email address.";
        return null;
      },
      onSaved: (value) => email = value,
      decoration: InputDecoration(
        icon: Icon(
          Icons.email,
          color: Colors.black,
        ),
        hintText: "Enter your email",
      ),
    );

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: passBox,
      validator: (value) {
        if (!validatePassword(value))
          return "Password must contain minimum eight characters,\n at least one uppercase letter, one lowercase letter\n and one number";
        return null;
      },
      onSaved: (value) => password = value,
      decoration: InputDecoration(
        icon: Icon(
          Icons.lock,
          color: Colors.black,
        ),
        hintText: "Enter your password",
      ),
    );

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/registerBackground.jpg"),
              fit: BoxFit.cover,
            )
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(40.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                    ],
                  ),
                    SizedBox(height: 100.0),
                    emailField,
                    SizedBox(height: 20.0),
                    passwordField,
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgotPassword');
                            },
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'Heebo',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[900],
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.black,
                                decorationThickness: 2.5,
                              ),
                            ))
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ignore: deprecated_member_use
                        FlatButton.icon(
                          onPressed: () async {
                            if (formKey.currentState.validate())
                            {
                              email = emailBox.text;
                              password = passBox.text;
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              List<String> idQuantityList = prefs.getStringList('notLoginItems') != null ? prefs.getStringList('notLoginItems') : [];
                              bool isLoginSuccessful = await LoginFunction(email, password, idQuantityList, loginResponse);
                              if (isLoginSuccessful)
                              {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text('Login Successful.')));
                                prefs.setString('access', globals.accessToken);
                                prefs.setBool('loggedIn', globals.isLoggedIn);
                                prefs.setStringList('notLoginItems', globals.nonLoggedInItems);
                                Navigator.pushNamedAndRemoveUntil(context, '/', ModalRoute.withName('/'));
                              }
                              else
                              {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(loginResponse.value.toString())));
                              }
                            }
                          },
                          icon: Icon(Icons.login_sharp),
                          label: Text(
                              "LOGIN",
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
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ignore: deprecated_member_use
                        FlatButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          icon: Icon(Icons.app_registration),
                          label: Text(
                              "REGISTER",
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
