import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:price_tracker/services/scraper.dart';

class IntroScreen extends StatefulWidget {
  IntroScreen({Key key}) : super(key: key);
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "Price Tracker",
        // styleTitle: Theme.of(context).textTheme.headline1,
        description:
            "You can add products by copying the link to the product page." 
            +"\n\n A valid link in the clipboard will be automatically pasted for you.",
            // +"\n\nSupported stores include:"
            // +" \n${ScraperService.parseableDomains}",
        // pathImage: "images/photo_eraser.png",
        backgroundColor: Color(0xff000000),
        
      ),
    );
    slides.add(
      new Slide(
        title: "",
        description:
            "The app will get all relevant data like the current price, name and image for you."
            +"\n\nIt will also run periodically in the background and will update the prices once per day. You could manually update by pulling down."
            +"\n\nYou will be notified if prices dropped or when a product is cheaper than your set target price.",
        // pathImage: "images/photo_pencil.png",
        backgroundColor: Color(0xff000000),
      ),
    );
    // slides.add(
    //   new Slide(
    //     title: "RULER",
    //     description:
    //         "Much evil soon high in hope do view. Out may few northward believing attempted. Yet timed being songs marry one defer men our. Although finished blessing do of",
    //     // pathImage: "images/photo_ruler.png",
    //     backgroundColor: Color(0xff000000),
    //   ),
    // );
  }

  void onDonePress() {
    Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
      colorActiveDot: Theme.of(context).primaryColor,
      colorDot: Colors.grey,
    );
  }
}
