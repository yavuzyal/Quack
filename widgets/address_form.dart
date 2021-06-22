//import 'package:ecommerce_int2/app_properties.dart';
import 'package:flutter/material.dart';

class AddAddressForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
            child: TextField(
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
            child: TextField(
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
              child: TextField(
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
              child: TextField(
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
              child: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'City'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}