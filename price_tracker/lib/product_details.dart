import 'package:flutter/material.dart';
import 'package:price_tracker/product.dart';

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
              if(snapshot.hasData){
                Product product = snapshot.data;

                return Center(
                  child: Column(
                children: <Widget>[
                  Text(product.name.toString()),
                  Text(product.id.toString()),
                  // Text(product.productUrl.toString()),
                  // Text(product.imageUrl.toString()),
                  Text(product.prices.toString()),
                  Text(product.dates.toString()),
                ],
              ));
              }else{
                return Center(child: CircularProgressIndicator(),);
              }
              
            }));
  }
}
