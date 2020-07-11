import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:price_tracker/services/scraper.dart';
import 'package:price_tracker/services/parsers/abstract_parser.dart';

class ParserSelector extends Parser {
  String domain;
  Document doc;

  //Map with selector, regex
  Map<String, dynamic> name = Map();
  Map<String, dynamic> price = Map();
  Map<String, dynamic> image = Map();

  ParserSelector(String url, Response response) : super(url, response) {
    domain = ScraperService.getDomain(url);
    doc = ScraperService.getDOM(response);
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

  String getInnerString(Map map) {
    String n;
    for (String selector in map.keys) {
      Map<String, dynamic> regex = map[selector];
      try {
        String tmp = doc.querySelector(selector).innerHtml.trim();
        if (regex["pattern"] != "") {
          RegExp regexp = RegExp(regex["pattern"]);
          RegExpMatch match = regexp.firstMatch(tmp);
          if (regex["remove"] != "") {
            n = match
                .group(regex["group"])
                .replaceAll(new RegExp(RegExp.escape(regex["replace"])), "");
          } else
            n = match.group(regex["group"]);
        } else
          n = tmp;
        break;
      } catch (e) {}
    }
    return n;
  }

  @override
  String getImage() {
    String n;
    for (String selector in image.keys) {
      Map<String, dynamic> regex = image[selector];

      try {
        String tmp = doc
            .querySelector(selector)
            .attributes[regex["attribute"]]
            .toString();
        // debugPrint(tmp);
        if(!ScraperService.validUrl(tmp)) continue;
        n = tmp;
        break;
      } catch (e) {}
    }
    return n;
  }

  @override
  String getName() {
    return getInnerString(name);
  }

  @override
  double getPrice() {
    String inner = getInnerString(price) ?? "-1";
    String s = inner.replaceAll(RegExp(r","), ".");
    return double.parse(s);
  }
}
