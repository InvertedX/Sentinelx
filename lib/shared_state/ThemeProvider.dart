import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeProvider extends ChangeNotifier {
  static Color secondaryBg = Color(0xff262626);
  static Color whiteText = Color(0xffD4D4D4);
  Color accent = Colors.redAccent;
  ThemeData theme;
  ThemeData darkTheme;
  ThemeData lightTheme;

  ThemeProvider() {
    buildThemes();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: secondaryBg, // navigation bar color
    ));
    theme = darkTheme;
  }

  toggleTheme() {
    if (theme.brightness == Brightness.dark) {
      theme = lightTheme;
//      SystemChrome.setSystemUIOverlayStyle(
//          SystemUiOverlayStyle(statusBarColor: darkTheme.primaryColor));
    } else {
      theme = darkTheme;
//      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//          statusBarColor: darkTheme.primaryColor,
//          statusBarBrightness: Brightness.dark));
    }

    notifyListeners();
  }

  buildThemes() {
    darkTheme = new ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xff262626),
        primaryColorDark: Color(0xff212121),
        secondaryHeaderColor: Colors.grey[900],
        accentColor: accent,
        backgroundColor: Color(0xff262626),
        iconTheme: IconThemeData(color: Color(0xffD4D4D4), opacity: 0.8),
        cardColor: Color(0xff393939),
        textTheme: TextTheme(
          headline: TextStyle(color: Color(0xffD4D4D4)),
          title: TextStyle(color: Color(0xffD4D4D4)),
          subhead: TextStyle(color: Color(0xffD4D4D4)),
          body2: TextStyle(color: Color(0xffD4D4D4)),
          body1: TextStyle(color: Color(0xffD4D4D4)),
        ),
        canvasColor: Colors.transparent,
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
        appBarTheme: AppBarTheme(
            brightness: Brightness.dark,
            color: Color(0xff262626),
            elevation: 20));

    lightTheme = new ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xff4d4c5d),
        primaryColorDark: Color(0xff4d4c5d),
        accentColor: accent,
        backgroundColor: Colors.white,
        textTheme: TextTheme(
          headline: TextStyle(color: Colors.grey[800]),
          title: TextStyle(color: Colors.grey[800]),
          body1: TextStyle(color: Colors.grey[800]),
        ),
        canvasColor: Colors.transparent,
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
        appBarTheme: AppBarTheme(
            brightness: Brightness.dark,
            color: Color(0xff4d4c5d),
            elevation: 20));
  }

  void changeAccent(MaterialAccentColor greenAccent) {
    this.accent = greenAccent;
    print("ACC ${accent}");
    buildThemes();
    print("ACC ${darkTheme.accentColor}");
    theme = theme.brightness == Brightness.light ? lightTheme : darkTheme;
    Future.delayed(Duration(milliseconds: 120), () {
      notifyListeners();
    });
  }
}
