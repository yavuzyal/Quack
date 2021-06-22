import 'package:floor/floor.dart';

// this class is for the cart itself
@entity
class User{
  String email, fullName, address;
  int taxID;

  User({this.email, this.fullName, this.taxID, this.address});

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      email : json['email'],
      fullName : json['fullname'],
      taxID : json['taxID'],
      address : json['address'],
    );
  }

}