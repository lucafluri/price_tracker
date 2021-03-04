import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:settings_ui/settings_ui.dart';

class DevsScreen extends StatelessWidget {
  launchUrl(String url) async {
    if (await canLaunch(url))
      await launch(url);
    else
      throw "Could not launch URL";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          brightness: Brightness.dark,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          title: Text("Developers",
              style: TextStyle(color: Theme.of(context).primaryColor)),
          leading: BackButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("/settings", (route) => false);
            },
          ),
        ),
        body: ScrollConfiguration(
          behavior: EmptyScrollBehavior(),
          child: SettingsList(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            sections: [
              SettingsSection(
                  // title: 'Main Developer',
                  tiles: [
                    SettingsTile(
                      title: 'Luca Fluri',
                      subtitle: '@lucafluri',
                      leading: Icon(Icons.person),
                      onTap: () {
                        launchUrl("https://www.lucafluri.ch");
                      },
                    ),
                  ]),
              SettingsSection(
                title: "Thanks to",
                tiles: [
                  SettingsTile(
                    title: 'Andreas Ambühl',
                    subtitle: '@AndiSwiss',
                    leading: Icon(Icons.person_outline),
                    onTap: () {
                      launchUrl("https://andiswiss.ch/");
                    },
                  ),
                  SettingsTile(
                    title: 'Dario Breitenstein',
                    subtitle: '@chdabre',
                    leading: Icon(Icons.person_outline),
                    onTap: () {
                      launchUrl("https://www.imakethings.ch/");
                    },
                  ),
                  SettingsTile(
                    title: 'Marc Schnydrig',
                    subtitle: '@marcschny',
                    leading: Icon(Icons.person_outline),
                    onTap: () {
                      launchUrl("https://github.com/marcschny");
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

class EmptyScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
