class Comment {
  bool actions, approved;
  String text, id, customerId, productId, createdAt, updatedAt, fullname;
  num rating;

  Comment({this.actions, this.approved, this.text, this.id, this.customerId,
      this.productId, this.createdAt, this.updatedAt, this.rating, this.fullname});

  factory Comment.fromJson(Map<dynamic, dynamic> json){
    return Comment(
      actions: json['actions'],
      approved: json['approved'],
      text: json['comment'],
      id: json['_id'],
      customerId: json['customerId']['_id'],
      fullname: json['customerId']['fullname'],
      productId: json['productId'],
      rating: json['rating'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}