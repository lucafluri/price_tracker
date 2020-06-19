import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:string_validator/string_validator.dart';
import 'package:xpath_parse/xpath_selector.dart';

class ProductParser {
  static List<String> possibleDomains = ["digitec.ch", "galaxus.ch"];

  static bool validUrl(String url) {
    if (isURL(url, {
      'protocols': ['http', 'https'],
      'require_tld': true,
      'require_protocol': true,
      'allow_underscores': true,
      'host_whitelist': false,
      'host_blacklist': false
    })) {
      var domain = DomainUtils.getDomainFromUrl(url);
      String d = domain.sld + "." + domain.tld;
      if (possibleDomains.contains(d)) {
        return true;
      }
    }
    return false;
  }

  //returns parsed double price or -1 if not present
  static Future<double> parsePrice(String url) async {
    var client = Client();
    Response response = await client.get(url);

    var domain = DomainUtils.getDomainFromUrl(url);
    var d = domain.sld + "." + domain.tld;
    // var beginning = url.substring(0, url.indexOf(d));
    // var rest = url.substring(url.indexOf(d) + d.length);
    // debugPrint(beginning);
    // debugPrint(d);
    // debugPrint(rest);

    try {
      switch (d) {
        case "digitec.ch":
        case "galaxus.ch":
          String priceString = XPath.source(response.body)
              .query("//*[@id='pageContent']/div/div[2]/div/div[2]/div/div[1]")
              .get()
              .toString();
          final regexp = RegExp(r'\s{1}(\d+)[.]{0,1}(\d*)'); //Find first double
          final match = regexp.firstMatch(priceString);
          return match != null ? double.parse(match.group(0)) : -1;
          break;
      }
    } catch (e) {
      return null;
    }
  }

  // returns image url string
  static Future<String> parseImageUrl(String url) async {
    var client = Client();
    Response response = await client.get(url);

    var domain = DomainUtils.getDomainFromUrl(url);
    var d = domain.sld + "." + domain.tld;

    try {
      switch (d) {
        case "digitec.ch":
        case "galaxus.ch":
          String image = XPath.source(response.body)
              .query("//*[@id='slide-0']/div/div/picture/img")
              .get();
          final regexp2 = RegExp(r'"(\S*)"'); //Find first double
          final match2 = regexp2.firstMatch(image);
          return match2.group(1);
          break;
      }
    } catch (e) {
      return null;
    }
  }

  // returns name string
  static Future<String> parseName(String url) async {
    var client = Client();
    Response response = await client.get(url);

    var domain = DomainUtils.getDomainFromUrl(url);
    var d = domain.sld + "." + domain.tld;

    try {
      switch (d) {
        case "digitec.ch":
        case "galaxus.ch":
          String name = XPath.source(response.body)
              .query("//*[@id='pageContent']/div/div[2]/div/div[2]/div/h1")
              .get();
          final regexp = RegExp(
              r'[<]strong[>](.*)[<][\/]strong[>]\s*[<]span[>](.*)[<][\/]span[>]'); //Find first double
          final match = regexp.firstMatch(name);
          return match.group(1).replaceAllMapped(RegExp(r"<!--.*?-->"),
                  (match) {
                return "";
              }).trim() +
              " " +
              match.group(2).trim();
          break;
      }
    } catch (e) {
      return null;
    }
  }

  static void test(String url) async {
    debugPrint((await parseName(url)).toString());
    debugPrint((await parsePrice(url)).toString());
    debugPrint((await parseImageUrl(url)).toString());
  }
}
