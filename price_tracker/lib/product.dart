import 'package:flutter/material.dart';

class Product {
  int _id;
  String name;
  String productUrl;
  List<double> _prices;
  List<DateTime> _dates;
  double targetPrice = 100;
  String imageUrl = "https://static.digitecgalaxus.ch/Files/3/3/4/7/5/8/1/5/gata-1301_gata_1301_02.jpeg?impolicy=PictureComponent&resizeWidth=708&resizeHeight=288&resizeType=downsize";


  Product({this.name = "Ducky One 2 SF", this.productUrl = "https://www.digitec.ch/en/s1/product/ducky-one-2-sf-ch-cable-keyboards-12826095", this.targetPrice});

  Product.map(dynamic obj) {
    this._id = obj['id'];
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

  // String prices2String(List<double> prices){
  //   String listString = prices.toString();
  //   // for(int i = 1; i < prices.length; i++) { 
  //   //   listString += "," + prices[i].toString();
  //   // }
  //   return listString;
  // }

  List<double> prices2List(String prices){
    if(prices == "null") return [];
    return prices.substring(1, prices.length-1).split(",").map(double.parse).toList();
  }

    List<DateTime> dates2List(String dates){
    if(dates == "null") return [];
    return dates.substring(1, dates.length-1).split(",").map(DateTime.parse).toList();
  }


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
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
    this._id = map['id'];
    this.name = map['name'];
    this.productUrl = map['productUrl'];
    this._prices = prices2List(map['prices']);
    this._dates = dates2List(map['dates']);
    this.targetPrice= double.parse(map['targetPrice'] != "null" ? map['targetPrice'] : "0");
    this.imageUrl= map['imageUrl'];
  }
}
