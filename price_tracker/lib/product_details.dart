import 'package:flutter/material.dart';
import 'package:price_tracker/product.dart';

class ProductDetails extends StatefulWidget {
  final Product product;

  const ProductDetails({Key key, this.product}) : super(key: key);
  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: Center(child: Text("Details"))
    );
  }
}