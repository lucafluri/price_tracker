import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:price_tracker/services/parsers.dart';
import 'package:string_validator/string_validator.dart';

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

class ScraperService {
  static List<String> parseableDomains = ["digitec.ch", "galaxus.ch"];

  static Client _client;

  ScraperService._privateConstructor();
  static final ScraperService _instance = ScraperService._privateConstructor();
  static ScraperService get instance {
    if (_client == null) _client = Client();
    return _instance;
  }

  static bool validUrl(String url) {
    if (isURL(url, {
      'protocols': ['http', 'https'],
      'require_tld': true,
      'require_protocol': true,
      'allow_underscores': true,
      'host_whitelist': false,
      'host_blacklist': false
    })) {
      // String d = getDomain(url);
      // if (possibleDomains.contains(d)) {
      //   return true;
      // }
      return true;
    }
    return false;
  }

  static bool hasStructuredDataJSON(Response r) {
    Document doc = ScraperService.getDOM(r);
    // Find Product JSON-LD
    var jsonElements =
        doc.querySelectorAll('script[type="application/ld+json"]');
    if (jsonElements.isNotEmpty) {
      for (var el in jsonElements) {
        dynamic json = jsonDecode(el.innerHtml);
        if (json["@type"] != null && json["@type"] == "Product") {
          return true;
        }
      }
    }
    return false;
  }

  // Returns JSON-LD Object of the Product or
  // Null if no JSON-LD Structured Data is available
  static dynamic getStructuredDataJSON(Response r) {
    Document doc = ScraperService.getDOM(r);

    // Find Product JSON-LD
    var jsonElements =
        doc.querySelectorAll('script[type="application/ld+json"]');
    if (jsonElements.isNotEmpty) {
      for (var el in jsonElements) {
        dynamic json = jsonDecode(el.innerHtml);
        if (json["@type"] != null && json["@type"] == "Product") {
          return json;
        }
      }
    }
    return null;
  }

  // Takes a valid URL!
  // Returns Response
  // !! Has to be called via instance so that _client initialization is ensured
  Future<Response> getResponse(String url) async {
    Response r = await _client.get(url);
    return r;
  }

  static Document getDOM(Response r) {
    return r != null ? parse(r.body) : null;
  }

  // Takes a valid url and returns sld + tld
  static String getDomain(String url) {
    var domain = DomainUtils.getDomainFromUrl(url);
    return domain.sld + "." + domain.tld;
  }

  // Returns a Parser Instance
  Future<Parser> getParser(String url) async {
    Response r = await getResponse(url);
    if (hasStructuredDataJSON(r))
      return ParserSD(url, r);
    else
      return ParserXPath(url, r);
  }

  static void test(String url) async {
    Parser parser = await ScraperService.instance.getParser(url);
    debugPrint(parser.getName().toString());
    debugPrint(parser.getPrice().toString());
    debugPrint(parser.getImage().toString());
  }
}
