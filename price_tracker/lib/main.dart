import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clipboard_manager/flutter_clipboard_manager.dart';
import 'package:frefresh/frefresh.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:price_tracker/database_helper.dart';
import 'package:price_tracker/product.dart';
import 'package:price_tracker/productTile.dart';
import 'package:price_tracker/product_parser.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:toast/toast.dart';
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
  FRefreshController controller = FRefreshController();

  void initState() {
    super.initState();
  }

  // List<double> t = [232.4535, 45455.2342, 54536.342423];

  List<Widget> productTiles = <Widget>[];

  void test() async {
    // await ProductParser.test("https://www.digitec.ch/en/s1/product/icy-box-ib-ms303-t-table-27-monitor-mounts-10332070");
    // await ProductParser.test("https://www.digitec.ch/en/s1/product/ducky-one-2-sf-ch-cable-keyboards-12826095");
    // await ProductParser.test("https://www.digitec.ch/en/s1/product/digitec-connect-mobile-subscription-with-a-12-month-data-flat-rate-unlimited-sim-card-12409780");
    // await ProductParser.test("https://www.galaxus.ch/de/s3/product/uvex-sportstyle-706-vario-sportbrille-7587273");

    // int id = await dbHelper.insert(Product());
    // debugPrint((await dbHelper.getProduct(id)).id.toString());
  }

  Future<void> updatePrices() async {
    List<Product> products = await dbHelper.getAllProducts();
    for (int i = 0; i < products.length; i++) {
      await products[i].update();
      await dbHelper.update(products[i]);
      setState(() {
        controller.refreshState = RefreshState.REFRESHING;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint(t.toString().substring(1, t.toString().length-1));
    // dbHelper.deleteAll();
    String textRefresh = "";

    test();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              debugPrint("Deleted all products");
              dbHelper.deleteAll();
              setState(() {});
            },
          )
        ],
      ),
      body: Container(
        child: FRefresh(
          controller: controller,
          headerBuilder: (setter, constraints) {
            controller.setOnStateChangedCallback((state) {
              setter(() {
                if (controller.refreshState == RefreshState.PREPARING_REFRESH) {
                  textRefresh = "Release to Refresh";
                } else if (controller.refreshState == RefreshState.REFRESHING) {
                  textRefresh = "Loading...";
                } else if (controller.refreshState == RefreshState.FINISHING) {
                  textRefresh = "Refresh completed";
                } else {
                  textRefresh = "Loading...";
                }
              });
            });

            return Container(
                height: 50,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        backgroundColor: Theme.of(context).primaryColor,
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryTextTheme.caption.color),
                        strokeWidth: 2.0,
                      ),
                    ),
                    const SizedBox(width: 9.0),
                    Text(
                      textRefresh,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ));
          },
          headerHeight: 50,
          onRefresh: () async {
            updatePrices().then((e) => controller.finishRefresh());
          },
          child: FutureBuilder(
              future: dbHelper.getAllProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ProductTile(id: snapshot.data[index].id);
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String input = await FlutterClipboardManager.copyFromClipBoard();
          // debugPrint(ProductParser.validUrl(input).toString());
          if(!ProductParser.validUrl(input)){
            input = (await showTextInputDialog(
              context: context,
              textFields: [DialogTextField()],
              title: "Add new Product",
              message:
                  "Paste Link to Product. \n\nSupported Stores:\nDigitec.ch, Galaxus.ch",
            ))[0];
          }
          if (input != null && ProductParser.validUrl(input)) {
            Toast.show("Product Details are being parsed", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
            Product p = Product(productUrl: input);
            await p.update();
            await dbHelper.insert(p);
            setState(() {
            });
          }else{
            if(input != null) Toast.show("Invalid URL or unsupported store", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
          }
        },
        tooltip: 'Add Product',
        child: Icon(Icons.add),
      ),
    );
  }
}
