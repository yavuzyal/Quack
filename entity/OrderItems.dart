import 'package:floor/floor.dart';

@entity
class OrderItems{
  String id, productID, name, imageUrl;
  int quantity;
  num price, total;
  bool deleted, refunded;

  OrderItems({this.id, this.quantity, this.price, this.total, this.productID,
    this.name, this.imageUrl, this.deleted, this.refunded});

  factory OrderItems.fromJson(Map<dynamic, dynamic> json) {
    //print(json);
    if (json['productId'] == null) {
      //print("product id null");
      return OrderItems(
          id: "0907",
          quantity: 0,
          price: 0,
          total: 0,
          productID: "0908",
          name: "",
          imageUrl: "",
          deleted: false,
          refunded: false,
      );
    }
    return OrderItems(
      id: json['_id'],
      quantity: json['quantity'],
      price: json['price'],
      total: json['total'],
      productID: json['productId']['_id'],
      name: json['productId']['name'],
      imageUrl: json['productId']['imgUrl'],
      deleted: json['productId']['deleted'],
      refunded: json['refunded'],
    );
  }

}