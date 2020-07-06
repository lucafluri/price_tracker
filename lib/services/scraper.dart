import 'package:basic_utils/basic_utils.dart';
import 'package:http/http.dart';
import 'package:string_validator/string_validator.dart';

class ScraperService {
  static List<String> possibleDomains = ["digitec.ch", "galaxus.ch"];

  static Client _client;

  ScraperService._privateConstructor();
  static final ScraperService _instance = ScraperService._privateConstructor();
  static ScraperService get instance {
    if(_client == null) _client = Client();
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
      var domain = DomainUtils.getDomainFromUrl(url);
      String d = domain.sld + "." + domain.tld;
      if (possibleDomains.contains(d)) {
        return true;
      }
    }
    return false;
  }

  // Returns Response if valid URL
  // or null if invalid url
  Future<Response> getPage(String url) async {
    if (validUrl(url)) {
      Response r = await _client.get(url);
      return r;
    } else
      return Future.value(null);
  }


  // Takes a valid url and returns sld + tld
  static String getDomain(String url) {
    var domain = DomainUtils.getDomainFromUrl(url);
    return domain.sld + "." + domain.tld;
  }
}
