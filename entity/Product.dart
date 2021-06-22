import 'package:floor/floor.dart';
// this class is for item in the cart
// this is actually an item with additional attributes
@entity
class Product{

  //String name, model, description, warranty, distributor, imgUrl, category;
  //num rating, viewNumber, purchase, number, itemsInStock, unitPrice;

  String name, imageUrl;

  Product({this.name, this.imageUrl});

  factory Product.fromJson(Map<String, dynamic> json){
    return Product(
        name: json['name'],
        imageUrl: json['imgUrl']);
  }

}