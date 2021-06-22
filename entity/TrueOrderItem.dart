import 'package:floor/floor.dart';

@entity
class TrueOrderItem{
  String productId, name, imageUrl, orderId, status, address, date;
  int quantity;
  num price, total;
  bool deleted, refunded;

  TrueOrderItem(
      this.productId,
      this.name,
      this.imageUrl,
      this.orderId,
      this.status,
      this.address,
      this.date,
      this.quantity,
      this.price,
      this.total,
      this.deleted,
      this.refunded);
}