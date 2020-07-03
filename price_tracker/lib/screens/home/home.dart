import 'package:flutter/material.dart';
import 'package:frefresh/frefresh.dart';
import 'package:price_tracker/components/widget_view/widget_view.dart';
import 'package:price_tracker/screens/home/components/product_list_tile.dart';
import 'package:price_tracker/screens/home/home_controller.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  HomeScreenController createState() => HomeScreenController();
}

class HomeScreenView extends WidgetView<HomeScreen, HomeScreenController> {
  HomeScreenView(HomeScreenController state) : super(state);

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      brightness: Brightness.dark,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      title: Text('Price Tracker BETA',
          style: TextStyle(color: Theme.of(context).primaryColor)),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.help_outline),
          onPressed: () => Navigator.of(context).pushNamed("/intro"),
        ),
        IconButton(
          icon: Icon(Icons.description),
          onPressed: () => Navigator.of(context).pushNamed("/credits"),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: state.addProduct,
      tooltip: 'Add Product',
      child: Icon(Icons.add),
    );
  }

  Function _buildPullRefreshHeader(BuildContext context) {
    return (setter,constraints) => Container(
        height: 50,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryTextTheme.caption.color),
                strokeWidth: 2.0,
              ),
            ),
            const SizedBox(width: 9.0),
            Text(
              state.pullToRefreshText,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
        child: ScrollConfiguration(
          behavior: EmptyScrollBehavior(),
          child: FRefresh(
              controller: state.refreshController,
              headerTrigger: 100,
              headerHeight: 50,
              headerBuilder: _buildPullRefreshHeader(context),
              onRefresh: state.onRefresh,
              child: Column(
                children: <Widget>[
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.products.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ProductListTile(
                        id: state.products[index].id,
                        onDelete: () => state.deleteProduct(state.products[index]),
                      );
                    },
                  ),
                  if (state.loading) Center(child: CircularProgressIndicator()),
                  if (!state.loading && state.products.length == 0) Center(
                      child: Text("You don't have any tracked products yet.")
                  ),
                  Container(height: 70)
                ],
              )),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }
}

class EmptyScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}