// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:novo/Provider/provider.dart';
import 'package:provider/provider.dart';

import '../Roating/route.dart' as route;

Map<String, String> headers = {
  'Origin': 'https://novo.flattrade.in',
  'Referer': 'https://novo.flattrade.in'
  // 'Origin': 'http://localhost:8080',
  // 'Referer': 'http://localhost:8080'

  // 'Origin': 'https://auth.flattrade.in',,
  // 'Referer': 'https://auth.flattrade.in'
};
//http://localhost:8080
//https://novo.flattrade.in/
// 140,178 //karthickraja
// 114 //nithish
// 101 //prasanth
// 103 //pavithra
// 145 //Kaviya
// 137 //sri
String mainUrl = 'https://novoapi.flattrade.in/';
// String mainUrl = 'http://192.168.02.137:29092/';
// String mainUrl = 'https://localhost:8080/';
// String mainUrl = 'http://192.168.100.207:29091/';
// String mainUrl = 'https://authapi.flattrade.in/auth/session';
// String mainUrl = 'https://novo.flattrade.in/ipo/';

Future<bool> verifyCookies(context) async {
  String cookies =
      Provider.of<NavigationProvider>(context, listen: false).cookies;
  //print(cookies);
  String cookieTime =
      Provider.of<NavigationProvider>(context, listen: false).cookieTime;
  headers["cookie"] = cookies;
  if (cookieTime.isEmpty ||
      cookies.isEmpty ||
      DateTime.parse(cookieTime).difference(DateTime.now()).inMicroseconds <
          0) {
    return false;
  } else {
    return true;
  }
}

void updateCookie(http.Response response, context) async {
  String? rawCookie = response.headers['set-cookie'];
  if (rawCookie != null && rawCookie.isNotEmpty) {
    DateTime validateTime = DateTime.now().add(Duration(
        seconds: int.parse(
            rawCookie.split(";").toList()[3].split("=").toList()[1])));
    Provider.of<NavigationProvider>(context, listen: false)
        .setCookies(rawCookie, validateTime.toString());
  }
}

deleteCookieInSref(context) async {
  Provider.of<NavigationProvider>(context, listen: false).setCookies('', '');
}

logInPost(String url, dynamic data, BuildContext context) async {
  http.Response response =
      await http.post(Uri.parse("$mainUrl$url"), body: data);
  updateCookie(response, context);
  return response;
}

getOtpPost(dynamic data, BuildContext context) async {
  http.Response response = await http
      .put(Uri.parse("https://authapi.flattrade.in/sendOTP"), body: data);
  return response;
}

forgetPassPost(dynamic data, BuildContext context) async {
  http.Response response = await http
      .post(Uri.parse("https://authapi.flattrade.in/ftauthreset"), body: data);
  return response;
}

getCurVersion() async {
  http.Response response =
      await http.post(Uri.parse("http://192.168.2.101:29091/getCurVersion"));
  return response;
}

logOutGet(String url, context) async {
  await verifyCookies(context);
  http.Response response =
      await http.get(Uri.parse("$mainUrl$url"), headers: headers);
  return response;
}

getMethod(String url, context, {Map? header}) async {
  bool validCookie = await verifyCookies(context);

  if (!validCookie) {
    Navigator.pushNamed(context, route.logIn);
    return;
  }

  http.Response response = await http.get(Uri.parse("$mainUrl$url"),
      headers: header != null ? {...headers, ...header} : headers);

  ////////print(header != null ? {...headers, ...header} : headers);
  if (jsonDecode(response.body)["status"] == "I") {
    Navigator.pushNamed(context, route.logIn);
    deleteCookieInSref(context);
    return null;
  }
  return response;
}

postMethod(String url, dynamic data, context) async {
  bool validCookie = await verifyCookies(context);
  if (!validCookie) {
    Navigator.pushNamed(context, route.logIn);
    return;
  }
  http.Response response =
      await http.post(Uri.parse("$mainUrl$url"), body: data, headers: headers);
  if (jsonDecode(response.body)["status"] == "I") {
    Navigator.pushNamed(context, route.logIn);
    deleteCookieInSref(context);
    return null;
  }
  return response;
}

getIpoMktDemandApi(String url, masterid, context) async {
  bool validCookie = await verifyCookies(context);
  if (!validCookie) {
    Navigator.pushNamed(context, route.logIn);
    return;
  }
  headers['ID'] = "$masterid";
  http.Response response =
      await http.get(Uri.parse("$mainUrl$url"), headers: headers);
  if (jsonDecode(response.body)['status'] == "I") {
    Navigator.pushNamed(context, route.logIn);
    deleteCookieInSref(context);
    return null;
  }
  return response;
}

// getHistoryRecordApi(String url, masterid, appName, context) async {
//   bool validCookie = await verifyCookies(context);
//   if (!validCookie) {
//     Navigator.pushNamed(context, route.logIn);
//     return;
//   }
//   headers['ID'] = "$masterid";
//   headers['NO'] = "$appName";
//   http.Response response =
//       await http.get(Uri.parse("$mainUrl$url"), headers: headers);
//   if (jsonDecode(response.body)["status"] == "I") {
//     Navigator.pushNamed(context, route.logIn);
//     deleteCookieInSref(context);
//     return null;
//   }
//   return response;
// }

// getModifyDetailsApi(String url, masterid, category, context) async {
//   bool validCookie = await verifyCookies(context);
//   if (!validCookie) {
//     Navigator.pushNamed(context, route.logIn);
//     return;
//   }
//   headers['ID'] = "$masterid";
//   headers['CATEGORY'] = "$category";
//   http.Response response =
//       await http.get(Uri.parse("$mainUrl$url"), headers: headers);
//   if (jsonDecode(response.body)["status"] == "I") {
//     Navigator.pushNamed(context, route.logIn);
//     deleteCookieInSref(context);
//     return null;
//   }
//   return response;
// }

// getIpoCategoryDetailsApi(String url, masterid, context) async {
//   bool validCookie = await verifyCookies(context);
//   if (!validCookie) {
//     Navigator.pushNamed(context, route.logIn);
//     return;
//   }
//   headers['ID'] = "$masterid";
//   http.Response response =
//       await http.get(Uri.parse("$mainUrl$url"), headers: headers);
//   if (jsonDecode(response.body)["status"] == "I") {
//     Navigator.pushNamed(context, route.logIn);
//     deleteCookieInSref(context);
//     return null;
//   }
//   return response;
// }

// getIpoCategoryPurFlagDetailsApi(String url, masterid, context) async {
//   bool validCookie = await verifyCookies(context);
//   if (!validCookie) {
//     Navigator.pushNamed(context, route.logIn);
//     return;
//   }
//   headers['ID'] = "$masterid";
//   http.Response response =
//       await http.get(Uri.parse("$mainUrl$url"), headers: headers);
//   if (jsonDecode(response.body)["status"] == "I") {
//     Navigator.pushNamed(context, route.logIn);
//     deleteCookieInSref(context);
//     return null;
//   }
//   return response;
// }



// post method 
//  Map res = await post("http://192.168.2.153:26301/Login", jsonEncode({"a":1,"b":2}));

// get method
//     Map r = await get("http://192.168.2.153:26301/TokenValidate");