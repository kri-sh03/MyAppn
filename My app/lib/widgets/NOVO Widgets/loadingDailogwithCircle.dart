import 'package:flutter/material.dart';
import 'package:novo/utils/colors.dart';

loadingDailogWithCircle(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Dialog(
              elevation: 0,
              child: Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    color: titleTextColorLight,
                    backgroundColor: titleTextColorDark,
                  )),
              backgroundColor: Colors.transparent));
    },
  );
}
