import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:string_validator/string_validator.dart';
import 'package:price_tracker/services/parsers/selector_parser.dart';
import 'package:price_tracker/services/parsers/xpath_parser.dart';
import 'package:price_tracker/services/parsers/struct_data_parser.dart';
import 'package:price_tracker/services/parsers/abstract_parser.dart';

class ScraperService {
  // HTTP GET Response Timout in seconds
  static const RESPONSE_TIMOUT = 15;
  static const USE_LOCAL_CONF_FILE = false;

  static final parseInfoURL =
      "https://raw.githubusercontent.com/lucafluri/price_tracker/dev/lib/configuration/parser_configuration.json";

  // static List<String> parseableDomains = ["digitec.ch", "galaxus.ch"];
  static Map<dynamic, dynamic> parserConf;
  static List<String> parseableDomains;
  static bool _initDone = false;

  static Client _client;

  ScraperService._privateConstructor();
  static final ScraperService _instance = ScraperService._privateConstructor();
  static ScraperService get instance {
    if (_client == null) _client = Client();
    return _instance;
  }

  static Future<void> init() async {
    await getParserInfo();
    _initDone = true;
  }

  static Future<String> loadFallbackParseInfo() async {
    return await rootBundle
        .loadString('lib/configuration/parser_configuration.json');
  }

  static Future<void> getParserInfo() async {
    // Load PARSE_INFO from Github or local fallback copy if something fails
    if (!USE_LOCAL_CONF_FILE) {
      try {
        Response response =
            await ScraperService.instance.getResponse(parseInfoURL);
        if (response == null) throw Exception();
        parserConf = jsonDecode(response.body);
        print("Loaded newest parser_configuration from Github");
      } catch (e) {
        print("PARSER_CONFIGURATION GET ERROR --- LOADING LOCAL FILE");
        parserConf = jsonDecode(await loadFallbackParseInfo());
      }
    } else
      print("Loaded local parser_configuration");
    parserConf = jsonDecode(await loadFallbackParseInfo());

    //Set possible domains var
    parseableDomains = parserConf["domains"].keys.toList();

    // Map<dynamic, dynamic> domains = parseInfo["domains"];
    // debugPrint(possibleDomains.toString());
    // debugPrint(domains[supportedDomains[0]]["name"][0].toString());
  }

  static bool validUrl(String url) {
    if (url != null &&
        isURL(url, {
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
    try {
      // Find Product JSON-LD
      var jsonElements =
          doc.querySelectorAll('script[type="application/ld+json"]');
      if (jsonElements.isNotEmpty) {
        for (var el in jsonElements) {
          if (el.innerHtml.isEmpty) continue;

          dynamic json = jsonDecode(el.innerHtml);
          if (json["@type"] != null && json["@type"] == "Product") {
            return json;
          }
        }
      }
    } catch (e) {
      print(e.toString());
      return null;
    }

    return null;
  }

  // Takes a valid URL!
  // Returns Response
  // !! Has to be called via instance so that _client initialization is ensured
  Future<Response> getResponse(String url) async {
    try {
      Response r = await _client
          .get(url)
          .timeout(Duration(seconds: RESPONSE_TIMOUT), onTimeout: () {
        debugPrint("HTTP GET Timout!");
        return null;
      });
      return r;
    } catch (e) {
      return null;
    }
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
    if (!_initDone) await init();
    Response r = await getResponse(url);
    if (r == null) return null;

    String d = ScraperService.getDomain(url);
    dynamic sdJSON = getStructuredDataJSON(r);
    if (sdJSON != null)
      return ParserSD(url, r, sdJSON);
    else if (parseableDomains.contains(d)) {
      if (toBoolean(parserConf["domains"][d]["xpath"]))
        return ParserXPath(url, r);
      else
        return ParserSelector(url, r);
    } else
      return null;
  }

  static void test(String url) async {
    Parser parser = await ScraperService.instance.getParser(url);
    if (parser == null) {
      debugPrint("Parser get Failed!");
      return;
    }

    debugPrint(parser.getName().toString());
    debugPrint(parser.getPrice().toString());
    debugPrint(parser.getImage().toString());
  }
}
