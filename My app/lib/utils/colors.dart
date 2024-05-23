import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Color appPrimeColor = const Color.fromRGBO(0, 74, 177, 1);
Color titleTextColorLight = const Color.fromRGBO(67, 67, 79, 1);
Color titleTextColorDark = Colors.white;
Color subTitleTextColor = const Color.fromRGBO(156, 155, 173, 1);
Color primaryRedColor = const Color.fromRGBO(236, 52, 78, 1);
Color primaryGreenColor = const Color.fromRGBO(11, 154, 124, 1);
Color primaryOrangeColor = const Color.fromRGBO(251, 140, 0, 1);
Color modifyButtonColor = const Color.fromRGBO(187, 222, 251, 1);
Color footerBackgroundColor = const Color.fromRGBO(225, 245, 254, 1);
Color activeColor = const Color.fromRGBO(83, 183, 162, 1);
Color inactiveColor = const Color.fromRGBO(240, 240, 240, 1);
Color infoColorStart = const Color.fromRGBO(236, 177, 82, 1);
Color infoColor = const Color.fromRGBO(255, 243, 224, 1);
Color sgbPrimaryColor = const Color.fromRGBO(255, 249, 160, 1);

double titleFontSize = 16.0;
double subTitleFontSize = 14.0;
double contentFontSize = 12.0;
String somethingError = 'Something went wrong...';
String sessionError = 'Session Expired...';
var rsFormat = NumberFormat.currency(
  // name: "",
  locale: 'en_IN',
  decimalDigits: 0,
  // change it to get decimal places
  symbol: '₹ ',
);
var rsMrkFormat = NumberFormat.currency(
  // name: "",
  locale: 'en_IN',
  decimalDigits: 0,
  symbol: '',
  // change it to get decimal places
);

String formatMrkNumber(int number) {
  if (number < 100000) {
    return rsMrkFormat.format(number); // Return as is if less than 1 lakh
  } else if (number >= 100000 && number < 10000000) {
    double lakhs = number / 100000;
    return '${lakhs.toStringAsFixed(2)} Lakhs';
  } else {
    double crores = number / 10000000;
    return '${crores.toStringAsFixed(2)} Crores';
  }
}

String formatNumber(int number) {
  if (number < 100000) {
    return rsFormat.format(number); // Return as is if less than 1 lakh
  } else if (number >= 100000 && number < 10000000) {
    double lakhs = number / 100000;
    return '${lakhs.toStringAsFixed(2)} Lakhs';
  } else {
    double crores = number / 10000000;
    return '${crores.toStringAsFixed(2)} Crores';
  }
}
