import 'package:http/http.dart';

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
  //Returns price double or -1 if not present
  double getPrice();
}