import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:price_tracker/services/parsers/abstract_parser.dart';
import 'package:price_tracker/services/scraper.dart';
import 'package:string_validator/string_validator.dart';

class Product {
  int _id;
  String name;
  String productUrl;
  List<double> _prices = [];
  List<DateTime> _dates = [];
  double targetPrice = -1;
  String imageUrl;
  bool _parseSuccess = true;

  Product(String productUrl) {
    this.productUrl = productUrl;
  }

  int get id => _id;
  set id(int idNew) => {this._id = idNew};
  String get description => productUrl;
  List<double> get prices => _prices;
  List<DateTime> get dates => _dates;
  bool get parseSuccess => _parseSuccess;
  set parseSuccess(bool newVal) => this._parseSuccess = newVal;

  @override
  bool operator ==(o) =>
      o is Product && o.productUrl == productUrl && o.name == name;
  @override
  int get hashCode => name.hashCode ^ productUrl.hashCode;

  // Parses all information from the web
  Future<bool> init() async {
    // final dbHelper = DatabaseHelper.instance;
    Parser parser = await ScraperService.instance.getParser(this.productUrl);
    if (parser == null) return false;

    String parsedName = parser.getName();
    double parsedPrice = parser.getPrice();
    String parsedImageUrl = parser.getImage();

    //Check if parsing successful, else return false
    if (parsedName == null || parsedPrice == null || parsedImageUrl == null) {
      debugPrint("Failed Parsing");

      return false;
    } else {
      this.name = parsedName;
      var formatter = new DateFormat('yyyy-MM-dd');

      // Save only 1 Entry per day
      if (this._dates.length > 0) {
        if (formatter.format(this._dates[this._dates.length - 1]) !=
            formatter.format(DateTime.now())) {
          this._prices.add(parsedPrice);
          this._dates.add(DateTime.now());
        } else {
          this._prices[this._prices.length - 1] = (parsedPrice);
          this._dates[this._dates.length - 1] = (DateTime.now());
        }
      } else {
        this._prices.add(parsedPrice);
        this._dates.add(DateTime.now());
      }

      this.imageUrl = parsedImageUrl;

      // dbHelper.update(this);
      debugPrint(this._id.toString() + " " + this._prices.toString());
      return true;
    }
  }

  // Only Parses the price
  Future<bool> update({bool test = false}) async {
    Parser parser = await ScraperService.instance.getParser(this.productUrl);
    if (parser == null) {
      parseSuccess = false;
      return false;
    }

    double parsedPrice = parser.getPrice();

    //Check if parsing successful, else return false
    if (parsedPrice == null) {
      debugPrint("Failed Parsing");
      parseSuccess = false;
      return false;
    } else {
      var formatter = new DateFormat('yyyy-MM-dd');

      if (!test) {
        // Save only 1 Entry per day
        if (this._dates.length > 0) {
          if (formatter.format(this._dates[this._dates.length - 1]) !=
              formatter.format(DateTime.now())) {
            this._prices.add(parsedPrice);
            this._dates.add(DateTime.now());
          } else {
            this._prices[this._prices.length - 1] = (parsedPrice);
            this._dates[this._dates.length - 1] = (DateTime.now());
          }
        } else {
          this._prices.add(parsedPrice);
          this._dates.add(DateTime.now());
        }
      } else {
        //TEST
        if (this._dates.length > 0) {
          this._prices[this._prices.length - 1] = 1;
          this._dates[this._dates.length - 1] = (DateTime.now());
        }
      }

      debugPrint(this._id.toString() + " " + this._prices.toString());
      parseSuccess = true;
      return true;
    }
  }

  String getDomain() {
    return ScraperService.getDomain(productUrl);
  }

  String getShortName({numChars: 60}) {
    return this.name.length > numChars
        ? this.name.substring(0, numChars) + "..."
        : this.name;
  }

  double roundToPlace(double d, int places) {
    double mod = pow(10.0, places);
    return ((d * mod).round().toDouble() / mod);
  }

  bool priceFall() {
    int length = prices.length;

    if (length <= 1) return false;

    double last = prices[length - 1];
    double secondLast = prices[length - 2];

    if (last < secondLast && last != -1) return true;
    return false;
  }

  bool availableAgain() {
    int length = prices.length;

    if (length <= 1) return false;

    double last = prices[length - 1];
    double secondLast = prices[length - 2];

    if (secondLast == -1 && last != -1) return true;
    return false;
  }

  bool underTarget() {
    int length = prices.length;

    if (length == 0) return false;

    double last = prices[length - 1];

    if (last < targetPrice && last != -1) return true;
    return false;
  }

  double priceDifferenceToYesterday() {
    int length = prices.length;

    if (length <= 1) return 0;

    double last = prices[length - 1];
    double secondLast = prices[length - 2];

    return roundToPlace(last - secondLast, 2);
  }

  double percentageToYesterday() {
    int length = prices.length;

    if (length <= 1) return 0;

    double last = prices[length - 1];
    double secondLast = prices[length - 2];

    return roundToPlace((1 - (last / secondLast)) * -100, 2);
  }

  List<double> prices2List(String prices) {
    if (prices == "null" || prices == "[]" || prices == null) return [];
    try {
      return prices
          .substring(1, prices.length - 1)
          .split(",")
          .map(double.parse)
          .toList();
    } catch (e) {}
    return null;
  }

  List<DateTime> dates2List(String dates) {
    if (dates == "null" || dates == "[]" || dates == null) return [];
    try {
      return dates
          .substring(1, dates.length - 1)
          .split(",")
          .map((date) => DateTime.parse(date.trim()))
          .toList();
    } catch (e) {}
    return null;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['_id'] = _id;
    }
    map['name'] = name;
    map['productUrl'] = productUrl;
    map['prices'] = _prices.toString();
    map['dates'] = _dates.toString();
    map['targetPrice'] = targetPrice.toString();
    map['imageUrl'] = imageUrl;
    map['parseSuccess'] = parseSuccess.toString();

    return map;
  }

  Product.fromMap(Map<String, dynamic> map) {
    this._id = map['_id'];
    this.name = map['name'];
    this.productUrl = map['productUrl'];
    this._prices = prices2List(map['prices']);
    this._dates = dates2List(map['dates']);
    this.targetPrice = double.parse(
        map['targetPrice'] != "null" || map['targetPrice'] != null
            ? map['targetPrice']
            : "-1");
    this.imageUrl = map['imageUrl'];
    this.parseSuccess = toBoolean(map['parseSuccess']);
  }
}
