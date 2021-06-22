import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart' as globals;
import 'MainTemplate.dart';

Future<bool> placeOrder () async{
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/order/placeOrder");
  final response = await http.post(
    apiURL,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      HttpHeaders.authorizationHeader : "Bearer " + globals.accessToken,
    },
  );
  print(response.body.toString());
  final body = jsonDecode(response.body);
  print(body);
  return body["success"];
}


class Summary extends StatefulWidget {

  final String address;

  Summary(this.address);

  @override
  Sum createState() => Sum();
}

BoxDecoration myBoxDecoration() {
  return BoxDecoration(
    color: Colors.amber,
    border: Border.all(
        width: 2.0
    ),
    borderRadius: BorderRadius.all(
        Radius.circular(30.0)
    ),
  );
}

class Sum extends State<Summary> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Checkout Summary",), centerTitle: true,
          backgroundColor: Colors.amber,
        ),
        body:
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CreditCardWidget(
              showBackView: false,
              cardBgColor: Colors.grey[900],
              cardNumber: "1234123412341243",
              expiryDate: "02/20",
              cardHolderName: "deneme",
              cvvCode: "123",
              //obscureCardNumber: true,
              //obscureCardCvv: true,
            ),
            SizedBox(height: 25,),
            Text("MY ADDRESS",textAlign: TextAlign.center,),
            Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration: myBoxDecoration(),
              child: Column(
                children: [
                  Text("\n" + "Delivery Address" + "\n" +"\n"
                      + widget.address + "\n" ,textAlign: TextAlign.center,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), ),
                ],
              ),
            ),
            //Text(widget.address ,textAlign: TextAlign.center,),
            // ignore: deprecated_member_use
            /*RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Container(
                margin: const EdgeInsets.all(8),
                child: const Text(
                  'PLACE ORDER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              color: const Color(0xff1b447b),
              onPressed: () async{
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => AddAddressPage()));
              },
            ),*/
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //SizedBox(height: 130.0),
                  // ignore: deprecated_member_use
                  FlatButton.icon(
                    onPressed: () async{
                      //placeOrder();
                      bool ordered = await placeOrder();
                      print("order returned " + ordered.toString());
                      if(ordered){
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Order has been made. Check your email.')));
                        Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => Template()));
                        //Navigator.pop(context);
                      }
                      else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Order failed.')));
                        Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => Template()));
                        print("order failed");
                      }
                    },
                    icon: Icon(Icons.shopping_basket, color: Colors.grey[900],),
                    label: Text(
                        'Complete Order',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24.0,
                            fontFamily: 'Heebo',
                            color: Colors.grey[900]
                        )
                    ),
                    color: Colors.amber,
                    shape: RoundedRectangleBorder
                      (side: BorderSide(
                        color: Colors.grey[900],
                        width: 3,
                        style: BorderStyle.solid
                    ), borderRadius: BorderRadius.circular(0)
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
}