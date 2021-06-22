import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart';

class RefundScreen extends StatefulWidget {
  final String pId, oId;
  const RefundScreen(this.pId, this.oId);

  @override
  _RefundScreenState createState() => _RefundScreenState();
}

// ignore: non_constant_identifier_names
Future<String> Refund(String pId, String oId, String text) async {
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/order/return");
  final response = await http.post(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader : "Bearer " + accessToken,
      },
      body: jsonEncode(<String, dynamic>{
        "productId": pId,
        "orderId": oId,
        "reasoning": text,
      })
  );
  final body = jsonDecode(response.body);
  //print(body);
  if (body['success'])
    return "Refund request is sent successfully.";
  else
    return body['error'];
}

class _RefundScreenState extends State<RefundScreen> {

  final refundBox = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "Refund",
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: "Heebo",
                fontSize: 20.0),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(20, 75, 20, 0),
              child: Column(
                children: [
                  Text(
                    "We would like to know why you want to refund.",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Heebo",
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: TextFormField(
                      autofocus: false,
                      controller: refundBox,
                      maxLines: 3,
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.settings_backup_restore,
                          color: Colors.black,
                        ),
                        hintText: "Write your reasoning here...",
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // ignore: deprecated_member_use
                  FlatButton.icon(
                    onPressed: () async{
                      if (refundBox.text != "")
                      {
                        //print(ratingToSend);
                        String result = await Refund(widget.pId, widget.oId, refundBox.text);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(result)));
                        Navigator.pop(context);
                      }
                      else
                      {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Please provide explanation.')));
                      }
                    },
                    icon: Icon(Icons.settings_backup_restore_outlined),
                    label: Text(
                        "Refund",
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
            ),
          ),
        )
    );
  }
}
