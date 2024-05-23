import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:novo/Provider/provider.dart';
import 'package:novo/main.dart';
import 'package:novo/utils/Themes/theme.dart';
import 'package:novo/utils/colors.dart';
import 'package:novo/widgets/NOVO%20Widgets/netWorkConnectionALertBox.dart';
import 'package:novo/widgets/NOVO%20Widgets/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    getDetails();
    getClientDetails();
    // print('FireBaseId');
    // print(Firebase.app().options.appId.split(':')[1]);
    // print(Firebase.app().options.projectId);
    super.initState();
  }

  String clientId = '';
  getClientDetails() async {
    try {
      if (await isInternetConnected()) {
        SharedPreferences sref = await SharedPreferences.getInstance();
        clientId = sref.getString("clientId") ?? '';
        print(clientId);
      } else {
        noInternetConnectAlertDialog(context, () => getClientDetails());
      }
      setState(() {});
    } catch (e) {
      showSnackbar(context, somethingError, Colors.red);
    }
    return null;
  }

  TextEditingController globalMsgController = TextEditingController();
  TextEditingController userMsgController = TextEditingController();
  List messages = [];
  List globalMsg = [];
  List clientMsg = [];
  // final firebaseStorage = FirebaseFirestore.instance;
  getDetails() async {
    try {
      var details = await firestore
          .collection('global_Messages')
          .doc('Notifications')
          .get();
      if (details['message'] != null) {
        messages = details['message'];
        print('messageeeee');
        print(messages);
        for (var msg in messages) {
          if (msg['subTopic'] == Firebase.app().options.appId.split(':')[1]) {
            globalMsg.add(msg);
          } else {
            if (msg['subTopic'] == clientId) {
              clientMsg.add(msg);
            }
          }
        }
      } else {
        messages = [];
      }
    } catch (e) {
      // //print(e);
      messages = [];
    }

    //print('*****************');
    //print(messages);
    // //print(details.docs[0].data()['List']);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var darkThemeMode =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark;
    Color themeBasedColor =
        Provider.of<NavigationProvider>(context).themeMode == ThemeMode.dark
            ? titleTextColorDark
            : titleTextColorLight;
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: themeBasedColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Notifications',
                      style: darkThemeMode
                          ? ThemeClass.Darktheme.textTheme.titleMedium
                          : ThemeClass.lighttheme.textTheme.titleMedium,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                TabBar(
                  labelColor: Colors.black,
                  tabs: [
                    Text('Global'),
                    Text('User'),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      messages.isNotEmpty
                          ? ListView.builder(
                              itemCount: globalMsg.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(globalMsg[index]['title'] ?? ''),
                                  subtitle:
                                      Text(globalMsg[index]['body'] ?? ''),
                                  // onTap: () {
                                  //   //print('Notificationm');
                                  //   ChangeIndex().value = 5;
                                  // },
                                );
                              },
                            )
                          : Center(child: Text('Nothing to see here , yet')),
                      messages.isNotEmpty
                          ? ListView.builder(
                              itemCount: clientMsg.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(clientMsg[index]['title'] ?? ''),
                                  subtitle:
                                      Text(clientMsg[index]['body'] ?? ''),
                                  // onTap: () {
                                  //   //print('Notificationm');
                                  //   ChangeIndex().value = 5;
                                  // },
                                );
                              },
                            )
                          : Center(child: Text('Nothing to see here , yet')),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: globalMsgController,
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    sendNotificationToTopicGlobal(
                      title: 'FCM Test',
                      body: globalMsgController.text,
                      topic: Firebase.app().options.appId.split(':')[1],
                    );
                  },
                  child: Text('Send Msg Globally'),
                ),
                TextFormField(
                  controller: userMsgController,
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    sendNotificationToTopicUser(
                      title: 'FCM Test',
                      body: userMsgController.text,
                      topic: clientId,
                    );
                  },
                  child: Text('Send Msg To User'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> sendNotificationToTopicGlobal({
  required String title,
  required String body,
  required String topic,
}) async {
  final String serverKey =
      'AAAAacjBFHs:APA91bHFHUal9E_e3BB0-IyUAnm0W0zrXZZ6jPAt-SuujcVrKspIvEoL7Ane9sU7eVsUCw-9-IKqxD9WAm5QkA301vCbsqbKOigcnXnq7wOwOamnItxZo8uF1P03Oz6Er9MGxtXBa-6S';

  String url = 'https://fcm.googleapis.com/fcm/send';

  final Map<String, dynamic> payload = {
    'notification': {
      'title': title,
      'body': body,
    },
    'priority': 'high',
    'data': {
      "key": DateTime.now().toString(),
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      "message": "Hello FCM!",
      "subTopic": topic
    },
    'to': '/topics/$topic', // Send to a specific topic
  };

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=$serverKey',
  };

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(payload),
  );
  if (response.statusCode == 200) {
    //print('Notification sent successfully');
  } else {
    //print('Failed to send notification. Error: ${response.reasonPhrase}');
  }
}

Future<void> sendNotificationToTopicUser({
  required String title,
  required String body,
  required String topic,
}) async {
  final String serverKey =
      'AAAAacjBFHs:APA91bHFHUal9E_e3BB0-IyUAnm0W0zrXZZ6jPAt-SuujcVrKspIvEoL7Ane9sU7eVsUCw-9-IKqxD9WAm5QkA301vCbsqbKOigcnXnq7wOwOamnItxZo8uF1P03Oz6Er9MGxtXBa-6S';

  String url = 'https://fcm.googleapis.com/fcm/send';

  final Map<String, dynamic> payload = {
    'notification': {
      'title': title,
      'body': body,
    },
    'priority': 'high',
    'data': {
      "key": DateTime.now().toString(),
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      "message": "Hello FCM!",
      "subTopic": topic
    },
    'to': '/topics/$topic', // Send to a specific topic
  };

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'key=$serverKey',
  };

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(payload),
  );
  if (response.statusCode == 200) {
    //print('Notification sent successfully');
  } else {
    //print('Failed to send notification. Error: ${response.reasonPhrase}');
  }
}
