import 'dart:convert';
import 'dart:io';

import 'package:cs308_project/entity/User.dart';
import 'package:cs308_project/screens/ShowAddressCheckout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart' as globals;

import 'AddAddressScreen.dart';

class CreditCardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CreditCardPageState();
  }
}

Future<User> getUserInfo() async {
  User myUser;
  //List<User> temp = [];
  var apiURL = Uri.parse(
      "https://protected-everglades-33662.herokuapp.com/api/auth/getUserById");
  final response = await http.get(apiURL, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    HttpHeaders.authorizationHeader: "Bearer " + globals.accessToken,
  });
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

class CreditCardPageState extends State<CreditCardPage> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  User currentUser;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            currentUser = snapshot.data;
            return Scaffold(
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                backgroundColor: Colors.amber,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.black,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                automaticallyImplyLeading: false,
                title: Text(
                  'Credit Card Information',
                  style: TextStyle(color: Colors.black),
                ),
                centerTitle: true,
              ),
              resizeToAvoidBottomInset: true,
              body: SafeArea(
                child: Column(
                  children: <Widget>[
                    CreditCardWidget(
                      cardBgColor: Colors.grey[900],
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      showBackView: isCvvFocused,
                      obscureCardNumber: true,
                      obscureCardCvv: true,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            CreditCardForm(
                              formKey: formKey,
                              onCreditCardModelChange: onCreditCardModelChange,
                              obscureCvv: true,
                              obscureNumber: true,
                              cardNumberDecoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Number',
                                hintText: 'XXXX XXXX XXXX XXXX',
                              ),
                              expiryDateDecoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Expired Date',
                                hintText: 'XX/XX',
                              ),
                              cvvCodeDecoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'CVV',
                                hintText: 'XXX',
                              ),
                              cardHolderDecoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Card Holder Name',
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            // ignore: deprecated_member_use
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                child: const Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              color: Colors.amber,
                              onPressed: () async{
                                if (formKey.currentState.validate()) {
                                  if(currentUser.address == null) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => AddAddressPage()));
                                  }
                                  else {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => ShowAddressCheckout()));
                                  }
                                } else {
                                  print('invalid!');
                                }
                                User updatedUser = await getUserInfo();
                                setState(() {
                                  currentUser = updatedUser;
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
  /*
  Future<AlertDialog> _showValidDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xff1b447b),
          title: Text(title),
          content: Text(content),
          actions: [
            // ignore: deprecated_member_use
            FlatButton(
                child: Text(
                  "Ok",
                  style: TextStyle(fontSize: 18, color: Colors.cyan),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }
  */
  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
