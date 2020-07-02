import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/widgets.dart';
import 'package:price_tracker/models/product.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:math';

import 'package:price_tracker/services/database.dart';

double roundDouble(double value, int places) {
  double mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

class ProductDetail extends StatefulWidget {
  final Product product;

  const ProductDetail({Key key, this.product,}) : super(key: key);
  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final dbHelper = DatabaseService.instance;
  var formatter = new DateFormat('yyyy-MM-dd--HH:mm:ss');
  double sliderValue;

  final _targetInputController = TextEditingController();
  bool setTarget;
  bool canSetTarget;
  bool validTarget = false;

  Future<void> setTextField() async {
    Product p = await dbHelper.getProduct(widget.product.id);
    setTarget = p.targetPrice >= 0;
    canSetTarget = p.prices[p.prices.length - 1] > 0;
    if (setTarget) {
      _targetInputController.text = p.targetPrice.toString();
      validTarget = true;
    }
  }

  @override
  void initState() {
    setTextField();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
        return Future.value(true);
      },
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            brightness: Brightness.dark,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
            leading: BackButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("/", (route) => false);
              },
            ),
          ),
          body: FutureBuilder(
              future: dbHelper.getProduct(widget.product.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Product product = snapshot.data;

                  sliderValue = product.targetPrice;
                  if (sliderValue > product.prices[product.prices.length - 1] ||
                      sliderValue < 0)
                    sliderValue = product.prices[product.prices.length - 1];

                  List<DataPoint<DateTime>> chartData = [];
                  for (int i = 0; i < product.prices.length; i++) {
                    chartData.add(DataPoint(
                        value: product.prices[i], xAxis: product.dates[i]));
                  }

                  setTarget = product.targetPrice >= 0 &&
                      product.prices[product.prices.length - 1] > 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: SingleChildScrollView(
                      child: Center(
                          child: Column(
                        children: <Widget>[
                          Center(
                              child: Text(product.name,
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.headline5)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 250,
                              child: product.imageUrl != null
                                  ? OptimizedCacheImage(
                                      imageUrl: product.imageUrl,
                                      placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )
                                  : Container(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              color: Theme.of(context).primaryColor,
                              //Launch URL Button
                              onPressed: () async {
                                if (await canLaunch(product.productUrl))
                                  await launch(product.productUrl);
                                else
                                  throw "Could not launch URL";
                              },
                              child: Text(
                                "Open Product Site",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                                "Current Price: ${product.prices[product.prices.length - 1]}",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          Container(
                              child: CheckboxListTile(
                                  activeColor: Theme.of(context).primaryColor,
                                  checkColor: Colors.black,
                                  title: Text("Set Target Price?"),
                                  value: setTarget,
                                  onChanged: (e) async {
                                    if (canSetTarget) {
                                      if (e) {
                                        product.targetPrice =
                                            product.targetPrice.abs();
                                        await dbHelper.update(product);
                                        setState(() {
                                          _targetInputController.text =
                                              product.targetPrice.toString();
                                          validTarget = true;
                                        });
                                      } else {
                                        product.targetPrice =
                                            -product.targetPrice;
                                        await dbHelper.update(product);
                                        _targetInputController.text = "";
                                        setState(() {});
                                      }
                                    }
                                  })),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              enabled: setTarget,
                              expands: false,
                              controller: _targetInputController,
                              cursorColor: Theme.of(context).primaryColor,
                              decoration: new InputDecoration(
                                  labelText: product.targetPrice >= 0
                                      ? "Set Target Price"
                                      : "Target Price Disabled",
                                  errorText: validTarget
                                      ? null
                                      : "Invalid Target Price"),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                // _targetInputController.text = value;
                                try {
                                  double input;
                                  if (value.isNotEmpty) {
                                    input = double.parse(value);
                                    validTarget = input > 0 &&
                                        input <
                                            product.prices[
                                                product.prices.length - 1];
                                  } else {
                                    validTarget = false;
                                  }
                                } catch (e) {
                                  validTarget = false;
                                }
                                setState(() {});
                              },
                              onSubmitted: (value) async {
                                if (validTarget) {
                                  product.targetPrice =
                                      double.parse(value).abs();
                                  await dbHelper.update(product);
                                } else {
                                  _targetInputController.text =
                                      product.targetPrice.toString();
                                  validTarget = true;
                                }
                                setState(() {});
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 30),
                            child: Container(
                                //Bezier Chart Container
                                height: MediaQuery.of(context).size.height / 2,
                                width: MediaQuery.of(context).size.width,
                                child: BezierChart(
                                  fromDate: product.dates[0],
                                  toDate: DateTime.now(),
                                  selectedDate:
                                      product.dates[product.dates.length - 1],
                                  bezierChartScale: BezierChartScale.WEEKLY,
                                  series: [
                                    BezierLine(
                                      label: "Price",
                                      data: chartData,
                                    ),
                                  ],
                                  config: BezierChartConfig(
                                    verticalIndicatorStrokeWidth: 3.0,
                                    verticalIndicatorColor:
                                        Theme.of(context).primaryColor,
                                    showVerticalIndicator: true,
                                    verticalIndicatorFixedPosition: false,
                                    backgroundColor: Colors.transparent,
                                    footerHeight: 30.0,
                                    displayYAxis: true,
                                    displayLinesXAxis: true,
                                    updatePositionOnTap: false,
                                    pinchZoom: true,
                                  ),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                "Last Update: ${timeago.format(product.dates[product.dates.length - 1])}"),
                          ),
                        ],
                      )),
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })),
    );
  }
}
