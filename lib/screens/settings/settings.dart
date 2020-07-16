import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:price_tracker/components/widget_view/widget_view.dart';
import 'package:price_tracker/screens/settings/settings_controller.dart';
import 'package:price_tracker/services/backup.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  Settings createState() => Settings();
}

class SettingsScreenView extends WidgetView<SettingsScreen, Settings> {
  SettingsScreenView(Settings state) : super(state);

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
          title: Text("Settings",
              style: TextStyle(color: Theme.of(context).primaryColor)),
          leading: BackButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("/", (route) => false);
            },
          ),
        ),
        body: ScrollConfiguration(
          behavior: EmptyScrollBehavior(),
          child: SettingsList(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            sections: [
              SettingsSection(
                title: 'Backup / Restore',
                tiles: [
                  SettingsTile(
                    title: 'Backup',
                    subtitle: 'Save Backup File',
                    leading: Icon(Icons.backup),
                    onTap: () {
                      state.backup();
                    },
                  ),
                  SettingsTile(
                    title: 'Restore',
                    subtitle: 'Restore from Backup File',
                    leading: Icon(Icons.cloud_download),
                    onTap: () {
                      state.restore();
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: 'Help',
                tiles: [
                  SettingsTile(
                    title: 'Tutorial',
                    subtitle: 'Open Tutorial',
                    leading: Icon(Icons.live_help),
                    onTap: () {
                      Navigator.of(context).pushNamed("/intro");
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: 'DEVELOPER DANGER ZONE',
                tiles: [
                  SettingsTile(
                    title: 'Clear DB',
                    leading: Icon(Icons.warning),
                    onTap: () {
                      state.clearDB();
                    },
                  ),
                  SettingsTile(
                    title: 'Test Notification (Price Fall)',
                    leading: Icon(Icons.warning),
                    onTap: () {
                      state.testPriceFallNotification();
                    },
                  ),
                  SettingsTile(
                    title: 'Test Notification (Under Target)',
                    leading: Icon(Icons.warning),
                    onTap: () {
                      state.testUnderTargetNotification();
                    },
                  ),
                  SettingsTile(
                    title: 'Test Notification (Available Again)',
                    leading: Icon(Icons.warning),
                    onTap: () {
                      state.testAvailableAgainNotification();
                    },
                  ),
                  SettingsTile(
                    title: 'Test Background Service (Android Only)',
                    leading: Icon(Icons.warning),
                    onTap: () {
                      state.testBackgroundService();
                    },
                    enabled: Platform.isAndroid,
                  ),
                ],
              ),
              SettingsSection(
                title: 'Credits',
                tiles: [
                  SettingsTile(
                    title: 'Luca Fluri',
                    subtitle: '@lucafluri',
                    leading: Icon(Icons.person),
                    onTap: () {
                      launchUrl("https://www.lucafluri.ch");
                    },
                  ),
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
              SettingsSection(
                title: 'Version',
                tiles: [
                  SettingsTile(
                    title: Settings.VERSION,
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
