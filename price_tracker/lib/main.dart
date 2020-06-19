import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clipboard_manager/flutter_clipboard_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frefresh/frefresh.dart';
import 'package:price_tracker/database_helper.dart';
import 'package:price_tracker/product.dart';
import 'package:price_tracker/productTile.dart';
import 'package:price_tracker/product_parser.dart';
import 'package:price_tracker/intro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:workmanager/workmanager.dart';
import 'package:after_layout/after_layout.dart';

String appName = "Price Tracker v0.1.0";

// --TODO pass Product to ProductTile
// --TODO Add Products and Tiles via button
// --TODO Product Image Handling (async loading)
// --TODO edit Product Details => Details (Settings) View (with future Graph)
// --TODO Webscraping Test
// --TODO Background Service check
// --TODO Notifications Test
// --TODO Chart from price data
// --TODO Trigger regular Scrapes of all Products in db
// --TODO Trigger Notifications after Price fall
// --TODO Show recent price change with icon in ListTile
// TODO Enlarge ListTile (+ bigger Picture)
// TODO Styling
// --TODO Show onboarding help screens
// --TODO show fail toast if pasted link didn't work, or scraping failed
// TODO Offline Functionality => Detect Internet State and (Placeholder Images) disable adding

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager.initialize(callbackDispatcher, isInDebugMode: false);
  print('init work manager');

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  runApp(MyApp());
}

Future<int> checkPriceFall() async {
  final dbHelper = DatabaseHelper.instance;

  List<Product> products = await dbHelper.getAllProducts();

  int count = 0;

  for (int i = 0; i < products.length; i++) {
    //Check difference to yesterday
    if (products[i].prices.length > 1) {
      if (products[i].prices[products[i].prices.length - 1] <
          products[i].prices[products[i].prices.length - 2]) {
        if (products[i].prices[products[i].prices.length - 1] != -1) count++;
      }
    }
  }
  return count;
}

Future<int> checkPriceUnderTarget() async {
  final dbHelper = DatabaseHelper.instance;

  List<Product> products = await dbHelper.getAllProducts();

  int count = 0;

  for (int i = 0; i < products.length; i++) {
    //Target Price
    if (products[i].prices[products[i].prices.length - 1] <
        products[i].targetPrice) {
      // debugPrint(products[i].name.substring(0, 20) + " is under Target of ${products[i].targetPrice}");
      if (products[i].prices[products[i].prices.length - 1] != -1) count++;
    }
  }
  return count;
}

void pushNotification(int id, String title, String body) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(id, title, body, platformChannelSpecifics, payload: 'item x');
}

void callbackDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Init Notifications Plugin
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  Workmanager.executeTask((taskName, inputData) async {
    switch (taskName) {
      case "Price Tracker Scraper":
        try {
          updatePrices();
          print("Executed Task");
        } catch (e) {}

        break;
    }
    return Future.value(true);
  });
}

Future<void> updatePrices({test: false}) async {
  final dbHelper = DatabaseHelper.instance;

  List<Product> products = await dbHelper.getAllProducts();
  for (int i = 0; i < products.length; i++) {
    await products[i].update(test: test);
    await dbHelper.update(products[i]);
  }

  products = await dbHelper.getAllProducts();
  int countFall = await checkPriceFall();
  int countTarget = await checkPriceUnderTarget();

  if (countFall > 0) {
    if (countFall == 1) {
      pushNotification(0, '$countFall Product is cheaper',
          'We detected that $countFall is cheaper today!'); //Display Notification
    } else {
      pushNotification(0, '$countFall Products are cheaper',
          'We detected that $countFall are cheaper today!'); //Display Notification
    }
  }
  if (countTarget > 0) {
    if (countTarget == 1) {
      pushNotification(1, '$countTarget Product is under their target!',
          'We detected that $countTarget Product is under the set target today!'); //Display Notification
    } else {
      pushNotification(1, '$countTarget Products are under their target!',
          'We detected that $countTarget Products are under the set targets today!'); //Display Notification
    }
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        // primarySwatch: Colors.yellow,
        primaryColor: Colors.yellow[400],
        accentColor: Colors.yellowAccent[400],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      //Routes
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => Splash(),
        "/": (context) => MyHomePage(title: appName),
        "/intro": (context) => Intro(),
      },
    );
  }
}

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> with AfterLayoutMixin<Splash> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
    } else {
      await prefs.setBool('seen', true);
      Navigator.of(context).pushNamedAndRemoveUntil("/intro", (route) => false);
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new CircularProgressIndicator(),
      ),
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
    //TODO CHANGE TO 12-24 Hours
    Workmanager.registerPeriodicTask("priceScraping", "Price Tracker Scraper",
        frequency: Duration(hours: 1));

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

  void addProduct() async {
    String input = await FlutterClipboardManager.copyFromClipBoard();
    // debugPrint(ProductParser.validUrl(input).toString());

    List<String> inputs = (await showTextInputDialog(
      context: context,
      textFields: [
        DialogTextField(
            initialText: ProductParser.validUrl(input) ? input : "",
            hintText:
                ProductParser.validUrl(input) ? "Paste from Clipboard" : "")
      ],
      title: "Add new Product",
      message: "Paste Link to Product. \n\nSupported Stores:\n" +
          ProductParser.possibleDomains
              .toString()
              .replaceAll("[", "")
              .replaceAll("]", ""),
    ));
    input = inputs != null ? inputs[0] : inputs;

    if (input != null && ProductParser.validUrl(input)) {
      Toast.show("Product details are being parsed", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      Product p = Product(productUrl: input);
      if (await p.update()) {
        await dbHelper.insert(p);
      } else {
        Toast.show("Parsing error, invalid store URL?", context,
            duration: 4, gravity: Toast.BOTTOM);
        // await FlutterClipboardManager.copyToClipBoard("");
      }

      setState(() {});
    } else {
      if (input != null)
        Toast.show("Invalid URL or unsupported store", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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
            icon: Icon(Icons.help_outline),
            onPressed: () {
              Navigator.of(context).pushNamed("/intro");
              setState(() {});
            },
          ),
          FlatButton(
            child: Text(
              "TEST",
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () async {
              await updatePrices(test: true);
              setState(() {});
            },
          ),
        ],
      ),
      body: Container(
        child: FRefresh(
          controller: controller,
          headerTrigger: 75,
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
                  textRefresh = "Pull to Refresh";
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
            await updatePrices();

            // Check if MyHomePage is still mounted otherwise setState gets called on a unmounted widget => crash
            if (this.mounted)
              setState(() {
                controller.finishRefresh();
              });
          },
          child: FutureBuilder(
              future: dbHelper.getAllProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: <Widget>[
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ProductTile(
                            id: snapshot.data[index].id,
                            onDelete: () async {
                              dbHelper.delete(snapshot.data[index].id);
                              debugPrint(
                                  'Deleted Product ${snapshot.data[index].name}');
                              setState(() {});
                            },
                          );
                        },
                      ),
                      Container(height: 70)
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addProduct,
        tooltip: 'Add Product',
        child: Icon(Icons.add),
      ),
    );
  }
}
