import 'dart:convert';
import 'dart:io';
import 'package:cs308_project/entity/Cart.dart';
import 'package:cs308_project/entity/CartItem.dart';
import 'package:cs308_project/entity/Item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'MainTemplate.dart';

class ItemSummary extends StatefulWidget{

  final String address;

  ItemSummary(this.address);

  @override
  itemsum createState() => itemsum();

}

Future<bool> placeOrder () async{
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/order/placeOrder");
  final response = await http.post(
    apiURL,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      HttpHeaders.authorizationHeader : "Bearer " + globals.accessToken,
    },
  );
  print(response.body.toString());
  final body = jsonDecode(response.body);
  print(body);
  return body["success"];
}

Future<List<CartItem>> getCart (PrimitiveWrapper total, PrimitiveWrapper contList) async {
  //print("get cart called");
  if (globals.isLoggedIn)
  {
    Cart myCart;
    var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/cart");
    final response = await http.get(
        apiURL,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader : "Bearer " + globals.accessToken,
        }
    );
    final body = jsonDecode(response.body);
    //print(body["data"]);
    if (body["success"]) {
      myCart = Cart.fromJson(body["data"]);
      total.value = myCart.subtotal;
      for (CartItem CartItemInstance in myCart.items)
      {
        //print("inside for item " + CartItemInstance.item.name + " quantity is " + CartItemInstance.quantity.toString());
        contList.value.add(new TextEditingController(text: CartItemInstance.quantity.toString()));
      }
      //print("returning items");
      return myCart.items;
    }
    return [];
  }
  else {
    String dummyId = "1";
    // ignore: deprecated_member_use
    List<CartItem> notLoggedInCartItems = new List<CartItem>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> idQuantityList = prefs.getStringList('notLoginItems');
    for (String s in idQuantityList) {
      String productID = s.substring(12, s.indexOf(','));
      //print(s);
      //print(productID);
      //print(s.substring(s.indexOf('ty: ') + 4, s.indexOf('}')));
      var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/product/" + productID);
      final response = await http.get(
        apiURL,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      final body = jsonDecode(response.body);
      print(body);
      CartItem myItem = new CartItem();
      myItem.id = dummyId;
      dummyId += "1";
      myItem.quantity = int.tryParse(s.substring(s.indexOf('ty: ') + 4, s.indexOf('}')));
      myItem.item = Item.fromJson(body['data']);
      myItem.price = body['data']['unitPrice'];
      myItem.total = myItem.quantity * myItem.price;
      total.value += myItem.total;
      contList.value.add(new TextEditingController(text: myItem.quantity.toString()));
      notLoggedInCartItems.add(myItem);
    }
    return notLoggedInCartItems;
  }
}

BoxDecoration myBoxDecoration() {
  return BoxDecoration(
    color: Colors.amber,
    border: Border.all(
        width: 2.0
    ),
    borderRadius: BorderRadius.all(
        Radius.circular(30.0)
    ),
  );
}

class PrimitiveWrapper {
  var value;
  PrimitiveWrapper(this.value);
}

bool checkForStockAndDeleted(List<CartItem> cart)
{
  for (CartItem item in cart)
  {
    if (item.item.deleted || item.item.itemsInStock <= 0)
      return false;
  }
  return true;
}

// ignore: camel_case_types
class itemsum extends State<ItemSummary>{
  List<CartItem> items;
  TextEditingController dummyController = new TextEditingController(text: "-");
  @override
  Widget build(BuildContext context) {
    var totalCartPrice = new PrimitiveWrapper(0);
    // ignore: deprecated_member_use
    var controllerList = new PrimitiveWrapper(new List<TextEditingController>());
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text('Checkout Summary',
            style: TextStyle(color: Colors.grey[900],
                fontWeight: FontWeight.bold,
                fontFamily: 'Heebo',
                letterSpacing: 1.5,
                fontSize: 24.0)
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
        automaticallyImplyLeading: true,
        //foregroundColor: Colors.black,

        actions: [],
      ),

      body: FutureBuilder(
          future: getCart(totalCartPrice, controllerList),
          builder: (context, snapshot){
            items = snapshot.data;
            if(snapshot.hasData){ //snapshot.hasData
              //print(items.length);
              //print(controllerList.value.length);
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: myBoxDecoration(),
                    child: Text(widget.address ,textAlign: TextAlign.center,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), ),
                  ),
                  SizedBox(height: 10,),
                  Text("ITEMS", style: TextStyle(fontSize: 20),),
                  Divider(thickness: 5, color: Colors.amber),
                  Expanded(child: ListView.builder(
                    itemCount: items == null ? 0 : items.length,
                    itemBuilder: (context, index){
                      return Slidable(
                        child: Card(
                          elevation: 8,
                          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    child:
                                    Image(
                                      image: NetworkImage(items[index].item.imageUrl),   //items[index].imageUrl
                                      fit: BoxFit.contain,),
                                    borderRadius: BorderRadius.all(Radius.circular(4)),
                                  ),
                                  flex: 2,
                                ),
                                Expanded(flex: 6, child: Container(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8, right: 8),
                                        child: items[index].item.deleted == false ? Text(items[index].item.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Heebo',),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,) :
                                        Text(items[index].item.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.lineThrough,
                                            decorationColor: Colors.red,
                                            decorationThickness: 2.5,
                                            fontFamily: 'Heebo',),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                                        child: Row(mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(Icons.monetization_on, color: Colors.amber, size:16),
                                            Container(margin: const EdgeInsets.only(left: 8),
                                              child: items[index].item.deleted == false ?
                                              items[index].item.itemsInStock > 0 ? Text(items[index].price.toStringAsFixed(2),
                                                style: TextStyle(fontWeight: FontWeight.bold,
                                                  fontFamily: 'Heebo',),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,) :
                                              Text("NOT ENOUGH STOCK",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red[900],
                                                  decorationThickness: 2.5,
                                                  fontFamily: 'Heebo',),) :
                                              Text("DELETED PRODUCT",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red[900],
                                                  decorationThickness: 2.5,
                                                  fontFamily: 'Heebo',),
                                                maxLines: 1,),
                                            )
                                          ],
                                        ),)
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                      );
                    },
                  ),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //SizedBox(height: 130.0),
                        // ignore: deprecated_member_use
                        FlatButton.icon(
                          onPressed: () async{
                            //placeOrder();
                            bool ordered = await placeOrder();
                            print("order returned " + ordered.toString());
                            if(ordered){
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('Order has been made. Check your email.')));
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => Template()));
                              //Navigator.pop(context);
                            }
                            else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('Order failed.')));
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => Template()));
                              print("order failed");
                            }
                          },
                          icon: Icon(Icons.shopping_basket, color: Colors.grey[900],),
                          label: Text(
                              'Complete Order',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24.0,
                                  fontFamily: 'Heebo',
                                  color: Colors.grey[900]
                              )
                          ),
                          color: Colors.amber,
                          shape: RoundedRectangleBorder
                            (side: BorderSide(
                              color: Colors.grey[900],
                              width: 3,
                              style: BorderStyle.solid
                          ), borderRadius: BorderRadius.circular(0)
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.0))
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Total Price: \$" + totalCartPrice.value.toStringAsFixed(2),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                            color: Colors.grey[900],
                            fontFamily: 'Heebo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            else{
              return Center(child: Text('No items in the cart.'),);
            }
          }
      ),
    );
  }
}