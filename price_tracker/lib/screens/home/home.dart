import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clipboard_manager/flutter_clipboard_manager.dart';
import 'package:frefresh/frefresh.dart';
import 'package:price_tracker/models/product.dart';
import 'package:price_tracker/screens/home/components/product_list_tile.dart';
import 'package:price_tracker/services/database.dart';
import 'package:price_tracker/services/product_utils.dart';
import 'package:toast/toast.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseService.instance;
  FRefreshController controller = FRefreshController();

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }


  List<Widget> productTiles = <Widget>[];

  void test() async {
    // await ProductParser.test("https://www.digitec.ch/de/product/fossil-collider-hybrid-hr-42mm-edelstahl-sportuhr-smartwatch-11773438#mobileModel");
    // await ProductParser.test("https://www.digitec.ch/en/s1/product/ducky-one-2-sf-ch-cable-keyboards-12826095");
    // await ProductParser.test("https://www.digitec.ch/en/s1/product/digitec-connect-mobile-subscription-with-a-12-month-data-flat-rate-unlimited-sim-card-12409780");
    // await ProductParser.test("https://www.galaxus.ch/de/s3/product/uvex-sportstyle-706-vario-sportbrille-7587273");

    // int id = await dbHelper.insert(Product());
    // debugPrint((await dbHelper.getProduct(id)).id.toString());
  }

  void addProduct() async {
    String input = await FlutterClipboardManager.copyFromClipBoard();

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
      if (await p.init()) {
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
    // dbHelper.deleteAll();
    String textRefresh = "Pull to refresh";

    test();

    return ScrollConfiguration(
      behavior: EmptyScrollBehavior(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          brightness: Brightness.dark,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          title: Text('Price Tracker BETA',
              style: TextStyle(color: Theme.of(context).primaryColor)),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                Navigator.of(context).pushNamed("/intro");
                setState(() {});
              },
            ),
            IconButton(
              icon: Icon(Icons.description),
              onPressed: () {
                Navigator.of(context).pushNamed("/credits");
              },
            ),
            // FlatButton(
            //   child: Text(
            //     "TEST",
            //     style: TextStyle(color: Colors.black),
            //   ),
            //   onPressed: () async {
            //     Workmanager.registerOneOffTask(
            //         "manualpriceScraping", "Manual Price Tracker Scraper");
            //     debugPrint("registeres one off task");
            //   },
            // ),
          ],
        ),
        body: Container(
          child: FRefresh(
            controller: controller,
            headerTrigger: 100,
            headerHeight: 50,
            headerBuilder: (setter, constraints) {
              controller.setOnStateChangedCallback((state) {
                setter(() {
                  if (controller.refreshState == RefreshState.PREPARING_REFRESH) {
                    textRefresh = "Release to refresh";
                  } else if (controller.refreshState == RefreshState.REFRESHING) {
                    textRefresh = "Loading...";
                  } else if (controller.refreshState == RefreshState.FINISHING) {
                    textRefresh = "Refresh completed";
                  } else {
                    textRefresh = "Pull to refresh";
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
                            return ProductListTile(
                              id: snapshot.data[index].id,
                              onDelete: () async {
                                await dbHelper.delete(snapshot.data[index].id);
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
      ),
    );
  }
}

class EmptyScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}