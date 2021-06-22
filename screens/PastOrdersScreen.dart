import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cs308_project/entity/OrderItems.dart';
import 'package:cs308_project/entity/OrderedItem.dart';
import 'package:cs308_project/entity/TrueOrderItem.dart';
import 'package:cs308_project/globals/GlobalVariables.dart';
import 'package:cs308_project/screens/RefundScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart' as globals;

import 'package:flutter/cupertino.dart';

class PastOrders extends StatefulWidget{
  @override
  _PastOrdersState createState() => _PastOrdersState();
}

Future<List<TrueOrderItem>> getPastOrders () async {
  List<OrderedItem> myOrdered;
  List<OrderItems> updatedOrdered;
  //print("get past orders called");
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/order/getOldOrders");
  //print("response onu");
  final response = await http.get(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader : "Bearer " + globals.accessToken,
      }
  );
  //print(response);
  final body = jsonDecode(response.body);
  //print(body);
  if (body["success"]) {
    //print("success");
    myOrdered = List<OrderedItem>.from(body["orders"].map((x) => OrderedItem.fromJson(x)));
    //print(myOrdered.length);
    //print("before for");
    for (OrderedItem c in myOrdered)
    {
      //print(c.itemList.length);
      // ignore: deprecated_member_use
      updatedOrdered = new List<OrderItems>();
      for (OrderItems i in c.itemList)
      {
        if (i.id != "0907")
          updatedOrdered.add(i);
      }
      c.itemList = updatedOrdered;
    }
    // ignore: deprecated_member_use
    List<TrueOrderItem> returnList = new List();
    for (OrderedItem oitem in myOrdered)
    {
      String address = oitem.address;
      String status = oitem.status;
      String dateOfOrder = oitem.dateOfOrder;
      String orderId = oitem.orderId;
      for (OrderItems innerItem in oitem.itemList)
      {
        String productId = innerItem.productID;
        String name = innerItem.name;
        String imageUrl = innerItem.imageUrl;
        num quantity = innerItem.quantity;
        num price = innerItem.price;
        num total = innerItem.total;
        bool deleted = innerItem.deleted;
        bool refunded = innerItem.refunded;

        TrueOrderItem tempItem = TrueOrderItem(productId, name, imageUrl,
            orderId, status, address, dateOfOrder, quantity, price, total, deleted, refunded);
        returnList.add(tempItem);
        //print("item added");
      }
    }
    //print(returnList.length);
    return returnList;
  }
  return [];
}

// ignore: non_constant_identifier_names
Future<String> Cancel(String pId, String oId) async {
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/order/cancel");
  final response = await http.delete(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader : "Bearer " + accessToken,
      },
      body: jsonEncode(<String, dynamic>{
        "productId": pId,
        "orderId": oId,
      })
  );
  final body = jsonDecode(response.body);
  //print(body);
  if (body['success'])
    return "Cancelled the order successfully.";
  else
    return body['msg'];
}

// ignore: non_constant_identifier_names
String DateFormatter(String date)
{
  DateTime dateObject = DateTime.parse(date);
  dateObject = dateObject.add(Duration(hours: 3));
  return dateObject.day.toString() + "/" + dateObject.month.toString() + "/" + dateObject.year.toString()
      + " " + dateObject.hour.toString() + ":" + dateObject.minute.toString();
}

String buttonTypeDecider(TrueOrderItem item)
{
  String status = item.status;
  bool deleted = item.deleted;
  bool refunded = item.refunded;
  String orderDate = item.date;
  DateTime orderDateTime = DateTime.parse(orderDate);

  if (deleted || refunded)
    return "N";

  if (status == "DELIVERED")
  {
    DateTime refundDate = orderDateTime.add(Duration(days: 30));
    if (refundDate.isAfter(DateTime.now()))
      return "R"; // refundable
  }
  else
  {
    DateTime refundDate = orderDateTime.add(Duration(days: 30));
    if (refundDate.isAfter(DateTime.now()))
      return "C"; // cancel
  }
  return "N"; // no button
}

class _PastOrdersState extends State<PastOrders> {
  List<TrueOrderItem> items;
  int rebuild = 0;

