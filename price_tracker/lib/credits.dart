import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Credits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        title: Text("Credits",
            style: TextStyle(color: Theme.of(context).primaryColor)),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil("/", (route) => false);
          },
        ),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  if (await canLaunch("https://www.lucafluri.ch"))
                    await launch("https://www.lucafluri.ch");
                  else
                    throw "Could not launch URL";
                },
                child: Column(
                  children: <Widget>[
                    Text(
                      "Made by Luca Fluri",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      "lucafluri.ch",
                      style: Theme.of(context).textTheme.headline5,
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 36.0),
                child: Text("June 2020"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
