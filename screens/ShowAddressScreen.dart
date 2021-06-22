import 'dart:convert';
import 'dart:io';

import 'package:cs308_project/entity/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart' as globals;
import 'AddAddressScreen.dart';


class ShowAddress extends StatefulWidget {

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
  //print(body);

  if (body["status"] == true) {
    myUser = User.fromJson(body["data"]);
    //temp.add(myUser);
    return myUser;
  }
  return null;
}


class _ShowAddressState extends State<ShowAddress> {
  User currentUser;

  void refreshPage () async {
    User updatedUser = await getUserInfo();
    setState(() {
      currentUser = updatedUser;
    });
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
  BoxDecoration myBoxDecoration2() {
    return BoxDecoration(
      color: Colors.black,
      border: Border.all(
          color: Colors.amber,
          width: 2.0
      ),
      borderRadius: BorderRadius.all(
          Radius.circular(0)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  title: Text("Address", style: TextStyle(color: Colors.black),), centerTitle: true,
                  backgroundColor: Colors.amber,
                ),
                body:
                Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                          image: AssetImage("assets/images/ducks.jpg"),
                          fit: BoxFit.cover,
                        )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 30,),
                        Image.asset('assets/images/delivery1.png', scale: 3,),
                        //Text("MY ADDRESS/n",textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                        /*Container(
                          margin: const EdgeInsets.all(10.0),
                          //padding: const EdgeInsets.all(3.0),
                          //decoration: myBoxDecoration2(),
                          child: Text("DELIVERY ADDRESS", textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),),
                        ),*/
                        SizedBox(height: 20,),
                        Container(
                          margin: const EdgeInsets.all(15.0),
                          padding: const EdgeInsets.all(3.0),
                          decoration: myBoxDecoration(),
                          child: Column(
                            children: [
                              Text("\n" + "Delivery Address" + "\n" +"\n"
                                  + currentUser.address + "\n" ,textAlign: TextAlign.center,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), ),
                            ],
                          ),
                        ),
                        //SizedBox(height: 20,),
                        Container(
                            margin: const EdgeInsets.all(20.0),
                            child: Center(
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
                                            color: Colors.grey[900],
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
                            )
                        )
                      ],
                    )
                )
            );
          }
          else return Center(child: CircularProgressIndicator());
        });


    /*return Scaffold(
        appBar: AppBar(
          title: Text("Address",), centerTitle: true,
          backgroundColor: Colors.amber,
        ),
        body:
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("MY ADDRESS",textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration: myBoxDecoration(),
              child: Text(widget.address ,textAlign: TextAlign.center,style: TextStyle(fontSize: 25),),
            ),
            Container(
              width: double.infinity,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Container(
                  margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: const Text(
                    'Change Address Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                color: const Color(0xff1b447b),
                splashColor: Colors.amber,
                onPressed: () async{
                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => AddAddressPage()));
                },
              )
            ),

          ],
        )
    );*/
  }
}