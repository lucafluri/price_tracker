import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:xpath_parse/xpath_selector.dart';


class PriceParser{

  static Future<double> parsePrice(String url) async{
    var client = Client();
    Response response = await client.get(url);

    var domain = DomainUtils.getDomainFromUrl(url);
    var d = domain.sld + "." + domain.tld;
    // var beginning = url.substring(0, url.indexOf(d));
    // var rest = url.substring(url.indexOf(d) + d.length);
    // debugPrint(beginning);
    // debugPrint(d);
    // debugPrint(rest);

    switch(d){
      case "digitec.ch":
        String priceString = XPath.source(response.body).query("//*[@id='pageContent']/div/div[2]/div/div[2]/div/div[1]").get().toString();
        final regexp = RegExp(r'\s{1}(\d+)[.]{0,1}(\d*)'); //Find first double
        final match = regexp.firstMatch(priceString);
        return double.parse(match.group(0));
        break;
    }
    


  }

  static Future<String> parseImageUrl(String url) async{
    var client = Client();
    Response response = await client.get(url);

    var domain = DomainUtils.getDomainFromUrl(url);
    var d = domain.sld + "." + domain.tld;

    switch(d){
      case "digitec.ch":
        String image = XPath.source(response.body).query("//*[@id='slide-0']/div/div/picture/img").get();
        final regexp2 = RegExp(r'"(\S*)"'); //Find first double
        final match2 = regexp2.firstMatch(image);
        return match2.group(1);
        break;
    }
    
  }

  static Future<String> test(String url) async{
    return (await parsePrice(url)).toString() + " || " + await parseImageUrl(url);
  }
}