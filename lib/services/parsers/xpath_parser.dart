
import 'package:http/http.dart';
import 'package:price_tracker/services/scraper.dart';
import 'package:xpath_parse/xpath_selector.dart';
import 'package:price_tracker/services/parsers/abstract_parser.dart';


class ParserXPath extends Parser {
  ParserXPath(String url, Response response) : super(url, response);

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