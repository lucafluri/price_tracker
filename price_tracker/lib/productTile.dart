import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:price_tracker/product.dart';
import 'package:price_tracker/product_details.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  const ProductTile({Key key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
          color: Theme.of(context).cardColor,
          child: ListTile(
            onTap: () {Navigator.of(context).push(new MaterialPageRoute(builder: (context) => ProductDetails(product: product)));}, // TODO Open Detail View
            onLongPress: () {}, // TODO Open Link
            dense: false,
            leading: Container(
              //Image Placeholder
              // color: Colors.indigoAccent,
              width: 80,
              child: product.imageUrl != null
                  ? CachedNetworkImage(
                      placeholder: (context, url) => CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.black54),
                        strokeWidth: 4,
                      ),
                      imageUrl: product.imageUrl,
                    )
                  : Container(),
            ),
            trailing: Container(
              //Change Placeholder?
              color: Colors.redAccent,
              width: 50,
              height: 50,
            ),
            title: Text(product.name),
            subtitle: Text(product.productUrl, overflow: TextOverflow.ellipsis),
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
            onTap: () => debugPrint('Delete'),
          ),
        ],
      ),
    );
  }
}
