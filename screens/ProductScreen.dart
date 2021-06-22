import 'dart:convert';
import 'dart:io';

import 'package:cs308_project/entity/PageItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart';

import 'AddEditCommentScreen.dart';
import 'HomeScreen.dart';


class ProductScreen extends StatefulWidget {
  final String id;
  const ProductScreen(this.id);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

Future<PageItem> getProductForProductPage(String id) async {
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/product/" + id);
  dynamic response;
  if (isLoggedIn)
  {
    response = await http.get(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader : "Bearer " + accessToken,
      },
    );
  }
  else {
    response = await http.get(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }
  final body = jsonDecode(response.body);
  //print(body);
  return PageItem.fromJson(body);
}

// ignore: non_constant_identifier_names
Future<bool> DeleteComment(String id, String commentId) async {
  var apiURL = Uri.parse(
      "https://protected-everglades-33662.herokuapp.com/product/"
          + id + "/comments" + "/" + commentId);
  final response = await http.delete(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer " + accessToken,
      },
  );
  final body = jsonDecode(response.body);
  //print(body);
  return body['success'];
}

// ignore: non_constant_identifier_names
String DateFormatter(String date)
{
  DateTime dateObject = DateTime.parse(date);
  dateObject = dateObject.add(Duration(hours: 3));
  return dateObject.day.toString() + "/" + dateObject.month.toString() + "/" + dateObject.year.toString()
      + " " + dateObject.hour.toString() + ":" + dateObject.minute.toString();
}

// ignore: non_constant_identifier_names
num CalculateOriginalPrice(num price, num discount)
{
  num percentage = 100 - discount;
  return (price*100)/percentage;
}

class _ProductScreenState extends State<ProductScreen> {

  PageItem item;

