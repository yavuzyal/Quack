import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart';

class AddEditCommentScreen extends StatefulWidget {
  final String id, mode, commentId;
  const AddEditCommentScreen(this.id, this.mode, this.commentId);

  @override
  _AddEditCommentScreenState createState() => _AddEditCommentScreenState();
}

// ignore: non_constant_identifier_names
Future<bool> AddComment(String id, double rating, String commentText) async {
  print(rating);
  if (commentText == null)
    commentText = "";
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/product/" + id + "/comments");
  final response = await http.post(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader : "Bearer " + accessToken,
      },
      body: jsonEncode(<String, dynamic>{
        "rating": rating,
        "comment": commentText,
        }
      )
  );
  final body = jsonDecode(response.body);
  print(body);
  return body["success"];
}

// ignore: non_constant_identifier_names
Future<bool> EditComment(String id, double rating, String commentText, String commentId) async {
  print(rating);
  print(commentText);
  if (commentText == null)
    commentText = "";
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/product/"
      + id + "/comments" + "/" + commentId);
  final response = await http.put(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader : "Bearer " + accessToken,
      },
      body: jsonEncode(<String, dynamic>{
        "rating": rating,
        "comment": commentText,
      }
      )
  );
  final body = jsonDecode(response.body);
  print(body);
  return body['success'];
}

class _AddEditCommentScreenState extends State<AddEditCommentScreen> {

  double ratingToSend = 4.5;
  final commentBox = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          widget.mode == "add" ? 'Add Comment' : "Edit Comment",
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
                  "Please rate :)",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Heebo",
                      fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 10,),
                RatingBar.builder(
                  initialRating: 4.5,
                  minRating: 0.5,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    //print(rating);
                    ratingToSend = rating;
                    //print(ratingToSend);
                  },
                ),
                SizedBox(height: 20),
                Text(
                  "We would like to your hear your comments.",
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
                    controller: commentBox,
                    maxLines: 3,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.comment,
                        color: Colors.black,
                      ),
                      hintText: "Write your comment here...",
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "You can leave comment empty, but you have to rate.",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Heebo",
                    fontSize: 12.0,
                  ),
                ),
                SizedBox(height: 10),
                // ignore: deprecated_member_use
                FlatButton.icon(
                  onPressed: () async{
                    if (widget.mode == "add")
                    {
                      //print(ratingToSend);
                      bool result = await AddComment(widget.id, ratingToSend, commentBox.text);
                      if (result)
                      {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Comment is added successfully.')));
                      }
                      else
                      {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('This comment cannot be added.')));
                      }
                      Navigator.pop(context);
                    }
                    else
                    {
                      print("edit comment");
                      //print(commentBox.text);
                      bool result = await EditComment(widget.id, ratingToSend, commentBox.text, widget.commentId);
                      if (result)
                      {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Comment is edited successfully.')));
                      }
                      else
                      {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('This comment cannot be edited.')));
                      }
                      Navigator.pop(context);
                    }
                  },
                  icon: widget.mode == "add" ? Icon(Icons.add_comment) : Icon(Icons.edit),
                  label: Text(
                      widget.mode == "add" ? 'Add Comment' : "Edit Comment",
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