  // ignore: non_constant_identifier_names
  void RefreshPage()
  {
    setState(() {
      rebuild++;
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text('Past Orders',
            style: TextStyle(color: Colors.grey[900],)
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
        //automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        future: getPastOrders(),
        builder: (context, snapshot){
          items = snapshot.data;
          if(snapshot.hasData){
            return Column(
              children: [
                Expanded(child: ListView.builder(
                  itemCount: items == null ? 0 : items.length,
                  itemBuilder: (context, index){
                    return Slidable(
                      child: Card(
                        elevation: 8,
                        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  child:
                                  Image(
                                    //image: NetworkImage(currProduct.imageUrl),
                                    image: NetworkImage(items[index].imageUrl),   //NetworkImage(items[index].item[0].imageUrl     'assets/images/pp.jpg'
                                    fit: BoxFit.contain,),
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                ),
                                flex: 2,
                              ),
                              Expanded(flex: 6, child: Container(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8, right: 8),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            items[index].deleted == false ? Container(
                                              width: 150,
                                              child: Text(items[index].name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Heebo',),
                                                maxLines: 2,
                                                overflow: TextOverflow.clip,
                                              ),
                                            ) :
                                            Text("DELETED PRODUCT",
                                              style: TextStyle(
                                                fontSize: 16,
                                                decoration: TextDecoration.lineThrough,
                                                decorationColor: Colors.red,
                                                decorationThickness: 2.5,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Heebo',),
                                              maxLines: 2,
                                              overflow: TextOverflow.clip,
                                            ),
                                            buttonTypeDecider(items[index]) == "R" ? TextButton.icon(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (_) => RefundScreen(items[index].productId, items[index].orderId)));
                                                  RefreshPage();
                                                },
                                                icon: Icon(Icons.assignment_return_outlined, color: Colors.amber,),
                                                label: Text(
                                                    "Refund",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Heebo',
                                                      color: Colors.grey[900],
                                                    ),)) :
                                            buttonTypeDecider(items[index]) == "C" ? TextButton.icon(
                                                onPressed: () async {
                                                  String msg = await Cancel(items[index].productId, items[index].orderId);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(content: Text(msg)));
                                                  RefreshPage();
                                                },
                                                icon: Icon(Icons.cancel, color: Colors.red[900],),
                                                label: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Heebo',
                                                    color: Colors.grey[900],
                                                  ),)) : SizedBox(height: 0.1),
                                          ]
                                      ),),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(Icons.monetization_on, color: Colors.amber, size:22),
                                          Container(margin: const EdgeInsets.only(left: 8),
                                            child: Text(items[index].total.toStringAsFixed(2),
                                              style: TextStyle(fontWeight: FontWeight.bold,
                                                fontFamily: 'Heebo',
                                              fontSize: 15),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,),)
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(Icons.shopping_basket, color: Colors.amber, size:22),
                                          Container(margin: const EdgeInsets.only(left: 8),
                                            child: Text(items[index].quantity.toString(),
                                              style: TextStyle(fontWeight: FontWeight.bold,
                                                fontFamily: 'Heebo',
                                                  fontSize: 15),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,),),
                                          SizedBox(width: 10),
                                          Icon(Icons.calendar_today, color: Colors.amber, size:22),
                                          Container(margin: const EdgeInsets.only(left: 8),
                                            child: Text(DateFormatter(items[index].date),
                                              style: TextStyle(fontWeight: FontWeight.bold,
                                                fontFamily: 'Heebo',
                                                  fontSize: 15),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,),)
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(Icons.home, color: Colors.amber, size:22),
                                          Container(
                                            width: 200,
                                            margin: const EdgeInsets.only(left: 8, right: 8),
                                            child: Text(items[index].address,
                                              style: TextStyle(fontWeight: FontWeight.bold,
                                                fontFamily: 'Heebo',
                                                  fontSize: 14),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,),)
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(Icons.local_shipping_outlined, color: Colors.amber, size:22),
                                          Container(margin: const EdgeInsets.only(left: 8),
                                            child: Text(items[index].status,
                                              style: TextStyle(fontWeight: FontWeight.bold,
                                                fontFamily: 'Heebo',
                                                  fontSize: 15),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,),),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      secondaryActions: [
                      ],
                    );
                    },
                ))
              ],
            );
          }
          else {
            return Center(child: Text('No previous orders found.'),);
          }
        },
      ),
    );
  }
}