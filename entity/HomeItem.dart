import 'package:floor/floor.dart';
// this class is for item in the cart
// this is actually an item with additional attributes
@entity
class HomeItem{
  String id, name, models, description, warranty, distributor, imgURL, wholeJson;
  int itemsInStock;
  num unitPrice, rating, salesPercent;


  HomeItem({
      this.id,
      this.name,
      this.models,
      this.description,
      this.warranty,
      this.distributor,
      this.imgURL,
      this.wholeJson,
      this.itemsInStock,
      this.unitPrice,
      this.rating,
      this.salesPercent});

  factory HomeItem.fromJson(Map<dynamic, dynamic> json){
    //print(json);
    return HomeItem(
      id: json['_id'],
      name: json['name'],
      models: json['models'],
      description: json['description'],
      itemsInStock: json['itemsInStock'],
      unitPrice: json['unitPrice'],
      warranty: json['warranty'],
      distributor: json['distributor'],
      imgURL: json['imgUrl'],
      rating: json['rating'],
      salesPercent: json['salesPercent'],
    );
  }
}