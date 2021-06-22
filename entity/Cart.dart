import 'package:floor/floor.dart';
import 'CartItem.dart';

// this class is for the cart itself
@entity
class Cart{
  num subtotal;
  // ignore: non_constant_identifier_names
  String cart_id, user_id;
  List<CartItem> items;

  // ignore: non_constant_identifier_names
  Cart({this.subtotal, this.cart_id, this.user_id, this.items});

  factory Cart.fromJson(Map<String, dynamic> json){
    //print(json);
    return Cart(
      subtotal : json['subTotal'],
      cart_id : json['_id'],
      user_id : json['userId'],
      items : List<CartItem>.from(json["items"].map((x) => CartItem.fromJson(x))),
    );
  }

}