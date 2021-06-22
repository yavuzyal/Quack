import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;


class ResetPasswordScreen extends StatefulWidget {
  final String token;
  ResetPasswordScreen(this.token);
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

bool validatePassword(String pw)
{
  String  pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$';
  RegExp regExp = new RegExp(pattern);
  return regExp.hasMatch(pw);
}

Future<String> changePassword (String password, String token) async{
  //print(email);
  print(password);
  print(token);
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/api/auth/password/reset");
  final response = await http.put(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "password": password,
        "resetPasswordToken": token,
      }
      )
  );
  final body = jsonDecode(response.body);
  print(body);
  if (body["success"])
    return "success";
  return body["error"];
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  final passBox = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: passBox,
      validator: (value) {
        if (!validatePassword(value))
          return "Password must contain minimum eight characters,\n at least one uppercase letter, one lowercase letter\n and one number";
        return null;
      },
      decoration: InputDecoration(
        icon: Icon(
          Icons.lock,
          color: Colors.black,
        ),
        hintText: "Enter your password",
      ),
    );

    final confirmPasswordField = TextFormField(
      autofocus: false,
      validator: (value) {
        if (value.isEmpty)
        {
          return "Confirmation password cannot be blank.";
        }
        else if (value != passBox.text)
        {
          return "Passwords do not match.";
        }
        return null;
      },
      obscureText: true,
      decoration: InputDecoration(
        icon: Icon(
          Icons.lock,
          color: Colors.black,
        ),
        hintText: "Confirm your password",
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
                    passwordField,
                    SizedBox(height: 20),
                    confirmPasswordField,
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ignore: deprecated_member_use
                        FlatButton.icon(
                          onPressed: () async {
                            if (formKey.currentState.validate())
                            {
                              String msg = await changePassword(passBox.text, widget.token);
                              if (msg == "success")
                                {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text("Password is changed successfully.")));
                                  Navigator.popUntil(context, ModalRoute.withName('/login'));
                                }

                              else
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(msg)));
                            }
                          },
                          icon: Icon(Icons.reset_tv),
                          label: Text(
                              "Reset Password",
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
      ),);
  }
}
