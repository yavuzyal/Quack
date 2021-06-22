import 'dart:convert';
import 'dart:io';
import 'package:cs308_project/entity/HomeItem.dart';
import 'package:cs308_project/screens/ProductScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:cs308_project/globals/GlobalVariables.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

// ignore: non_constant_identifier_names
Future<List<HomeItem>> GetItems () async {
  //print("get items called");
  var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/product/getAll");
  final response = await http.get(
      apiURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }
  );
  final body = jsonDecode(response.body);
  //print(body["data"]);
  if (body["status"]) {
    return List<HomeItem>.from(body["data"].map((x) => HomeItem.fromJson(x)));
  }
  return [];
}

// ignore: non_constant_identifier_names
Map<String, dynamic> HomeItemToJson(String itemID) => {
  'productId': itemID,
  'quantity': "1",
};

// ignore: non_constant_identifier_names
Future<String> AddItemToCart (String itemID) async {
  if (globals.isLoggedIn)
  {
    var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/cart/addItemstoCart");
    final response = await http.post(
        apiURL,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader : "Bearer " + globals.accessToken,
        },
        body: jsonEncode(<String, String>{
          "productId" : itemID,
          "quantity" : "1",
        }
        )
    );
    final body = jsonDecode(response.body);
    print(body);
    if (body["success"] == false)
    {
      String message = body["error"];
      //print(message);
      if (message == "Such a product does not exist in our database!")
        return "An error at server occurred. Sorry :(";
      else if (message == "This item already exists, please send an update request!")
        return "You already have this item in your cart. Go there to buy many!";
      else if (message == "You tried to buy more than what we have in the stock!")
        return "Not enough stock. Sorry :(";
      else if (message == "Quantity cannot be negative dear!")
        return "Quantity cannot be negative.";
      else
        return "We have failed everything.";
    }
    else
      return "Item added to your cart.";

  }
  else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globals.nonLoggedInItems = prefs.getStringList('notLoginItems');
    if (globals.nonLoggedInItems.toString().indexOf(HomeItemToJson(itemID).toString().substring
      (0, HomeItemToJson(itemID).toString().indexOf(','))) != -1)
      return "You already added this item to your cart. Go there to buy many!";
    globals.nonLoggedInItems.add(HomeItemToJson(itemID).toString());
    for (String item in globals.nonLoggedInItems)
      print(item);
    prefs.setStringList('notLoginItems', globals.nonLoggedInItems);
    return "Item added to your cart.";
  }

}

class HomeScreenState extends State<HomeScreen> {

  final TextEditingController searchController = new TextEditingController();
  final TextEditingController catController = new TextEditingController();
  final TextEditingController minController = new TextEditingController();
  final TextEditingController maxController = new TextEditingController();
  List<HomeItem> items;
  int rebuild = 0;
  String dropdownValue = 'No Sorting';
  String catValue = 'All';
  String minFilter = "", maxFilter = "";

  List <String> catSpinnerItems =
  [ 'All',
    'Apparel',
    'Accessories',
    'Quacks',
    'For Home and Office',
    'Adoption'
  ];

  List <String> spinnerItems =
  [ 'No Sorting',
    'Price - Low to High',
    'Price - High to Low',
    'Best Selling',
    'Views - High to Low',
    'Rating - High to Low',
    'Discount - High to Low'
  ];

