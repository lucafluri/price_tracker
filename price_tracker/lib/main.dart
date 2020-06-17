import 'package:flutter/material.dart';
import 'package:price_tracker/database_helper.dart';
import 'package:price_tracker/product.dart';
import 'package:price_tracker/productTile.dart';

void main() {
  runApp(MyApp());
}


// TODO pass Product to ProductTile
// TODO Add Products and Tiles via button
// TODO Product Image Handling (async loading)
// TODO edit Product Details => Details (Settings) View (with future Graph)
// TODO Webscraping Test
// TODO Background Service check
// TODO Notifications Test
// TODO Chart from price data
// TODO Trigger regular Scrapes of all Products in db
// TODO Trigger Notifications after Price fall
// TODO Show recent price change with icon in ListTile
// TODO Enlarge ListTile (+ bigger Picture)

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

  void initState(){
    super.initState();
  }

  // List<double> t = [232.4535, 45455.2342, 54536.342423];
 

  List<Widget> productTiles = <Widget>[];

  @override
  Widget build(BuildContext context) {
    // debugPrint(t.toString().substring(1, t.toString().length-1));
    
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

