import 'package:floor/floor.dart';
import 'Comment.dart';
// this class is for item in the cart
// this is actually an item with additional attributes
@entity
class PageItem{
  bool canAddComment;
  num rating, viewNumber, purchased, itemsInStock, unitPrice, salesPercent;
  String id, name, models, description, warranty, distributor, imageURL, category;
  List<Comment> comments;


  PageItem({
      this.canAddComment,
      this.rating,
      this.viewNumber,
      this.purchased,
      this.itemsInStock,
      this.unitPrice,
      this.salesPercent,
      this.id,
      this.name,
      this.models,
      this.description,
      this.warranty,
      this.distributor,
      this.imageURL,
      this.category,
      this.comments});

  factory PageItem.fromJson(Map<dynamic, dynamic> json){
    return PageItem(
      canAddComment: json['canAddComment'],
      rating: json['data']['rating'],
      viewNumber: json['data']['viewNumber'],
      purchased: json['data']['purchased'],
      salesPercent: json['data']['salesPercent'],
      id: json['data']['_id'],
      name: json['data']['name'],
      models: json['data']['models'],
      description: json['data']['description'],
      itemsInStock: json['data']['itemsInStock'],
      unitPrice: json['data']['unitPrice'],
      warranty: json['data']['warranty'],
      distributor: json['data']['distributor'],
      imageURL: json['data']['imgUrl'],
      category: json['data']['category'],
      comments: List<Comment>.from(json['data']['comments'].map((x) => Comment.fromJson(x))),
    );
  }
}