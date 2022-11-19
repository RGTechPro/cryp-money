import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  bool a = true;
  bool b = true;
  bool c = true;
  bool d = true;
  final _url = 'https://rgtechpro.github.io/crippy_privacy_policy/';
  void _launchURL() async {
    try {
      await launch(_url, forceWebView: true);
    } catch (e) {
      final snackBar = SnackBar(
          duration: Duration(milliseconds: 1250), content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Basics'),
            tiles: [
              SettingsTile(
                title: Text('Language'),
               
                leading: Icon(Icons.language),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile.switchTile(
                title: Text('Show More Data'),
                leading: Icon(Icons.show_chart),
                initialValue: a,
                onToggle: (value) {
                  setState(() {
                    a = value;
                  });
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text('Notifications'),
            tiles: [
              SettingsTile.switchTile(
                title: Text('New News Notification'),
                leading: Icon(Icons.dehaze),
                initialValue: b,
                onToggle: (bool value) {
                  setState(() {
                    b = value;
                  });
                },
              ),
              SettingsTile.switchTile(
                title: Text('Push Notifications'),
                leading: Icon(Icons.circle_notifications),
                initialValue: c,
                onToggle: (bool value) {
                  setState(() {
                    setState(() {
                      c = value;
                    });
                  });
                },
              ),
              SettingsTile.switchTile(
                title: Text('Notification Vibration'),
                leading: Icon(Icons.vibration),
                initialValue: d,
                onToggle: (bool value) {
                  setState(() {
                    d = value;
                  });
                },
              ),
            ],
          ),
          SettingsSection(
            title: Text('Misc'),
            tiles: [
              SettingsTile(
                  onPressed: (context) {
                    _launchURL();
                  },
                  title: Text('Privacy Policy'),
                  leading: Icon(Icons.description)),
            ],
          ),
        ],
      ),
    );
  }
}
