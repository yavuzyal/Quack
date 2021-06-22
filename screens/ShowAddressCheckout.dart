import 'dart:convert';
import 'dart:io';

import 'package:cs308_project/entity/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart' as globals;
import 'AddAddressScreen.dart';
import 'Summary.dart';


class ShowAddressCheckout extends StatefulWidget {

  /*final String address;

  const ShowAddress(this.address);*/

  @override
  _ShowAddressState createState() => _ShowAddressState();
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
  print(body);

  if (body["status"] == true) {
    myUser = User.fromJson(body["data"]);
    //temp.add(myUser);
    return myUser;
  }
  return null;
}

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


class _ShowAddressState extends State<ShowAddressCheckout> {
  User currentUser;
  void refreshPage () async {
    print("refresh");
    User updatedUser = await getUserInfo();
    setState(() {
      currentUser = updatedUser;
    });
  }
  @override
  Widget build(BuildContext context) {
    BoxDecoration myBoxDecoration() {
      return BoxDecoration(
        color: Colors.amber,
        border: Border.all(
            width: 3.0
        ),
        borderRadius: BorderRadius.all(
            Radius.circular(30.0) //                 <--- border radius here
        ),
      );
    }
    return FutureBuilder(
        future: getUserInfo(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            currentUser = snapshot.data;
            return Scaffold(
                appBar: AppBar(
                  iconTheme: IconThemeData(
                    color: Colors.black, //change your color here
                  ),
                  title: Text("Address",style: TextStyle(color: Colors.black),), centerTitle: true,
                  backgroundColor: Colors.amber,
                ),
                body:
                    Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
                              image: AssetImage("assets/images/ducks.jpg"),
                              fit: BoxFit.cover,
                            )
                        ),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 30,),
                            Image.asset('assets/images/delivery1.png', scale: 3,),
                            /*Container(
                              margin: const EdgeInsets.all(15.0),
                              padding: const EdgeInsets.all(3.0),
                              decoration: myBoxDecoration(),
                              child: Text("MY ADDRESS",textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                            ),*/
                            SizedBox(height: 15,),
                            Container(
                              margin: const EdgeInsets.all(15.0),
                              padding: const EdgeInsets.all(3.0),
                              decoration: myBoxDecoration(),
                              child: Text("\n" + "Delivery Address" + "\n" +"\n"
                                  + currentUser.address + "\n" ,textAlign: TextAlign.center,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(12.0),
                              //padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //SizedBox(height: 130.0),
                                  // ignore: deprecated_member_use
                                  FlatButton.icon(
                                    onPressed: () async{
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) => AddAddressPage())).then((value) {
                                        refreshPage();
                                      });
                                    },
                                    icon: Icon(Icons.home, color: Colors.grey[900],),
                                    label: Text(
                                        "Change Address",
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
                            Container(
                              margin: const EdgeInsets.all(10.0),
                              //padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //SizedBox(height: 130.0),
                                  // ignore: deprecated_member_use
                                  FlatButton.icon(
                                    onPressed: () async{
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) => ItemSummary(currentUser.address)));
                                    },
                                    icon: Icon(Icons.wysiwyg, color: Colors.grey[900],),
                                    label: Text(
                                        "Continue",
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
                        ),
                      ))
            );
          }
          else return Center(child: CircularProgressIndicator());
        });
  }
}

/*

Container(
                      width: double.infinity,
                      // ignore: deprecated_member_use
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: const Text(
                            'Place Order',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        color: const Color(0xff1b447b),
                        splashColor: Colors.amber,
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
                      ),
                    ),

 */