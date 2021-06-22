import 'package:floor/floor.dart';
// this class is for item in the cart
// this is actually an item with additional attributes
@entity
class Item{
  String id, name, imageUrl;
  int itemsInStock;
  num unitPrice, salesPercent;
  bool deleted;

  Item(
      {this.id,
      this.name,
      this.salesPercent,
      this.deleted,
      this.imageUrl,
      this.itemsInStock,
      this.unitPrice});

  factory Item.fromJson(Map<dynamic, dynamic> json) {
    //print(json);
    return Item(
        id : json["_id"],
        name : json["name"],
        salesPercent : json["salesPercent"],
        deleted : json["deleted"],
        itemsInStock : json["itemsInStock"],
        unitPrice : json["unitPrice"],
        imageUrl : json["imgUrl"],
    );
  }
}