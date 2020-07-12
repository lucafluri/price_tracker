import 'package:flutter_test/flutter_test.dart';
import 'package:price_tracker/models/product.dart';

// Product Class Unit Tests
void main() {
  Product p;

  String productUrl =
      "https://www.digitec.ch/en/product/ducky-one-2-sf-ch-cable-keyboards-12826095";

  Map<String, dynamic> productMap = {
    "_id": 1,
    "name": "Test Product",
    "productUrl": productUrl,
    "prices": "[]",
    "dates": "[]",
    "targetPrice": "-1.0",
    "imageUrl": "",
    "parseSuccess": "true",
  };

  setUpAll(() {
    p = Product.fromMap(productMap);
  });

  group("Product Unit Tests", () {
    test('productUrl Constructor works', () {
      expect(Product(productUrl).productUrl, productUrl);
    });

    group('prices2List', () {
      Product p;

      setUpAll(() {
        p = Product(productUrl);
      });

      test('Non null', () {
        expect(p.prices2List("[]"), []);
      });

      test('int entries', () {
        expect(p.prices2List("[1, 2, 3]"), [1, 2, 3]);
      });

      test('double entries', () {
        expect(p.prices2List("[1.0, 2.0, 3.0]"), [1.0, 2.0, 3.0]);
      });

      test('illegal entries', () {
        expect(p.prices2List("[abc, 2.0, 3.0]"), null);
      });

      test('null', () {
        expect(p.prices2List(null), []);
      });
    });

    group('dates2List', () {
      Product p;
      DateTime date1 = DateTime.parse("1970-01-01");
      DateTime date2 = DateTime.parse("2020-07-04");
      DateTime date3 = DateTime.parse("2019-12-24");

      setUpAll(() {
        p = Product(productUrl);
      });

      test('Non null', () {
        expect(p.dates2List("[]"), []);
      });

      test('valid date entries', () {
        expect(p.dates2List("[1970-01-01, 2020-07-04, 2019-12-24]"),
            [date1, date2, date3]);
      });

      test('illegal entries', () {
        expect(p.dates2List("[2019-12-24, 2.0, abc]"), null);
      });

      test('null', () {
        expect(p.dates2List(null), []);
      });
    });

    test('Map Constructor produces correct Product', () {
      Product p = Product.fromMap(productMap);
      expect(p.id, productMap["_id"]);
      expect(p.name, productMap["name"]);
      expect(p.productUrl, productMap["productUrl"]);
      expect(p.prices, p.prices2List(productMap["prices"]));
      expect(p.dates, p.dates2List(productMap["dates"]));
      expect(p.targetPrice, double.parse(productMap["targetPrice"]));
      expect(p.imageUrl, productMap["imageUrl"]);
    }, skip: false);

    test('toMap works', () {
      expect(p.toMap(), productMap);
    });

    group('equals and hashCode', () {
      Map<String, dynamic> productMap2 = new Map.from(productMap);
      productMap2["name"] = "New Name";

      Product p1 = Product.fromMap(productMap);
      Product p2 = Product.fromMap(productMap);
      Product p3 = Product.fromMap(productMap2);

      test('correct name set', () {
        expect(productMap["name"], "Test Product");
        expect(p1.name, productMap["name"]);
        expect(p3.name, "New Name");
      });

      test('equals', () {
        expect(p1 == p1, true);
        expect(p1 == p2, true);
        expect(p1 == p3, false);
      });

      test('hashCode', () {
        expect(p1.hashCode == p1.hashCode, true);
        expect(p1.hashCode == p2.hashCode, true);
        expect(p1.hashCode == p3.hashCode, false);
      });
    });

    group('getShortName', () {
      test('too long', () {
        p.name =
            "1234567890123456789012345678901234567890123456789012345678901234567890";
        expect(p.getShortName(numChars: 60),
            "123456789012345678901234567890123456789012345678901234567890...");
      });

      test('shorter', () {
        p.name = "12345678901234567890123456789012345678901234567890";
        expect(p.getShortName(numChars: 60),
            "12345678901234567890123456789012345678901234567890");
      });

      test('just right', () {
        p.name = "123456789012345678901234567890123456789012345678901234567890";
        expect(p.getShortName(numChars: 60),
            "123456789012345678901234567890123456789012345678901234567890");
      });
    });

    group('roundToPlace', () {
      test('round int', () {
        expect(p.roundToPlace(1, 2), 1);
      });
      test('round double down', () {
        expect(p.roundToPlace(1.1234, 2), 1.12);
      });
      test('round double ', () {
        expect(p.roundToPlace(1.255, 2), 1.25);
      });
      test('round double up', () {
        expect(p.roundToPlace(1.256, 2), 1.26);
      });
    });

    group('getDomain', () {
      test('getter', () {
        expect(p.getDomain(), "digitec.ch");
      });
    });
  });
}
