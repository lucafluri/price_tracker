import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/widgets.dart';
import 'package:price_tracker/classes/product.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:price_tracker/utils/database_helper.dart';

double roundDouble(double value, int places) {
  double mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

class ProductDetails extends StatefulWidget {
  final Product product;
  final Function fileFromDocsDir;

  const ProductDetails({Key key, this.product, this.fileFromDocsDir})
      : super(key: key);
  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final dbHelper = DatabaseHelper.instance;
  var formatter = new DateFormat('yyyy-MM-dd--HH:mm:ss');
  double sliderValue;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
        return Future.value(true);
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.product.name),
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

                  return SingleChildScrollView(
                    child: Center(
                        child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "Last Update: ${formatter.format(product.dates[product.dates.length - 1].toLocal())}"),
                        ),
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
                            //Launch URL Button
                            onPressed: () async {
                              if (await canLaunch(product.productUrl))
                                await launch(product.productUrl);
                              else
                                throw "Could not launch URL";
                            },
                            child: Text("Open Product Site"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "Current Price: ${product.prices[product.prices.length - 1]}.-",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              child: product.prices[product.prices.length-1] >= 0 ? Column(
                            children: <Widget>[
                              Text(
                                  "Target Price: " +
                                      (sliderValue).toString() +
                                      ".-",
                                  style: TextStyle(fontSize: 17)),
                              Slider(
                                value: sliderValue ??
                                    product.prices[product.prices.length - 1] -
                                        1,
                                
                                onChanged: (e) {
                                  setState(() {
                                    e = roundDouble(e, 0);
                                    sliderValue = e;
                                    product.targetPrice = e;
                                    dbHelper.update(product);
                                  });
                                },
                                max: max(
                                    product.prices[product.prices.length - 1],
                                    product.prices.length > 1
                                        ? product
                                            .prices[product.prices.length - 2]
                                        : product
                                            .prices[product.prices.length - 1]),
                                min: 0,
                                // label: "Target Price",
                                activeColor: Theme.of(context).primaryColor,
                                // divisions: 10,
                              ),
                            ],
                          ) : Container()),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, bottom: 30, left: 20, right: 20),
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

                        // Text(product.imageUrl.toString()),
                        // Text(product.prices.toString()),
                        // Text(product.dates.toString()),
                      ],
                    )),
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
