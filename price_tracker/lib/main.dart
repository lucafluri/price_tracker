import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:price_tracker/database_helper.dart';
import 'package:price_tracker/product.dart';
import 'package:price_tracker/productTile.dart';
import 'package:price_tracker/price_parser.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:xpath_parse/xpath_selector.dart';

void main() {
  runApp(MyApp());
}

// --TODO pass Product to ProductTile
// TODO Add Products and Tiles via button
// --TODO Product Image Handling (async loading)
// TODO edit Product Details => Details (Settings) View (with future Graph)
// --TODO Webscraping Test
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

  void initState() {
    super.initState();
  }

  // List<double> t = [232.4535, 45455.2342, 54536.342423];

  List<Widget> productTiles = <Widget>[];

  void test() async {
    // debugPrint(await PriceParser.test("https://www.digitec.ch/en/s1/product/icy-box-ib-ms303-t-table-27-monitor-mounts-10332070"));
    // debugPrint(await PriceParser.test("https://www.digitec.ch/en/s1/product/ducky-one-2-sf-ch-cable-keyboards-12826095"));
    // debugPrint(await PriceParser.test("https://www.digitec.ch/en/s1/product/digitec-connect-mobile-subscription-with-a-12-month-data-flat-rate-unlimited-sim-card-12409780"));
    // debugPrint(await PriceParser.test("https://www.galaxus.ch/de/s3/product/uvex-sportstyle-706-vario-sportbrille-7587273"));
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint(t.toString().substring(1, t.toString().length-1));

    test();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
            future: dbHelper.getAllProducts(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Widget> productTiles = <Widget>[];
                snapshot.data
                    .forEach((e) => productTiles.add(ProductTile(product: e)));

                return ListView(children: productTiles);
              }else{
                return Center(child: CircularProgressIndicator());
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          // TODO Open Detail Dialogue to edit Product Details

          setState(() {
            dbHelper.insert(Product());
          })
        },
        tooltip: 'Add Product',
        child: Icon(Icons.add),
      ),
    );
  }
}
