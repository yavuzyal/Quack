import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

// ignore: non_constant_identifier_names
Future<bool> RegisterFunction (String name, String email, String password, String taxID) async{
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/api/auth/register");
  print(name + email + password + taxID);
  final response = await http.post(
    apiURL,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
      body: jsonEncode(<String, String>{
      "fullname": name,
      "email": email,
      "password": password,
      "taxID": taxID,
        "cart" : "[]",
      }
    )
  );
  final body = jsonDecode(response.body);
  print(body);
  return body["success"];
}

bool validatePassword(String pw)
{
  String  pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$';
  RegExp regExp = new RegExp(pattern);
  return regExp.hasMatch(pw);
}

class _RegisterScreenState extends State<RegisterScreen> {

  String nameSurname, email, password, address, taxID, answer;
  String question = "";

  final nameBox = TextEditingController();
  final emailBox = TextEditingController();
  final passBox = TextEditingController();
  final answerBox = TextEditingController();
  final taxIDBox = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    final nameField = TextFormField(
      autofocus: false,
      controller: nameBox,
      validator: (text) {
        if (text.isEmpty)
          return "Name and surname cannot be blank.";
        return null;
      },
      onSaved: (value) => nameSurname = value,
      decoration: InputDecoration(
        icon: Icon(
          Icons.person,
          color: Colors.black,
        ),
        hintText: "Enter your name and surname",
      ),
    );

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



    final taxIDField = TextFormField(
      autofocus: false,
      controller: taxIDBox,
      validator: (text) {
        if (text.isEmpty) {
          return "Tax ID cannot be blank.";
        }
        else if (int.tryParse(text) == null || text[0] == '0' || text.length != 11)
          {
            return "Tax ID must be a 11-digit integer";
          }
        return null;
      },
      onSaved: (value) => taxID = value,
      decoration: InputDecoration(
        icon: Icon(
          Icons.monetization_on_sharp,
          color: Colors.black,
        ),
        hintText: "Enter your tax ID",
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
                    SizedBox(height: 20.0),
                    nameField,
                    SizedBox(height: 5.0),
                    emailField,
                    SizedBox(height: 5.0),
                    passwordField,
                    SizedBox(height: 5.0),
                    confirmPasswordField,
                    SizedBox(height: 5.0),
                    taxIDField,
                    SizedBox(height: 20.0),
                    //auth.registeredInStatus == Status.Registering
                        //? loading
                        // longButtons("Register", doRegister),
                    // ignore: deprecated_member_use
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ignore: deprecated_member_use
                        FlatButton.icon(
                          onPressed: () async {
                            if (formKey.currentState.validate())
                              {
                                nameSurname = nameBox.text;
                                email = emailBox.text;
                                password = passBox.text;
                                taxID = taxIDBox.text;
                                bool isRegistered = await RegisterFunction(nameSurname, email, password, taxID);
                                if (isRegistered)
                                {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text('Registration Successful.')));
                                  Navigator.pop(context);
                                }
                                else
                                {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text('An error has occurred.')));
                                }

                              }
                            },
                          icon: Icon(Icons.how_to_reg),
                          label: Text(
                            "SIGN UP",
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
                    SizedBox(height: 5.0),
                    //forgotLabel
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