  void refreshPage () async {
    //print("refresh");
    PageItem updatedItem = await getProductForProductPage(widget.id);
    setState(() {
      item = updatedItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    //print("rebuilt product page");
    return Scaffold(
      body: SafeArea(
          child: FutureBuilder(
            future: getProductForProductPage(widget.id),
            builder: (context, snapshot) {
              item = snapshot.data;
              if (snapshot.hasData)
              {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Column(
                        children: [
                          Image(
                            width: 300,
                            height: 300,
                            image: NetworkImage(item.imageURL),
                          ),
                          SizedBox(height: 5,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                fontFamily: 'Heebo',
                              ),
                            ),
                          ),
                          SizedBox(height: 5,),
                          Text(
                            item.itemsInStock <= 0 ?
                            "Sold out" : "In stock: " + item.itemsInStock.toString(),
                              style: TextStyle(fontSize: 16,
                                  fontFamily: 'Heebo',
                                  fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,),
                          SizedBox(height: 5,),
                          Row(mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              item.salesPercent != null && item.salesPercent > 0 ? Container(margin: const EdgeInsets.only(left: 8),
                                child: Text("\$" + CalculateOriginalPrice(item.unitPrice, item.salesPercent).toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.red,
                                    decorationThickness: 2.5,
                                    fontFamily: 'Heebo',),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,),) : SizedBox(height: 0.1),
                              SizedBox(width: 10),
                              Icon(Icons.monetization_on_sharp, color: Colors.amber, size:20),
                              Container(margin: const EdgeInsets.only(left: 8),
                                child: Text("\$" + item.unitPrice.toStringAsFixed(2),
                                  style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold,
                                    fontFamily: 'Heebo',),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,),),
                              SizedBox(width: 15,),
                              // ignore: deprecated_member_use
                              ],
                          ),
                          // ignore: deprecated_member_use
                          FlatButton.icon(
                            label: Text(
                                "Add to Cart",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Heebo',
                                )),
                            icon: Icon(Icons.shopping_bag_outlined),
                            color: item.itemsInStock <= 0 ? Colors.grey : Colors.amber,
                            shape: RoundedRectangleBorder
                              (side: BorderSide(
                                color: Colors.black,
                                width: 3,
                                style: BorderStyle.solid
                            ), borderRadius: BorderRadius.circular(10)
                            ),
                            onPressed: () async {
                              if (item.itemsInStock <= 0)
                              {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text("Not enough stock.")));
                              }
                              else
                              {
                                String msg = await AddItemToCart(item.id);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(msg)));
                              }
                            },
                          ),
                          SizedBox(height: 5),
                          item.salesPercent > 0 ? Container(
                            padding: EdgeInsets.all(8.0),
                            color: Colors.red[800],
                            child: Text(
                              "ON SALE -" + item.salesPercent.toStringAsFixed(2) + "%",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Heebo',
                                letterSpacing: 2.0,
                              ),
                            ),
                          ) : SizedBox(width: 0.1,),
                          SizedBox(height: 5,),
                          item.rating != null ? RatingBarIndicator(
                            rating: item.rating.toDouble(),
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 28.0,
                            direction: Axis.horizontal,
                          ) :
                          Text(
                            "This product is not rated yet.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Heebo',
                            ),
                          ),
                          SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Description",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Heebo',
                                ),
                              )
                            ],
                          ),
                          Container(
                            height: 2,
                            color: Colors.amber,
                          ),
                          SizedBox(height: 5),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Heebo',
                              wordSpacing: 1.5,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Category",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Heebo',
                                ),
                              )
                            ],
                          ),
                          Container(
                            height: 2,
                            color: Colors.amber,
                          ),
                          SizedBox(height: 5),
                          Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Heebo',
                              wordSpacing: 1.5,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Model",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Heebo',
                                ),
                              )
                            ],
                          ),
                          Container(
                            height: 2,
                            color: Colors.amber,
                          ),
                          SizedBox(height: 5),
                          Text(
                            item.models,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Heebo',
                              wordSpacing: 1.5,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Warranty",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Heebo',
                                ),
                              )
                            ],
                          ),
                          Container(
                            height: 2,
                            color: Colors.amber,
                          ),
                          SizedBox(height: 5),
                          Text(
                            item.warranty,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Heebo',
                              wordSpacing: 1.5,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Distributor",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Heebo',
                                ),
                              )
                            ],
                          ),
                          Container(
                            height: 2,
                            color: Colors.amber,
                          ),
                          SizedBox(height: 5),
                          Text(
                            item.distributor,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Heebo',
                              wordSpacing: 1.5,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Comments",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Heebo',
                                ),
                              )
                            ],
                          ),
                          Container(
                            height: 2,
                            color: Colors.amber,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: item.comments == null ? 0 : item.comments.length,
                                      itemBuilder: (context, index){
                                        return Slidable(
                                          actionPane: null,
                                          child: Card(
                                            elevation: 4,
                                            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              child: Column(
                                                children: [
                                                  Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.person),
                                                        SizedBox(width: 10,),
                                                        Expanded(
                                                              child: Text(
                                                                item.comments[index].fullname,
                                                                  textAlign: TextAlign.left,
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 18,
                                                                  fontFamily: 'Heebo',
                                                                )
                                                              ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                              DateFormatter(item.comments[index].updatedAt),
                                                              textAlign: TextAlign.right,
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: 'Heebo',
                                                              )
                                                          ),
                                                        ),
                                                      ]
                                                  ),
                                                  Container(
                                                    height: 2,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(height: 6,),
                                                  Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.comment),
                                                        SizedBox(width: 10,),
                                                        Expanded(
                                                              child: Text(
                                                                item.comments[index].text,
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 16,
                                                                    fontFamily: 'Heebo',
                                                                  )
                                                              ),
                                                        ),
                                                      ]
                                                  ),
                                                  SizedBox(height: 6,),
                                                  Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.star),
                                                        SizedBox(width: 10,),
                                                        Expanded(
                                                          child: RatingBarIndicator(
                                                            rating: item.comments[index].rating.toDouble(),
                                                            itemBuilder: (context, index) => Icon(
                                                              Icons.star,
                                                              color: Colors.amber,
                                                            ),
                                                            itemCount: 5,
                                                            itemSize: 24.0,
                                                            direction: Axis.horizontal,
                                                          ),
                                                        ),
                                                        item.comments[index].actions ? TextButton(
                                                          child: Text(
                                                              "EDIT",
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 18,
                                                              fontFamily: 'Heebo',
                                                              color: item.comments[index].actions ? Colors.amber : Colors.grey,
                                                            )
                                                            ),
                                                          onPressed: () {
                                                            if (item.comments[index].actions)
                                                            {
                                                              print(item.id);
                                                              print(item.comments[index].id);
                                                              Navigator.of(context).push(
                                                                  MaterialPageRoute(
                                                                      builder: (_) => AddEditCommentScreen(item.id, "edit", item.comments[index].id))).then((value) {
                                                                 refreshPage();
                                                              });
                                                            }
                                                            else
                                                              print("not authorized for editing comment");
                                                          },
                                                        ) : SizedBox(width: 1),
                                                        item.comments[index].actions ? TextButton(
                                                          child: Text(
                                                              "DELETE",
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 18,
                                                                fontFamily: 'Heebo',
                                                                color: item.comments[index].actions ? Colors.amber : Colors.grey,
                                                              )
                                                          ),
                                                          onPressed: () async {
                                                            if (item.comments[index].actions)
                                                            {
                                                              bool result = await DeleteComment(item.id, item.comments[index].id);
                                                              if (result)
                                                              {
                                                                ScaffoldMessenger.of(context)
                                                                    .showSnackBar(SnackBar(content: Text('Comment is deleted successfully.')));
                                                              }
                                                              else
                                                              {
                                                                ScaffoldMessenger.of(context)
                                                                    .showSnackBar(SnackBar(content: Text('Failed to delete comment.')));
                                                              }
                                                            }
                                                            else
                                                              print("not authorized for deleting comment");
                                                            refreshPage();
                                                          },
                                                        ) : SizedBox(width: 1),
                                                      ]
                                                  ),
                                                  SizedBox(height:5),
                                                  item.comments[index].approved == false ? Text(
                                                    "This comment is waiting for approval.",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight: FontWeight.bold,
                                                    )
                                                  ) : SizedBox(height:1),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                  )
                              ),
                              // ignore: deprecated_member_use
                              FlatButton.icon(
                                onPressed: () {
                                  if (item.canAddComment)
                                  {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => AddEditCommentScreen(item.id, "add", "")))
                                        .then((value) {
                                      refreshPage();
                                    });
                                  }
                                  else
                                    print("not authorized for adding comment");
                                },
                                icon: Icon(Icons.add_comment),
                                label: Text(
                                    "Add Comment",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: 'Heebo',
                                    )
                                ),
                                color: item.canAddComment ? Colors.amber : Colors.grey,
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
                );
              }
              else {return Center(child: CircularProgressIndicator());}
            }
          )
      )
    );
  }
}