import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:price_tracker/services/parsers/abstract_parser.dart';
import 'package:price_tracker/services/scraper.dart';

class Product {
  int _id;
  String name;
  String productUrl;
  List<double> _prices = [];
  List<DateTime> _dates = [];
  double targetPrice = -1;
  String imageUrl =
      "https://static.digitecgalaxus.ch/Files/3/3/4/7/5/8/1/5/gata-1301_gata_1301_02.jpeg?impolicy=PictureComponent&resizeWidth=708&resizeHeight=288&resizeType=downsize";

  Product(
      {this.name = "Ducky One 2 SF",
      this.productUrl =
          "https://www.digitec.ch/en/s1/product/ducky-one-2-sf-ch-cable-keyboards-12826095",
      this.targetPrice = -1});

  Product.map(dynamic obj) {
    this._id = obj['_id'];
    this.name = obj['name'];
    this.productUrl = obj['productUrl'];
    this._prices = prices2List(obj['prices']);
    this._dates = dates2List(obj['dates']);
    this.targetPrice = double.parse(obj['targetPrice']);
    this.imageUrl = obj['imageUrl'];
  }

  int get id => _id;
  set id(int idNew) => {this._id = idNew};
  String get description => productUrl;
  List<double> get prices => _prices;
  List<DateTime> get dates => _dates;

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
    if (parser == null) return false;

    double parsedPrice = parser.getPrice();

    //Check if parsing successful, else return false
    if (parsedPrice == null) {
      debugPrint("Failed Parsing");
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
      return true;
    }
  }

  String getDomain() {
    return ScraperService.getDomain(productUrl);
  }

  double roundToPlace(double d, int places) {
    double mod = pow(10.0, places);
    return ((d * mod).round().toDouble() / mod);
  }

  List<double> prices2List(String prices) {
    if (prices == "null") return [];
    return prices
        .substring(1, prices.length - 1)
        .split(",")
        .map(double.parse)
        .toList();
  }

  List<DateTime> dates2List(String dates) {
    if (dates == "null") return [];
    // debugPrint(dates);
    return dates
        .substring(1, dates.length - 1)
        .split(",")
        .map((date) => DateTime.parse(date.trim()))
        .toList();
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

    return map;
  }

  Product.fromMap(Map<String, dynamic> map) {
    this._id = map['_id'];
    this.name = map['name'];
    this.productUrl = map['productUrl'];
    this._prices = prices2List(map['prices']);
    this._dates = dates2List(map['dates']);
    this.targetPrice =
        double.parse(map['targetPrice'] != "null" ? map['targetPrice'] : "0");
    this.imageUrl = map['imageUrl'];
  }
}
