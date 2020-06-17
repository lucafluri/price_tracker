class Product {
  int _id;
  String name;
  String productUrl;
  List<double> _prices;
  List<DateTime> _dates;
  double targetPrice;
  String imageUrl;


  Product({this.name = "Product Name", this.productUrl = "http://www.google.com", this.targetPrice});

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
  String get title => name;
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
    return prices.substring(1, prices.length-1).split(",").map(double.parse).toList();
  }

    List<DateTime> dates2List(String dates){
    return dates.substring(1, dates.length-1).split(",").map(DateTime.parse).toList();
  }


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['title'] = name;
    map['productUrl'] = productUrl;
    map['prices'] = _prices.toString();
    map['dates'] = _dates.toString();
    map['targetPrice'] = targetPrice.toString();
    map['imageUrl'] = imageUrl;

    return map;
  }

  Product.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this.name = map['title'];
    this.productUrl = map['productUrl'];
    this._prices = prices2List(map['prices']);
    this._dates = dates2List(map['dates']);
    this.targetPrice= double.parse(map['targetPrice']);
    this.imageUrl= map['imageUrl'];
  }
}
