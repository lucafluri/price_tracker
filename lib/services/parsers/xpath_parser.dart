
import 'package:http/http.dart';
import 'package:price_tracker/services/scraper.dart';
import 'package:xpath_parse/xpath_selector.dart';
import 'package:price_tracker/services/parsers/abstract_parser.dart';


class ParserXPath extends Parser {
  String domain;

  //Map with selector, regex
  Map<String, dynamic> name = Map();
  Map<String, dynamic> price = Map();
  Map<String, dynamic> image = Map();
  ParserXPath(String url, Response response) : super(url, response){
    domain = ScraperService.getDomain(url);
    dynamic domainConf = ScraperService.parserConf["domains"][domain];

    //Set paths and regexp
    for (dynamic obj in domainConf["name"]) {
      name.putIfAbsent(obj["path"], () => obj["regex"]);
    }
    for (dynamic obj in domainConf["price"]) {
      price.putIfAbsent(obj["path"], () => obj["regex"]);
    }
    for (dynamic obj in domainConf["image"]) {
      image.putIfAbsent(obj["path"], () => obj["regex"]);
    }
  }

  String getString(Map map, {bool imageMap = false}) {
    String n;
    for (String selector in map.keys) {
      Map<String, dynamic> regex = map[selector];
      try {
        String tmp = XPath.source(response.body).query(selector).get();
        if (regex["pattern"] != "") {
          RegExp regexp = RegExp(regex["pattern"]);
          RegExpMatch match = regexp.firstMatch(tmp);
          if (regex["remove"] != "") {
            tmp = match
                .group(regex["group"])
                .replaceAll(new RegExp(RegExp.escape(regex["replace"])), "");
          } else
            tmp = match.group(regex["group"]);
        } else
          
        if(imageMap && !ScraperService.validUrl(tmp)) continue;
        n = tmp;
        break;

      } catch (e) {}

      
    }
  
    return n;
  }

  @override
  String getImage() {
    return getString(image, imageMap: true);
  }

  @override
  String getName() {
    return getString(name);
  }

  @override
  double getPrice() {
    String inner = getString(price) ?? "-1";
    String s = inner.replaceAll(RegExp(r","), ".");
    return double.parse(s);
  }
}