import 'package:flutter/material.dart';
import 'package:novo/utils/Themes/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationProvider with ChangeNotifier {
  ThemeData currentTheme = ThemeClass.lighttheme;
  ThemeMode themeMode = ThemeMode.light;
  String cookies = '';
  String cookieTime = ''; // Default to system mode

  themeModel() {
    loadThemeFromPrefs();
  }

  void toggleTheme(context) {
    if (themeMode == ThemeMode.light) {
      themeMode = ThemeMode.dark;
      currentTheme = ThemeClass.Darktheme;
    } else {
      themeMode = ThemeMode.light;
      currentTheme = ThemeClass.lighttheme;
    }
    saveThemeToPrefs();
    notifyListeners();
  }

  void loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme');

    if (savedTheme == 'dark') {
      themeMode = ThemeMode.dark;
      currentTheme = ThemeClass.Darktheme;
    } else if (savedTheme == 'light') {
      themeMode = ThemeMode.light;
      currentTheme = ThemeClass.lighttheme;
    }
    notifyListeners();
  }

  void saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', themeMode.toString().split('.').last);
  }

  getCookie() async {
    SharedPreferences sref = await SharedPreferences.getInstance();
    cookies = sref.getString("cookies") ?? "";
    cookieTime = sref.getString("cookieTime") ?? "";
    notifyListeners();
  }

  setCookies(String rawCookie, String newCookieTime) async {
    SharedPreferences sref = await SharedPreferences.getInstance();

    sref.setString("cookieTime", newCookieTime);
    sref.setString("cookies", rawCookie);
    cookies = rawCookie;
    cookieTime = newCookieTime;
    notifyListeners();
  }
}
