import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart' as globals;

class AddAddressPage extends StatefulWidget {

  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

Future<bool> addAddress (String address) async{
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/api/auth/addAddress");
  final response = await http.put(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader : "Bearer " + globals.accessToken,
      },
      body: jsonEncode(<String, String>{
        "address": address,
      }
      )
  );
  final body = jsonDecode(response.body);
  return body["success"];
}

class _AddAddressPageState extends State<AddAddressPage> {

  String houseNumber, street, postalCode, district, city;
  String question = "";

  final houseNumberBox =  TextEditingController();
  final streetBox =  TextEditingController();
  final postalCodeBox =  TextEditingController();
  final districtBox =  TextEditingController();
  final cityBox =  TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text(
          "Address",
          style: TextStyle(
              color: Colors.black),),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: LayoutBuilder(
        builder: (_, viewportConstraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
            BoxConstraints(minHeight: viewportConstraints.maxHeight),
            child: Container(
              padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: MediaQuery.of(context).padding.bottom == 0
                      ? 20
                      : MediaQuery.of(context).padding.bottom),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height:20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'House Information',
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
                      child: TextFormField(
                        validator: (value){
                          if (value.isEmpty)
                          {
                            return "Cannot leave blank!";
                          }
                          else if(int.tryParse(value) == null){
                            return "Please enter an integer!";
                          }
                          return null;
                        },
                        controller: houseNumberBox,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'Flat Number/House Number'),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Colors.white,
                      ),
                      child: TextFormField(
                        controller: streetBox,
                        validator: (text){
                          if (text.isEmpty)
                          {
                            return "Cannot leave blank!";
                          }
                          return null;
                        },
                        decoration:
                        InputDecoration(border: InputBorder.none, hintText: 'Street'),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Area Information',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                      child: Container(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          //border: Border(bottom: BorderSide(color: Colors.red, width: 1)),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          controller: postalCodeBox,
                          validator: (value){
                            if (value.isEmpty)
                            {
                              return "Cannot leave blank!";
                            }
                            else if(int.tryParse(value) == null){
                              return "Please enter an integer!";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: 'Postal code'),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                      child: Container(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          //border: Border(bottom: BorderSide(color: Colors.red, width: 1)),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          controller: districtBox,
                          validator: (value){
                            if (value.isEmpty)
                            {
                              return "Cannot leave blank!";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: 'District'),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                      child: Container(
                        padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                        decoration: BoxDecoration(
                          //border: Border(bottom: BorderSide(color: Colors.red, width: 1)),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          controller: cityBox,
                          validator: (value){
                            if (value.isEmpty)
                            {
                              return "Cannot leave blank!";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: 'City'),
                        ),
                      ),
                    ),
                    // ignore: deprecated_member_use
                    SizedBox(height:10),
                    // ignore: deprecated_member_use
                    RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          child: Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.grey[900],
                              fontSize: 18,
                            ),
                          ),
                        ),
                        color: Colors.amber,
                        onPressed: () async{
                          if (formKey.currentState.validate()){
                            String address = houseNumberBox.text + ", " + streetBox.text + ", " + postalCodeBox.text + " - " + districtBox.text + "/" + cityBox.text;
                            //print(address);
                            bool result = await addAddress(address);
                            if (result)
                              ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('Address has been updated.')));
                            else
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('Could not add address.')));
                            Navigator.pop(context);
                          }
                          else print("I cannot do that");
                        }
                    )
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