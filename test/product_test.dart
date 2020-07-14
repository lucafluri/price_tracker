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
    "prices": "[-1.0, 269.0, 260.0]",
    "dates":
        "[2020-07-02 00:00:00.000, 2020-07-03 15:43:12.345, 2020-07-04 04:00:45.000]",
    "targetPrice": "261.0",
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

      setUp(() {
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

    group('priceFall', () {
      Map<String, dynamic> productMap2 = new Map.from(productMap);

      test('fall', () {
        expect(p.priceFall(), true);
      });

      test('no price fall, just available again', () {
        productMap2["prices"] = "[-1, 200]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.priceFall(), false);
      });

      test('no price fall, same price', () {
        productMap2["prices"] = "[200, 200]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.priceFall(), false);
      });

      test('no data captured', () {
        productMap2["prices"] = "[]";
        productMap2["dates"] = "[]";
        p = Product.fromMap(productMap2);

        expect(p.priceFall(), false);
      });

      test('just one datapoint', () {
        productMap2["prices"] = "[200]";
        productMap2["dates"] = "[2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.priceFall(), false);
      });
    });

    group('available again', () {
      Map<String, dynamic> productMap2 = new Map.from(productMap);

      test('not available again', () {
        expect(p.availableAgain(), false);
      });

      test('available again', () {
        productMap2["prices"] = "[-1, 200]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.availableAgain(), true);
      });

      test('not available again, same price', () {
        productMap2["prices"] = "[200, 200]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.availableAgain(), false);
      });

      test('no data captured', () {
        productMap2["prices"] = "[]";
        productMap2["dates"] = "[]";
        p = Product.fromMap(productMap2);

        expect(p.availableAgain(), false);
      });

      test('just one datapoint', () {
        productMap2["prices"] = "[200]";
        productMap2["dates"] = "[2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.availableAgain(), false);
      });
    });

    group('under target', () {
      Map<String, dynamic> productMap2 = new Map.from(productMap);

      test('is under target', () {
        expect(p.underTarget(), true);
      });

      test('available again and under target', () {
        productMap2["prices"] = "[-1, 200]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        productMap2["targetPrice"] = "210.0";
        p = Product.fromMap(productMap2);

        expect(p.underTarget(), true);
      });

      test('not under target', () {
        productMap2["prices"] = "[-1, 220]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        productMap2["targetPrice"] = "210.0";
        p = Product.fromMap(productMap2);

        expect(p.underTarget(), false);
      });

      test('same as target', () {
        productMap2["prices"] = "[-1, 210]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        productMap2["targetPrice"] = "210.0";
        p = Product.fromMap(productMap2);

        expect(p.underTarget(), false);
      });

      test('under target, same price', () {
        productMap2["prices"] = "[200, 200]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        productMap2["targetPrice"] = "210.0";
        p = Product.fromMap(productMap2);

        expect(p.underTarget(), true);
      });

      test('no data captured', () {
        productMap2["prices"] = "[]";
        productMap2["dates"] = "[]";
        productMap2["targetPrice"] = "210.0";
        p = Product.fromMap(productMap2);

        expect(p.underTarget(), false);
      });

      test('just one datapoint, under target', () {
        productMap2["prices"] = "[200]";
        productMap2["dates"] = "[2020-07-03]";
        productMap2["targetPrice"] = "210.0";
        p = Product.fromMap(productMap2);

        expect(p.underTarget(), true);
      });
    });

    group('priceDiffToYesterday', () {
      Map<String, dynamic> productMap2 = new Map.from(productMap);

      test('same price', () {
        productMap2["prices"] = "[200, 200]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.priceDifferenceToYesterday(), 0.0);
      });

      test('not enough data', () {
        productMap2["prices"] = "[200]";
        productMap2["dates"] = "[2020-07-02]";
        p = Product.fromMap(productMap2);

        expect(p.priceDifferenceToYesterday(), 0.0);
      });

      test('empty data', () {
        productMap2["prices"] = "[]";
        productMap2["dates"] = "[]";
        p = Product.fromMap(productMap2);

        expect(p.priceDifferenceToYesterday(), 0.0);
      });

      test('200 -> 100', () {
        productMap2["prices"] = "[200, 100]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.priceDifferenceToYesterday(), -100.0);
      });

      test('100 -> 200 -> 100', () {
        productMap2["prices"] = "[100, 200, 100]";
        productMap2["dates"] = "[2020-07-01, 2020-07-02, 2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.priceDifferenceToYesterday(), -100.0);
      });

      test('round 200.34 -> 200.12', () {
        productMap2["prices"] = "[200.34, 200.12]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.priceDifferenceToYesterday(), -0.22);
      });

      test('round 200.344356 -> 200.122345', () {
        productMap2["prices"] = "[200.34, 200.12]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.priceDifferenceToYesterday(), -0.22);
      });
    });

    group('percentageToYesterday', () {
      Map<String, dynamic> productMap2 = new Map.from(productMap);

      test('same price', () {
        productMap2["prices"] = "[200, 200]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.percentageToYesterday(), 0.0);
      });

      test('not enough data', () {
        productMap2["prices"] = "[200]";
        productMap2["dates"] = "[2020-07-02]";
        p = Product.fromMap(productMap2);

        expect(p.percentageToYesterday(), 0.0);
      });

      test('empty data', () {
        productMap2["prices"] = "[]";
        productMap2["dates"] = "[]";
        p = Product.fromMap(productMap2);

        expect(p.percentageToYesterday(), 0.0);
      });

      test('200 -> 100', () {
        productMap2["prices"] = "[200, 100]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.percentageToYesterday(), 50.0);
      });

      test('100 -> 200 -> 100', () {
        productMap2["prices"] = "[100, 200, 100]";
        productMap2["dates"] = "[2020-07-01, 2020-07-02, 2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.percentageToYesterday(), 50.0);
      });

      test('100 -> 200 -> 220', () {
        productMap2["prices"] = "[100, 200, 220]";
        productMap2["dates"] = "[2020-07-01, 2020-07-02, 2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.percentageToYesterday(), 10.0);
      });

      test('round 100 -> 78.548', () {
        productMap2["prices"] = "[100, 78.548]";
        productMap2["dates"] = "[2020-07-02, 2020-07-03]";
        p = Product.fromMap(productMap2);

        expect(p.percentageToYesterday(), 21.45);
      });
    });
  });
}
