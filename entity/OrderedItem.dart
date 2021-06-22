import 'package:floor/floor.dart';
import 'OrderItems.dart';

@entity
class OrderedItem{
  String orderId, address, status, dateOfOrder;
  num total;
  List<OrderItems> itemList;

  OrderedItem({this.address, this.status, this.total, this.itemList, this.dateOfOrder, this.orderId});

  factory OrderedItem.fromJson(Map<dynamic, dynamic> json){
    //print(json);
    return OrderedItem(
      orderId: json['_id'],
      address: json['address'],
      dateOfOrder: json['dateofOrder'],
      total: json['total'],
      status: json['status'],
      itemList : List<OrderItems>.from(json["items"].map((x) => OrderItems.fromJson(x))),
      // item: json['items'] != null ? new OrderItems.fromJson(json['items']) : null,
    );
  }

}