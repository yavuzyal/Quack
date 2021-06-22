import 'dart:convert';
import 'dart:io';
import 'package:cs308_project/entity/Cart.dart';
import 'package:cs308_project/entity/CartItem.dart';
import 'package:cs308_project/entity/Item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

import 'CreditCardScreen.dart';
import 'LoginScreen.dart';

class CartScreen extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => cartDetailState();

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


Future<void> deleteItem(String id) async{
  if(globals.isLoggedIn)
  {
    var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/cart/removeItem");
    final response = await http.delete(
        apiURL,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader : "Bearer " + globals.accessToken,
        },
        body: jsonEncode(<String, String>{
          "productId": id,
        },
        ));
    final body = jsonDecode(response.body);
    print(body["success"]);
  }
  else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globals.nonLoggedInItems = prefs.getStringList('notLoginItems');
    String toBeDeleted;
    for (String s in globals.nonLoggedInItems)
    {
      String productID = s.substring(12, s.indexOf(','));
      if (productID == id)
        toBeDeleted = s;
    }
    globals.nonLoggedInItems.remove(toBeDeleted);
    prefs.setStringList('notLoginItems', globals.nonLoggedInItems);
  }

}

Future<String> updateItem(String id, int updatedQuantity) async{
  // for pushing not related to method
  if (globals.isLoggedIn)
  {
    var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/cart/updateQuantity");
    final response = await http.put(
        apiURL,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader : "Bearer " + globals.accessToken,
        },
        body: jsonEncode(<String, dynamic>{
          "productId": id,
          "quantity": updatedQuantity,
        },
        ));
    final body = jsonDecode(response.body);
    print(body);
    print(body["success"]);
    if (body['success'])
      return "Successful.";
    else
    {
      String msg = body['error'];
      if (msg == "Invalid Quantity, use remove!")
        return "Swipe left to delete.";
      else if (msg == "Not enough stock!")
        return msg;
    }
  }
  else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> idQuantityList = prefs.getStringList('notLoginItems');
    int index = -1;
    for (String s in idQuantityList)
    {
      index++;
      //print(s);
      String productID = s.substring(12, s.indexOf(','));
      if (productID == id)
      {
        String newStr = "{productId: " + id + ", quantity: " + updatedQuantity.toString() + "}";
        idQuantityList.replaceRange(index, index+1, [newStr]);
      }
    }
    globals.nonLoggedInItems = idQuantityList;
    prefs.setStringList('notLoginItems', globals.nonLoggedInItems);
    return "Successful.";
  }
  return "";
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
class cartDetailState extends State<CartScreen>{
  List<CartItem> items;
  TextEditingController dummyController = new TextEditingController(text: "-");
  @override
  Widget build(BuildContext context) {
    var totalCartPrice = new PrimitiveWrapper(0);
    // ignore: deprecated_member_use
    var controllerList = new PrimitiveWrapper(new List<TextEditingController>());
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart',
            style: TextStyle(color: Colors.grey[900],
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Heebo',
                  letterSpacing: 1.5,
                  fontSize: 24.0)
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
        automaticallyImplyLeading: false,
        actions: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right:5),
                child: Text(
                    "BUY",
                    style: TextStyle(color: Colors.grey[900],
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Heebo',
                        letterSpacing: 2.0)),
              ),
            ],
          ),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  if (globals.isLoggedIn)
                  {
                    if (!checkForStockAndDeleted(items))
                    {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Please remove deleted and/or out of stock items from your cart.')));
                    }
                    else
                    {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CreditCardPage()));
                    }
                  }
                  else{
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Please login to continue.')));
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  }
                },
                child: Icon(
                  Icons.payment,
                  size: 26.0,
                  color: Colors.grey[900],
                ),
              )
          ),
        ],
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
                                Center(
                                  child: Container(
                                    width: 60.0,
                                    foregroundDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                        color: Colors.grey[900],
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: TextFormField(
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Heebo',
                                              fontSize: 18,
                                            ),
                                            //initialValue: items[index].quantity.toString(),
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(8.0),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(5.0),
                                              ),
                                            ),
                                            onFieldSubmitted: (value) async {
                                              int currentValue = int.parse(value);
                                              String result = await updateItem(items[index].item.id, currentValue);
                                              // ignore: non_constant_identifier_names
                                              List<CartItem> UpdatedItems = await getCart(totalCartPrice, controllerList);
                                              if (result != "Successful.")
                                                ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(content: Text(result)));
                                              setState(() {
                                                items = UpdatedItems;
                                              });
                                            },
                                            controller: index <= controllerList.value.length - 1 ? controllerList.value[index] : dummyController,
                                            keyboardType: TextInputType.numberWithOptions(
                                              decimal: false,
                                              signed: false,
                                            ),
                                            inputFormatters: <TextInputFormatter>[
                                              // ignore: deprecated_member_use
                                              WhitelistingTextInputFormatter.digitsOnly
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 50.0,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.amber,
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                ),
                                                child: InkWell(
                                                  child: Icon(
                                                    Icons.arrow_drop_up,
                                                    size: 24.0,
                                                  ),
                                                  onTap: () async{
                                                    int currentValue = int.parse(controllerList.value[index].text) + 1;
                                                    String result = await updateItem(items[index].item.id, currentValue);
                                                    // ignore: non_constant_identifier_names
                                                    List<CartItem> UpdatedItems = await getCart(totalCartPrice, controllerList);
                                                    if (result != "Successful.")
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(SnackBar(content: Text(result)));
                                                    setState(() {
                                                      items = UpdatedItems;
                                                    });
                                                  },
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.amber,
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                ),
                                                child: InkWell(
                                                  child: Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 24.0,
                                                  ),
                                                  onTap: () async{
                                                    int currentValue = int.parse(controllerList.value[index].text) - 1;
                                                    String result = await updateItem(items[index].item.id, currentValue);
                                                    // ignore: non_constant_identifier_names
                                                    List<CartItem> UpdatedItems = await getCart(totalCartPrice, controllerList);
                                                    if (result != "Successful.")
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(SnackBar(content: Text(result)));
                                                    setState(() {
                                                      currentValue++;
                                                      items = UpdatedItems;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    ),
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      secondaryActions: [
                        IconSlideAction(
                          caption: 'Delete',
                          icon: Icons.delete,
                          color: Colors.red,
                          onTap: () async{
                            //DELETE WILL BE IMPLEMENTED HERE
                            print("Delete pressed for " + items[index].item.name);
                            deleteItem(items[index].item.id);
                            // ignore: non_constant_identifier_names
                            List<CartItem> UpdatedItems = await getCart(totalCartPrice, controllerList);
                            setState((){
                              items = UpdatedItems;
                            });
                          },
                        )
                      ],
                    );
                  },
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
                        "Cart Total: \$" + totalCartPrice.value.toStringAsFixed(2),
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
            return Center(child: CircularProgressIndicator());
          }
        }
      ),
      );
  }
}