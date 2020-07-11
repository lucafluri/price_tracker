import 'package:http/http.dart';
import 'package:price_tracker/services/parsers/abstract_parser.dart';

class ParserSD extends Parser {
  // https://schema.org/Product

  // {
  //   "@context": "https://schema.org/",
  //   "@type": "Product",
  //   "image": [
  //     "https://static.digitecgalaxus.ch/Files/7/7/1/7/6/0/7/71GdNUGDzqL._SL1500_.jpg",
  //     "https://static.digitecgalaxus.ch/Files/7/7/1/7/6/0/9/61ggGeAoI4L._SL1500_.jpg",
  //     "https://static.digitecgalaxus.ch/Files/7/7/1/7/6/1/0/71kWo2BkYACL._SL1500_.jpg"
  //   ],
  //   "name": "USB type C nylon – pack of 5",
  //   "description": "Compatible with USB-C smartphones, tablets and laptops.",
  //   "url": "https://www.digitec.ch/en/s1/product/aukey-usb-type-c-nylon-pack-of-5-usb-cables-6213310",
  //   "brand": {
  //     "@type": "Thing",
  //     "name": "Aukey"
  //   },
  //   "sku": 6213310,
  //   "aggregateRating": {
  //     "@type": "AggregateRating",
  //     "ratingValue": 4.5,
  //     "ratingCount": 269
  //   },
  //   "offers": {
  //     "@type": "Offer",
  //     "availability": "http://schema.org/InStock",
  //     "price": 45,
  //     "priceCurrency": "CHF"
  //   }
  // }

  dynamic structData;
  @override
  ParserSD(String url, Response response, dynamic structData)
      : super(url, response) {
    this.structData = structData;
  }

  @override
  String getImage() {
    try {
      var images = structData["image"];
      String image = images is List ? images[0] : images;
      //Fix missing protocol (brack.ch for instance...)
      if (image.substring(0, 2) == "//") image = "https:" + image;
      return image;
    } catch (e) {
      return null;
    }
  }

  @override
  String getName() {
    try {
      String name = structData["name"] ?? "";
      String brand = "";

      if (structData["brand"] != null) {
        if (structData["brand"] is String)
          brand = structData["brand"];
        else
          brand = structData["brand"]["name"] ?? "";
        return '$brand $name';
      } else if (name != "" && brand == "")
        return name;
      else
        return null;
    } catch (e) {
      return null;
    }
  }

  @override
  double getPrice() {
    try {
      if (structData["offers"] != null) {
        var offers = structData["offers"];
        var offer = offers;

        if (offers is! List && offers["@type"] == "AggregateOffer") {
          offers = offers["offers"];
        }
        //Find first non empty entry in list (Playzone.ch...)
        if (offers is List) {
          for (var o in offers) {
            if (o.isNotEmpty) {
              offer = o;
              break;
            }
          }
        }

        return double.parse(offer["price"].toString());
      } else
        return -1;
    } catch (e) {
      return -1;
    }
  }
}
