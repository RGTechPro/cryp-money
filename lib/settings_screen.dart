import 'package:cryptapp/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

