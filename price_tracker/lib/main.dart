import 'package:flutter/material.dart';
import 'package:price_tracker/database_helper.dart';
import 'package:price_tracker/product.dart';
import 'package:price_tracker/productTile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Price Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        // primarySwatch: Colors.yellow,
        primaryColor: Colors.yellow[400],
        accentColor: Colors.yellowAccent[400],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      //Routes
      initialRoute: "/",
      routes: {
        "/": (context) => MyHomePage(title: 'Price Tracker'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;

  // List<double> t = [232.4535, 45455.2342, 54536.342423];
 

  List<Widget> productTiles = <Widget>[];

  @override
  Widget build(BuildContext context) {
    // debugPrint(t.toString().substring(1, t.toString().length-1));
    // dbHelper.insert(new Product(name: "Test", productUrl: "http://www.google.com"));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: productTiles
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          setState(() {
            productTiles = [...productTiles, ProductTile()];
            debugPrint(productTiles.toString());
          })
        },
        tooltip: 'Add Product',
        child: Icon(Icons.add),
      ),
    );
  }
}

