import 'package:http/http.dart';
import 'package:price_tracker/services/scraper.dart';
import 'package:xpath_parse/xpath_selector.dart';

abstract class Parser {
  String url;
  Response response;

  Parser(String url, Response response) {
    this.url = url;
    this.response = response;
  }
  //Returns name (brand + name) or null if no product name present
  String getName();
  //Returns String of first image or null if not present
  String getImage();
  //Returns price double or null if not present
  double getPrice();
}

class ParserSD extends Parser {
  dynamic structData;
  @override
  ParserSD(String url, Response r) : super(url, r) {
    this.structData = ScraperService.getStructuredDataJSON(this.response);
  }

  @override
  String getImage() {
    var images = structData["image"];
    return images is List ? images[0] : images;
  }

  @override
  String getName() {
    String name = structData["name"] ?? "";
    String brand = "";

    if (structData["brand"] != null) {
      brand = structData["brand"]["name"] ?? "";
      return '$brand $name';
    } else if (name != "" && brand == "")
      return name;
    else
      return null;
  }

  @override
  double getPrice() {
    if (structData["offers"] != null) {
      return double.parse(structData["offers"]["price"].toString());
    } else
      return null;
  }
}

class ParserXPath extends Parser {
  ParserXPath(String url, Response r) : super(url, r);


  @override
  String getImage() {
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

  @override
  String getName() {
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

  @override
  double getPrice() {
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
}
