import 'package:cs308_project/screens/ResetPasswordScreen.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

Future<String> sendPassCode (String email) async{
  //print(email);
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/api/auth/password/forgot");
  final response = await http.post(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "email": email,
      }
      )
  );
  final body = jsonDecode(response.body);
  //print(body);
  if (body["success"])
      return "Your pass code is emailed to you.";
    return body["error"];
}

Future<String> verifyCode (String email, String passCode, PrimitiveWrapper token) async{
  //print(email);
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/api/auth/password/reset/verify");
  final response = await http.post(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "email": email,
        "passcode": passCode,
      }
      )
  );
  final body = jsonDecode(response.body);
  //print(body);
  if (body["success"])
  {
    token.value = body['resetPasswordToken'];
    return "success";
  }
  return body["error"];
}

class PrimitiveWrapper {
  var value;
  PrimitiveWrapper(this.value);
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final formKey = GlobalKey<FormState>();
  final emailBox = TextEditingController();
  final passcodeBox = TextEditingController();
  String email, passcode, passToken;

  @override
  Widget build(BuildContext context) {
    var passToken = new PrimitiveWrapper("");
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
        hintText: "Enter your email.",
      ),
    );

    final passcodeField = TextFormField(
      autofocus: false,
      controller: passcodeBox,
      onSaved: (value) => passcode = value,
      decoration: InputDecoration(
        icon: Icon(
          Icons.vpn_key,
          color: Colors.black,
        ),
        hintText: "Enter the pass code you received.",
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
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ignore: deprecated_member_use
                        FlatButton.icon(
                          onPressed: () async {
                            if (formKey.currentState.validate())
                            {
                              String msg = await sendPassCode(emailBox.text);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(msg)));
                            }
                          },
                          icon: Icon(Icons.send),
                          label: Text(
                              "Send Pass Code",
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
                    SizedBox(height: 10,),
                    Text(
                        "Note that pass codes are valid for 10 minutes.",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Heebo',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),),
                    SizedBox(height: 10.0),
                    passcodeField,
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ignore: deprecated_member_use
                        FlatButton.icon(
                          onPressed: () async {
                            if (passcodeBox.text != "" && emailBox.text != "")
                            {
                              String msg = await verifyCode(emailBox.text, passcodeBox.text, passToken);
                              if (msg == "success")
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                    builder: (_) => ResetPasswordScreen(passToken.value)));
                              else
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(msg)));
                            }
                            else
                            {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text("Please fill the fields.")));
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
