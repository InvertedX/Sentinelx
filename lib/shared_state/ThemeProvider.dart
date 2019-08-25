
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeProvider extends ChangeNotifier {

  static Color secondaryBg = Color(0xff1a1d29);

  static ThemeData darkTheme = new ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xff6F4CFF),
      accentColor: Color(0xff5666fa),
      textTheme: TextTheme(
        headline: TextStyle(fontSize: 72.0, color: Colors.grey[300]),
        title: TextStyle(fontSize: 36.0, color:  Colors.grey[300]),
        body1: TextStyle(fontSize: 14.0, color: Colors.grey[300]),
      ),
      canvasColor: Colors.transparent,
      platform: TargetPlatform.fuchsia,
      appBarTheme: AppBarTheme(brightness: Brightness.dark, color: Color(0xff1a1d29), elevation: 20));

  static ThemeData lightTheme = new ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xff6F4CFF),
      accentColor: Color(0xff5666fa),
      textTheme: TextTheme(
        headline: TextStyle(fontSize: 72.0, color: Colors.grey[800]),
        title: TextStyle(fontSize: 36.0, color: Colors.grey[800]),
        body1: TextStyle(fontSize: 14.0, color: Colors.grey[800]),
      ),
      canvasColor: Colors.transparent,
      appBarTheme: AppBarTheme(brightness: Brightness.dark, color: Color(0xff4d4c5d), elevation: 20));

  ThemeData theme = darkTheme;

  ThemeProvider() {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor:  Color(0xff1a1d29), statusBarBrightness: Brightness.light));
  }

  toggleTheme() {
    if (theme.brightness == Brightness.dark) {
      theme = lightTheme;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:  Color(0xff1a1d29)));
    } else {
      theme = darkTheme;
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: Color(0xff1a1d29), statusBarBrightness: Brightness.dark));
    }
    notifyListeners();
  }
}