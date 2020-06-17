import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ProductTile extends StatelessWidget {
  final String title;
  final String subtitle;
  const ProductTile({Key key, this.title = "Product Tile", this.subtitle = "Subtitle maybe?"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
            color: Theme.of(context).cardColor,
            child: ListTile(
              leading: Container( //Image Placeholder
                color: Colors.indigoAccent,
                width: 50,
                height: 50,
              ),
              trailing: Container( //Change Placeholder?
                color: Colors.redAccent,
                width: 50,
                height: 50,
              ),
              title: Text(title),
              subtitle: Text(subtitle),
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
        Divider()
      ],
    );
  }
}
