import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentinelx/shared_state/change_notifier.dart';

class ThemeState extends SentinelXChangeNotifier {
  static Color secondaryBg = Color(0xff262626);
  static Color whiteText = Color(0xffD4D4D4);
  Color accent = Colors.redAccent.shade200;
  ThemeData theme ;
  ThemeData darkTheme;
  ThemeData lightTheme;
  static Map<String, Color> accentColors = {
    "Red": Colors.redAccent.shade200,
    "Green": Colors.greenAccent.shade700,
    "Blue": Colors.blueAccent.shade400,
    "Amber": Colors.amberAccent.shade400,
    "Indigo": Colors.indigoAccent,
    "Orange": Colors.orangeAccent.shade400,
  };

  ThemeState() {
    buildThemes();
    theme = darkTheme;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: darkTheme.primaryColorDark,
      systemNavigationBarColor: darkTheme.primaryColorDark,
    ));
  }

  toggleTheme() {
    if (theme.brightness == Brightness.dark) {
      theme = lightTheme;
    } else {
      theme = darkTheme;
    }
    notifyListeners();
  }

  setDark() {
    theme = darkTheme;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: darkTheme.primaryColorDark,
      systemNavigationBarColor: darkTheme.primaryColorDark,
    ));
    notifyListeners();
  }

  setLight() {

    theme = lightTheme;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff403F4D),
      systemNavigationBarColor: lightTheme.primaryColorDark,
    ));
    notifyListeners();
  }

  isActiveAccent(Color color) {
    return accent.value == color.value;
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
        cardColor: Color(0xff282828),
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
        backgroundColor: Color(0xfff9f9f9),
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

  isDarkThemeEnabled() {
    return this.theme.brightness == Brightness.dark;
  }

  void changeAccent(Color greenAccent) {
    this.accent = greenAccent;
    buildThemes();
    theme = theme.brightness == Brightness.light ? lightTheme : darkTheme;
    notifyListeners();
  }
}
