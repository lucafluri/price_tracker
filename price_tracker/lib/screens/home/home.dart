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
  FRefreshController _refreshController = FRefreshController();

  List<Product> _products = <Product>[];
  String _pullToRefreshText = "Pull to refresh";

  @override
  void initState() {
    _refreshController.setOnStateChangedCallback(_onPullRefreshStateChanged);
    _loadProducts();

    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() {
    final db = DatabaseService.instance;

    return db.getAllProducts().then((products) => {
          setState(() {
            _products = products;
          })
        });
  }

  void _addProduct() async {
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
        await DatabaseService.instance.insert(p);
      } else {
        Toast.show("Parsing error, invalid store URL?", context,
            duration: 4, gravity: Toast.BOTTOM);
        // await FlutterClipboardManager.copyToClipBoard("");
      }

      _loadProducts();
    } else {
      if (input != null)
        Toast.show("Invalid URL or unsupported store", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _deleteProduct(Product product) async {
    await DatabaseService.instance.delete(product.id);
    debugPrint('Deleted Product ${product.name}');

    _loadProducts();
  }

  void _onRefresh() async {
    await updatePrices();
    await _loadProducts();

    _refreshController.finishRefresh();
  }

  void _onPullRefreshStateChanged(RefreshState state) {
    setState(() {
      switch (state) {
        case RefreshState.PREPARING_REFRESH:
          _pullToRefreshText = "Release to refresh";
          break;
        case RefreshState.REFRESHING:
          _pullToRefreshText = "Loading...";
          break;
        case RefreshState.FINISHING:
          _pullToRefreshText = "Refresh completed";
          break;
        default:
          _pullToRefreshText = "Pull to refresh";
          break;
      }
    });
  }

  Widget _buildAppBar() {
    return AppBar(
      elevation: 0,
      brightness: Brightness.dark,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      title: Text('Price Tracker BETA',
          style: TextStyle(color: Theme.of(context).primaryColor)),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.help_outline),
          onPressed: () => Navigator.of(context).pushNamed("/intro"),
        ),
        IconButton(
          icon: Icon(Icons.description),
          onPressed: () => Navigator.of(context).pushNamed("/credits"),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _addProduct,
      tooltip: 'Add Product',
      child: Icon(Icons.add),
    );
  }

  Widget _buildPullRefreshHeader(setter, constraints) {
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
              _pullToRefreshText,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        child: ScrollConfiguration(
          behavior: EmptyScrollBehavior(),
          child: FRefresh(
              controller: _refreshController,
              headerTrigger: 100,
              headerHeight: 50,
              headerBuilder: _buildPullRefreshHeader,
              onRefresh: _onRefresh,
              child: Column(
                children: <Widget>[
                  if (_products.length == 0)
                    Center(child: CircularProgressIndicator()),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _products.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ProductListTile(
                        id: _products[index].id,
                        onDelete: () => _deleteProduct(_products[index]),
                      );
                    },
                  ),
                  Container(height: 70)
                ],
              )),
        ),
      ),
      floatingActionButton: _buildFAB(),
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