  Future<List<HomeItem>> searchPressed() async {
    //print("search pressed called");
    String sortAtt = "";
    if (dropdownValue == spinnerItems[1])
      sortAtt = "unitPrice";
    else if (dropdownValue == spinnerItems[2])
      sortAtt = "-unitPrice";
    else if (dropdownValue == spinnerItems[3])
      sortAtt = "-purchased";
    else if (dropdownValue == spinnerItems[4])
      sortAtt = "-viewNumber";
    else if (dropdownValue == spinnerItems[5])
      sortAtt = "-rating";
    else if (dropdownValue == spinnerItems[6])
      sortAtt = "-salesPercent";

    String catAtt = "";
    if (catValue == catSpinnerItems[1])
      catAtt = "&category=Apparel";
    else if (catValue == catSpinnerItems[2])
      catAtt = "&category=Accessories";
    else if (catValue == catSpinnerItems[3])
      catAtt = "&category=Quacks";
    else if (catValue == catSpinnerItems[4])
      catAtt = "&category=For+Home+and+Office";
    else if (catValue == catSpinnerItems[5])
      catAtt = "&category=Adoption";

    String filterAtt = "";
    if (minFilter != "")
      filterAtt += "&unitPrice[gte]=" + minFilter;
    if (maxFilter != "")
      filterAtt += "&unitPrice[lte]=" + maxFilter;

    List<String> searchTextList = searchController.text.split(" ");
    String query = searchTextList[0];
    for (String s in searchTextList.sublist(1))
      query += "+" + s;
    //print(query);
    var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/product/"
        "search?q=" + query + "&sort=" + sortAtt + filterAtt + catAtt);
    final response = await http.get(
        apiURL,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
    );
    var body = jsonDecode(response.body);
    // ignore: deprecated_member_use
    //print(body);
    // ignore: deprecated_member_use
    List<HomeItem> newList = new List();
    newList = List<HomeItem>.from(body["data"].map((x) => HomeItem.fromJson(x)));
    int pageNumber = 2;
    //print(body['pagination']['next']);
    bool loopContinue = body['pagination']['next'] != null;
    while (loopContinue)
    {
      //print(body['pagination']['next']);
      //print("inside while");
      String pageQuery = "&page=" + pageNumber.toString();
      var apiURL = Uri.parse("https://protected-everglades-33662.herokuapp.com/product/"
          "search?q=" + query + "&sort=" + sortAtt + filterAtt + catAtt + pageQuery);
      final response = await http.get(
        apiURL,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      body = jsonDecode(response.body);
      if (body['pagination']['next'] == null)
        loopContinue = false;
      //print(loopContinue);
      // ignore: deprecated_member_use
      List<HomeItem> pageList = new List();
      pageList = List<HomeItem>.from(body["data"].map((x) => HomeItem.fromJson(x)));
      newList.addAll(pageList);
      pageNumber++;
    }
    //print("here");
    print(newList.length);
    if (body["success"]) {
      return newList;
    }
    return [];
  }

