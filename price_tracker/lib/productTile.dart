import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:price_tracker/database_helper.dart';
import 'package:price_tracker/product_details.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductTile extends StatefulWidget {
  final int id;
  final Function onDelete;
  const ProductTile({Key key, this.id, this.onDelete}) : super(key: key);

  @override
  _ProductTileState createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  final dbHelper = DatabaseHelper.instance;
  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: dbHelper.getProduct(widget.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var product = snapshot.data;

            //Price Difference since last day => used for coloring
            int priceDifference = product.prices.length > 1 ? product.prices[product.prices.length - 1] - product.prices[product.prices.length - 1] : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: Container(
                  color: Theme.of(context).cardColor,
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (context) =>
                              ProductDetails(product: product)));
                    }, 
                    onLongPress: () async{if (await canLaunch(product.productUrl))
                            await launch(product.productUrl);
                          else
                            throw "Could not launch URL";}, // TODO Open Link
                    dense: false,
                    leading: Container(
                      //Image Placeholder
                      // color: Colors.indigoAccent,
                      width: 80,
                      height: 80,
                      child: product.imageUrl != null
                          ? CachedNetworkImage(
                              placeholder: (context, url) =>
                                  Center(child: Text("..."),),
                              imageUrl: product.imageUrl,
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            )
                          : Container(),
                    ),
                    trailing: Container(
                        //Change Placeholder?
                        // color: Colors.redAccent,
                        width: 50,
                        height: 50,
                        child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(product.prices.length > 0
                                    ? product.prices[product.prices.length - 1]
                                        .toString()
                                    : "--", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: priceDifference == 0 ? Colors.white : priceDifference > 0 ? Colors.green : Colors.red)),
                                Text(product.targetPrice.toString(), style: TextStyle(color: Colors.grey, fontSize: 12 ))
                              ],
                            ))),
                    title: Text(product.name),
                    subtitle: Text(product.getDomain(),
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
                actions: <Widget>[
                  IconSlideAction(
                    caption: 'Share',
                    color: Colors.blue,
                    icon: Icons.share,
                    onTap: () => debugPrint('Share'),
                  ),
                ],
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: 'Delete',
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: widget.onDelete
                  ),
                ],
              ),
            );
          } else
            return Center(
              child: CircularProgressIndicator(),
            );
        });
  }
}
