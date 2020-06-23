import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:optimized_cached_image/widgets.dart';
import 'package:price_tracker/utils/database_helper.dart';
import 'package:price_tracker/product_details.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

class ProductTile extends StatefulWidget {
  final int id;
  final Function onDelete;
  final Function fileFromDocsDir;
  const ProductTile({Key key, this.id, this.onDelete, this.fileFromDocsDir})
      : super(key: key);

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
            double priceDifference = (product.prices.length > 1 && product.prices[product.prices.length - 1] >= 0)
                ? product.prices[product.prices.length - 1] -
                    product.prices[product.prices.length - 2]
                : 0.0;

            bool underTarget =
                product.prices[product.prices.length - 1] <= product.targetPrice;

            // Color chosenColor = priceDifference > 0 ? Colors.green[800] : Colors.red[900];
            Color chosenColor = priceDifference == 0
                ? Colors.transparent
                : priceDifference < 0 ? Colors.green[800] : Colors.red[900];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                children: <Widget>[
                  Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    child: Container(
                      color: underTarget
                          ? Colors.green[800]
                          : Colors.transparent,
                          // : Theme.of(context).cardColor,
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(new MaterialPageRoute(
                              builder: (context) => ProductDetails(
                                  product: product,
                                  fileFromDocsDir: widget.fileFromDocsDir)));
                        },
                        // TODO replace with reorder functionality
                        onLongPress: () async {
                          if (await canLaunch(product.productUrl))
                            await launch(product.productUrl);
                          else
                            throw "Could not launch URL";
                        },
                        dense: false,
                        leading: Container(
                          //Image Placeholder
                          // color: Colors.indigoAccent,
                          width: 80,
                          height: 80,
                          // child: Icon(Icons.error),
                          child: product.imageUrl != null
                              ? OptimizedCacheImage(
                                  imageUrl: product.imageUrl,
                                  placeholder: (context, url) =>
                                      Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                )
                              : Container(),
                        ),
                        trailing: Container(
                            //Change Placeholder?
                            color: chosenColor,
                            width: 100,
                            height: 50,
                            child: Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                    product.prices[product.prices.length - 1] >= 0
                                        ? product.prices[product.prices.length - 1]
                                            .toString()
                                        : "--",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Colors.white)),
                                Text(product.targetPrice.toString(),
                                    style:
                                        TextStyle(color: Colors.grey, fontSize: 12))
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
                        onTap: () => Share.share("${product.productUrl}"),
                      ),
                    ],
                    secondaryActions: <Widget>[
                      IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: widget.onDelete),
                    ],
                  ),
                  Divider()
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
