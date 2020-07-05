import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clipboard_manager/flutter_clipboard_manager.dart';
import 'package:frefresh/frefresh.dart';
import 'package:price_tracker/models/product.dart';
import 'package:price_tracker/screens/home/home.dart';
import 'package:price_tracker/services/database.dart';
import 'package:price_tracker/services/product_utils.dart';
import 'package:toast/toast.dart';

class HomeScreenController extends State<HomeScreen> {
  FRefreshController refreshController = FRefreshController();

  bool loading = false;
  List<Product> products = <Product>[];
  String pullToRefreshText = "Pull to refresh";
  bool iConnectivity = true;

  @override
  void initState() {
    refreshController.setOnStateChangedCallback(_onPullRefreshStateChanged);
    _loadProducts();
    _checkInternet();
    super.initState();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  _checkInternet() async{
    try{
      final result = await InternetAddress.lookup('google.com');
      if(result.isNotEmpty && result[0].rawAddress.isNotEmpty){
        print('connected to internet');
        iConnectivity = true;
      }
    }on SocketException catch(_){
      print('NOT connected to internet');
      iConnectivity = false;
      Toast.show('Please ensure an internet connection', context, duration: 3, gravity: Toast.BOTTOM);
    }
  }

  Future<void> _loadProducts() async {
    loading = true;
    setState(() {});

    final _db = await DatabaseService.getInstance();

    return _db.getAllProducts().then((value) {
          products = value;
          loading = false;
          setState(() {});
        });
  }

  void _onPullRefreshStateChanged(state) {
    setState(() {
      switch (state) {
        case RefreshState.PREPARING_REFRESH:
          pullToRefreshText = "Release to refresh";
          break;
        case RefreshState.REFRESHING:
          pullToRefreshText = "Loading...";
          break;
        case RefreshState.FINISHING:
          pullToRefreshText = "Refresh completed";
          break;
        default:
          pullToRefreshText = "Pull to refresh";
          break;
      }
    });
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
      loading = true;
      setState(() {});
      Toast.show("Product details are being parsed", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      Product p = Product(productUrl: input);
      if (await p.init()) {
        final _db = await DatabaseService.getInstance();
        await _db.insert(p);
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

  void deleteProduct(Product product) async {
    final _db = await DatabaseService.getInstance();

    await _db.delete(product.id);
    debugPrint('Deleted Product ${product.name}');

    _loadProducts();
  }

  void onRefresh() async {
    await updatePrices();
    await _loadProducts();

    refreshController.finishRefresh();
  }

  @override
  Widget build(BuildContext context) => HomeScreenView(this);
}
