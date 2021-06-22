import 'package:floor/floor.dart';
import 'Item.dart';
// this class is for item in the cart
// this is actually an item with additional attributes
@entity
class CartItem{
  String id;
  int quantity;
  num price, total;
  Item item;

  CartItem({this.id, this.quantity, this.price, this.total, this.item});

  factory CartItem.fromJson(Map<dynamic, dynamic> json){
    //print(json);
    return CartItem(
      id: json['_id'],
      quantity: json['quantity'],
      price: json['price'],
      total: json['total'],
      item: json['productId'] != null
          ? new Item.fromJson(json['productId'])
          : null,
    );
  }

}