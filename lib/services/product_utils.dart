// Returns number of products that are today cheaper than yesterday or have a price at all compared to yesterday
import 'package:price_tracker/models/product.dart';
import 'package:price_tracker/services/database.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:price_tracker/services/notifications.dart';
import 'package:price_tracker/services/scraper.dart';
import 'package:xpath_parse/xpath_selector.dart';

class ProductParser {
  //returns parsed double price or -1 if not present
  static Future<double> parsePrice(String url) async {
    Response response = await ScraperService.getPage(url);
    String d = ScraperService.getDomain(url);

    

    try {
      switch (d) {
        case "digitec.ch":
        case "galaxus.ch":

          // REGEX TEST CASES
          // <strong class="ZZjx"> 12 900.–</strong>
          // <strong class="ZZjx"> 599.–</strong>
          // <strong class="ZZjx"> 50.10</strong>
          // <strong class="ZZjx"> 12'900.–</strong>
          // <div class="Z1gq"><strong class="ZZjx"> 12 900.–</strong></div>

          String priceString = XPath.source(response.body)
              .query("//*[@id='pageContent']/div/div[2]/div/div[2]/div/div[1]")
              .get()
              .toString();
          // final regexp = RegExp(r'\s{1}(\d+)[.]{0,1}(\d*)'); //Find first double
          final regexp = RegExp(r'>.(\d+.\d*)'); //Find first double
          final match = regexp.firstMatch(priceString);
          // debugPrint(match.group(0).replaceAll(new RegExp(r"\s+\b|\b\s|['>]"), ""));
          return match != null
              ? double.parse(
                  match.group(0).replaceAll(new RegExp(r"\s+\b|\b\s|['>]"), ""))
              : -1;
          break;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // returns image url string or null if missing
  static Future<String> parseImageUrl(String url) async {
    Response response = await ScraperService.getPage(url);
    String d = ScraperService.getDomain(url);

    try {
      switch (d) {
        case "digitec.ch":
        case "galaxus.ch":

          // All known image positions
          String image = XPath.source(response.body)
              .query("//*[@id='slide-0']/div/div/picture/img")
              .get();

          // Other Position
          image = image.isEmpty
              ? XPath.source(response.body)
                  .query("//*[@id='slide-0']/div/picture/img")
                  .get()
              : image;

          final regexp2 = RegExp(r'"(\S*)"'); //Find first double
          final match2 = regexp2.firstMatch(image);
          return match2.group(1);
          break;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // returns name string or null if missing
  static Future<String> parseName(String url) async {
    Response response = await ScraperService.getPage(url);
    String d = ScraperService.getDomain(url);

    try {
      switch (d) {
        case "digitec.ch":
        case "galaxus.ch":
          String name = XPath.source(response.body)
              .query("//*[@id='pageContent']/div/div[2]/div/div[2]/div/h1")
              .get();
          final regexp = RegExp(
              r'([<]strong[>](.*)[<][\/]strong[>])?\s*[<]span[>](.*)[<][\/]span[>]'); //Find first double
          final match = regexp.firstMatch(name);

          return (match.group(2) ?? "").replaceAllMapped(RegExp(r"<!--.*?-->"),
                  (match) {
                return "";
              }).trim() +
              " " +
              match.group(3).trim();
          break;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static void test(String url) async {
    debugPrint((await parseName(url)).toString());
    debugPrint((await parsePrice(url)).toString());
    debugPrint((await parseImageUrl(url)).toString());
  }
}

Future<int> countPriceFall() async {
  final _db = await DatabaseService.getInstance();

  List<Product> products = await _db.getAllProducts();

  int count = 0;

  for (int i = 0; i < products.length; i++) {
    //Check difference to yesterday
    if (products[i].prices.length > 1) {
      if (products[i].prices[products[i].prices.length - 1] <
          products[i].prices[products[i].prices.length - 2]) {
        if (products[i].prices[products[i].prices.length - 1] != -1) count++;
      }
      // Has a price > 0. => count as cheaper since it is has price again
      else if (products[i].prices[products[i].prices.length - 2] == -1 &&
          products[i].prices[products[i].prices.length - 1] > 0) count++;
    }
  }
  return count;
}

//Returns number of products that fell under the set target
Future<int> countPriceUnderTarget() async {
  final _db = await DatabaseService.getInstance();

  List<Product> products = await _db.getAllProducts();

  int count = 0;

  for (int i = 0; i < products.length; i++) {
    //Target Price
    if (products[i].prices[products[i].prices.length - 1] <=
        products[i].targetPrice) {
      // debugPrint(products[i].name.substring(0, 20) + " is under Target of ${products[i].targetPrice}");
      if (products[i].prices[products[i].prices.length - 1] != -1) count++;
    }
  }
  return count;
}

Future<void> updatePrices({test: false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final _db = await DatabaseService.getInstance();

  List<Product> products = await _db.getAllProducts();

  for (int i = 0; i < products.length; i++) {
    await products[i].update(test: test);
    await _db.update(products[i]);
  }

  products = await _db.getAllProducts();
  int countFall = await countPriceFall();
  int countTarget = await countPriceUnderTarget();

  if (countFall > 0) {
    if (countFall == 1) {
      NotificationService.sendPushNotification(
          0,
          '$countFall Product is cheaper',
          'We detected that $countFall is cheaper today!'); //Display Notification
    } else {
      NotificationService.sendPushNotification(
          0,
          '$countFall Products are cheaper',
          'We detected that $countFall are cheaper today!'); //Display Notification
    }
  }
  if (countTarget > 0) {
    if (countTarget == 1) {
      NotificationService.sendPushNotification(
          1,
          '$countTarget Product is under their target!',
          'We detected that $countTarget Product is under the set target today!'); //Display Notification
    } else {
      NotificationService.sendPushNotification(
          1,
          '$countTarget Products are under their target!',
          'We detected that $countTarget Products are under the set targets today!'); //Display Notification
    }
  }
}
