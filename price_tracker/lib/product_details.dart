import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:price_tracker/product.dart';
import 'package:url_launcher/url_launcher.dart';

import 'database_helper.dart';

class ProductDetails extends StatefulWidget {
  final Product product;

  const ProductDetails({Key key, this.product}) : super(key: key);
  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.product.name),
        ),
        body: FutureBuilder(
            future: dbHelper.getProduct(widget.product.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Product product = snapshot.data;

                List<DataPoint<DateTime>> chartData = [];
                for (int i = 0; i < product.prices.length; i++) {
                  chartData.add(DataPoint(
                      value: product.prices[i], xAxis: product.dates[i]));
                }

                return Center(
                    child: Column(
                  children: <Widget>[
                    RaisedButton(
                      //Launch URL Button
                      onPressed: () async {
                        if (await canLaunch(product.productUrl))
                          await launch(product.productUrl);
                        else
                          throw "Could not launch URL";
                      },
                      child: Text("Open Product Site"),
                    ),
                    Container(
                        //Bezier Chart Container
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        child: BezierChart(
                          fromDate: product.dates[0],
                          toDate: DateTime.now(),
                          selectedDate: product.dates[product.dates.length - 1],
                          bezierChartScale: BezierChartScale.WEEKLY,
                          series: [
                            BezierLine(
                              label: "Price",
                              data: chartData,
                            ),
                          ],
                          config: BezierChartConfig(
                            verticalIndicatorStrokeWidth: 3.0,
                            verticalIndicatorColor: Theme.of(context).primaryColor,
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

                    // Text(product.imageUrl.toString()),
                    // Text(product.prices.toString()),
                    // Text(product.dates.toString()),
                  ],
                ));
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }
}