  // ignore: non_constant_identifier_names
  FilterPopUp(context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          backgroundColor: Colors.grey[900],
          title: Text(
              "Choose filter...",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontFamily: 'Heebo',
          )),
          content: Container(
            height: 200,
            width: 400,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Category:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Heebo',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.grey[900],),
                      child: DropdownButton<String>(
                        value: catValue,
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 30,
                        elevation: 10,
                        style: TextStyle(color: Colors.grey[900], fontSize: 16),
                        underline: Container(
                          height: 2,
                          color: Colors.white,
                        ),
                        onChanged: (String data) {
                          setState(() {
                            catValue = data;
                          });
                        },
                        items: catSpinnerItems.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sort:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Heebo',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.grey[900],),
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 30,
                        elevation: 10,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        underline: Container(
                          height: 2,
                          color: Colors.white,
                        ),
                        onChanged: (String data) {
                          setState(() {
                            dropdownValue = data;
                          });
                        },
                        items: spinnerItems.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Price:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Heebo',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 50,
                      child: TextField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        controller: minController,
                        decoration: new InputDecoration(
                            hintText: "\$MIN",
                            hintStyle: TextStyle(
                                color: Colors.white
                            ),
                            ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ], // Only numbers can be entered
                      ),
                    ),
                    SizedBox(width: 10,),
                    Container(
                      width: 50,
                      child: TextField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        controller: maxController,
                        decoration: new InputDecoration(
                            hintText: "\$MAX",
                            hintStyle: TextStyle(
                              color: Colors.white
                            )),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ], // Only numbers can be entered
                      ),
                    ),
                    // ignore: deprecated_member_use
                  ],
                ),
                // ignore: deprecated_member_use
                FlatButton.icon(
                  label: Text("Filter"),
                  icon: Icon(Icons.filter_alt_outlined),
                  color: Colors.amber,
                  shape: RoundedRectangleBorder
                    (side: BorderSide(
                      color: Colors.black,
                      width: 3,
                      style: BorderStyle.solid
                  ), borderRadius: BorderRadius.circular(10)
                  ),
                  onPressed: () {
                    setState(() {
                      minFilter = minController.text;
                      maxFilter = maxController.text;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ignore: non_constant_identifier_names
  void RefreshPage()
  {
    setState(() {
      rebuild++;
    });
  }

  @override
  Widget build(BuildContext context) {
    //print("rebuilt");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        leading: new IconButton(
          icon: Icon(Icons.search, color: Colors.grey[900]),
          onPressed: () {
            setState(() {
              rebuild++;
            });
          },
        ),
        title: TextField(
          controller: searchController,
          decoration: new InputDecoration(
              hintText: 'Search...'
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear, color: Colors.grey[900]),
            onPressed: () {
              searchController.text = "";
              minController.text = "";
              maxController.text = "";
              dropdownValue = spinnerItems[0];
              catValue = catSpinnerItems[0];
              setState(() {
                rebuild++;
              });
            },
          ),
        ],
      ),
        body: Column(
          children: [
            // ignore: deprecated_member_use
            FlatButton.icon(
              label: Text(
                  "Filter Results",
                  style: TextStyle(
                    fontFamily: 'Heebo',
                    fontSize: 20,
                  ),),
              icon: Icon(Icons.filter_alt_outlined),
              color: Colors.amber,
              shape: RoundedRectangleBorder
                (side: BorderSide(
                  color: Colors.black,
                  width: 3,
                  style: BorderStyle.solid
              ), borderRadius: BorderRadius.circular(10)
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      return FilterPopUp(context);
                    }).then((value) => RefreshPage());
              },
            ),
            Expanded(
              child: FutureBuilder(
                  future: searchController.text == "" && dropdownValue == spinnerItems[0]
                      && minFilter == "" && maxFilter == "" && catValue == catSpinnerItems[0] ? GetItems() : searchPressed(),
                  builder: (context, snapshot){
                    items = snapshot.data;
                    if(snapshot.hasData){ //snapshot.hasData
                      return Column(
                        children: [
                          Expanded(child: ListView.builder(
                            itemCount: items == null ? 0 : items.length,
                            itemBuilder: (context, index){
                              return GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ProductScreen(items[index].id)),
                                  );
                                },
                              child: Slidable(
                                actionPane: null,
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
                                              image: NetworkImage(items[index].imgURL),   //items[index].imageUrl
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
                                                child: Text(items[index].name,
                                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                                                    fontFamily: 'Heebo',),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                                                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    Icon(Icons.monetization_on_sharp, color: Colors.amber, size:20),
                                                    Container(margin: const EdgeInsets.only(left: 8),
                                                      child: Text("\$" + items[index].unitPrice.toStringAsFixed(2),
                                                        style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                                                          fontFamily: 'Heebo',),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,),)
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8, right: 8),
                                                child: Text(items[index].itemsInStock <= 0 ?
                                                "Sold out" : "In stock: " + items[index].itemsInStock.toString(),
                                                  style: TextStyle(fontSize: 16,
                                                    fontFamily: 'Heebo',
                                                  fontWeight: FontWeight.bold),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,),
                                              ),
                                            ],
                                          ),
                                        )),
                                        Column(
                                          children: [
                                            Center(
                                              // ignore: deprecated_member_use
                                              child: FlatButton.icon(
                                                label: Text("Add to Cart"),
                                                icon: Icon(Icons.shopping_bag_outlined),
                                                color: items[index].itemsInStock <= 0 ? Colors.grey : Colors.amber,
                                                shape: RoundedRectangleBorder
                                                  (side: BorderSide(
                                                    color: Colors.black,
                                                    width: 3,
                                                    style: BorderStyle.solid
                                                ), borderRadius: BorderRadius.circular(10)
                                                ),
                                                onPressed: () async {
                                                  if (items[index].itemsInStock <= 0)
                                                  {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(SnackBar(content: Text("Not enough stock.")));
                                                  }
                                                  else
                                                  {
                                                    String msg = await AddItemToCart(items[index].id);
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(SnackBar(content: Text(msg)));
                                                  }
                                                },
                                              )
                                            ),
                                            SizedBox(height: 5,),
                                            items[index].rating != null ? RatingBarIndicator(
                                              rating: items[index].rating.toDouble(),
                                              itemBuilder: (context, index) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              itemCount: 5,
                                              itemSize: 24.0,
                                              direction: Axis.horizontal,
                                            ) :
                                            Text(
                                              "Product not rated yet.",
                                            ),
                                            SizedBox(height: 5),
                                            items[index].salesPercent > 0 ? Container(
                                              padding: EdgeInsets.all(4.0),
                                              color: Colors.red[800],
                                              child: Text(
                                                "ON SALE -" + items[index].salesPercent.toStringAsFixed(2) + "%",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Heebo',
                                                  letterSpacing: 2.0,
                                                ),
                                              ),
                                            ) : SizedBox(height: 0.1),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              );},
                          ))
                        ],
                      );
                    }
                    else{
                      return Center(child: CircularProgressIndicator());
                    }
                  }
              ),
            ),
          ],
        )
    );
  }
}
