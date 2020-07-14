import 'package:flutter/material.dart';
import 'package:price_tracker/components/widget_view/widget_view.dart';
import 'package:price_tracker/screens/home/components/product_list_tile.dart';
import 'package:price_tracker/screens/home/home_controller.dart';
import 'package:price_tracker/services/notifications.dart';
import 'package:price_tracker/services/product_utils.dart';
import 'package:toast/toast.dart';
import 'package:workmanager/workmanager.dart';

/// Set this to 'true' if you want to have a red button to create a test-notification:
const NOTIFICATION_TEST_BUTTON = false;
const BACKGROUND_TEST_BUTTON = false;

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
        if (NOTIFICATION_TEST_BUTTON)
          IconButton(
            icon: Icon(Icons.speaker_notes),
            onPressed: () => NotificationService.sendPushNotification(
                0, "test", "test body"),
            color: Colors.redAccent,
          ),
        if (BACKGROUND_TEST_BUTTON)
          IconButton(
            icon: Icon(Icons.cloud_download),
            onPressed: () => Workmanager.registerOneOffTask(
                "manualPriceScraping", "Manual Price Tracker Scraper"),
            color: Colors.redAccent,
          ),
        // Show Reload Button if internet connection avialable or internet error icon if not
        state.iConnectivity
            ? IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () => state.onRefresh(),
              )
            : IconButton(
                icon: Icon(
                  Icons.signal_wifi_off,
                  color: Colors.red,
                ),
                onPressed: () => state.checkInternet(),
              ),
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

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: state.iConnectivity
          ? state.addProductDialogue
          : () {
              Toast.show('Please ensure an internet connection', context,
                  duration: 3, gravity: Toast.BOTTOM);
            },
      tooltip: state.iConnectivity ? 'Add Product' : 'No Internet',
      backgroundColor: state.iConnectivity ? null : Colors.grey,
      child: Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
        child: ScrollConfiguration(
          behavior: EmptyScrollBehavior(),
          child: SingleChildScrollView(
            controller: state.listviewController,
            child: Column(
              children: <Widget>[
                if (state.refreshing)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(state.refreshingText),
                        Container(
                          width: 20,
                        ),
                        CircularProgressIndicator(
                          backgroundColor: Colors.grey[800],
                          value: reloadProgress,
                        ),
                      ],
                    )),
                  ),
                if (state.loading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ListView.separated(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.products.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(height: 1.0),
                  itemBuilder: (BuildContext context, int index) {
                    return ProductListTile(
                      product: state.products[index],
                      onDelete: () =>
                          state.deleteProduct(state.products[index]),
                    );
                  },
                ),
                Container(
                  height: 70,
                  child: Visibility(
                    visible: state.productCount != null,
                    child: Center(
                      child: Text("${state.productCount} tracked products"),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context),
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
