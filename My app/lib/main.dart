import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:novo/Provider/provider.dart';
import 'package:novo/firebase_options.dart';
import 'package:novo/utils/Themes/theme.dart';
import 'package:provider/provider.dart';

import 'Roating/route.dart' as route;

final navigatorKey = GlobalKey<NavigatorState>();
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  print('Background******* Handler');
  await getNotification(
      title: message.notification!.title!,
      body: message.notification!.body!,
      messageId: message.data['key'] ?? message.sentTime.toString(),
      subTopic: message.from!.split('/').last);

  print('Handling a background message ${message.messageId}');
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
);
bool isFlutterLocalNotificationsInitialized = false;
Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

List msg = [];

final FirebaseFirestore firestore = FirebaseFirestore.instance;
Future<String> getNotification({
  required String title,
  required String body,
  required String messageId,
  required String subTopic,
  // required bool deviceIsActive,
}) async {
  // getMessageFromFireBase();
  print('getNotification');
  print('before..............');

  print(msg);
  print('subTopic');
  print(subTopic);

  msg = await load();

  print('*****after*********');
  print(msg);
  List msgId = [];
  for (var message in msg) {
    msgId.add(message['id']);
  }
  print('Message Id');
  print(msgId);
  if (!msgId.contains(messageId)) {
    msg.add(
        {"title": title, 'body': body, 'id': messageId, 'subTopic': subTopic});
  }

  //  bool ismsgId =  msg.;

  print('After Adding notification');
  print(msg);
  String res = 'Some Error Occured';
  try {
    await firestore
        .collection('global_Messages')
        .doc('Notifications')
        .update({"message": msg});
    res = 'success';
    print('After Adding from notification');
    print(msg);
    print('res : $res');
  } catch (e) {
    res = e.toString();
  }
  return res;
}

Future<List<Map<String, dynamic>>> load() async {
  List<Map<String, dynamic>> msg = [];

  try {
    print('Load 1 ');
    var collectionRef = firestore.collection('global_Messages');
    var collectionSnapshot = await collectionRef.get();

    if (collectionSnapshot.docs.isNotEmpty) {
      print('Document is not Empty');

      var docSnapshot = await collectionRef.doc('Notifications').get();
      if (docSnapshot.exists && docSnapshot.data()!.containsKey('message')) {
        print('Data is Not Empty');
        msg = List<Map<String, dynamic>>.from(docSnapshot.get('message'));
        print(msg);
      } else {
        print('Setting the messages');
        await collectionRef.doc('Notifications').set({'message': []});
      }
    } else {
      print('else Part');
      await collectionRef.doc('Notifications').set({'message': []});
      msg = [];
    }
  } catch (e) {
    print('Error loading data from Firestore: $e');
  }

  return msg;
}

Future<void> handleMessage(RemoteMessage message) async {
  final notification = message.notification;
  print('Key **************');
  print(message.data);
  // print(notification!.titleLocArgs);
  // print(notification!.titleLocKey);
  // print(notification!.bodyLocKey);
  // print(notification!.bodyLocArgs);
  print(message.messageId);

  String res = notification!.title!;
  String resbody = notification.body!;
  print(res);
  print(resbody);
  print("********Handle************");
  print(msg);
  print('topic');
  print(message.from!.split('/').last);
  // if (message.data['subTopic'].isEmpty ||
  //     message.data['subTopic'] == null ||
  //     message.data['subTopic'] == 'allDevice') {
  //   print('+++++++GlobalTopic+++++++++');
  // } else {
  //   print('**********UserTopic**************');
  // }
  await getNotification(
      title: notification.title!,
      body: message.notification!.body!,
      messageId: message.data['key'] ?? message.sentTime.toString(),
      subTopic: message.from!.split('/').last);
  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // try {
  //   // WidgetsFlutterBinding.ensureInitialized();
  //   if (kIsWeb) {
  //     await Firebase.initializeApp(
  //       options: const FirebaseOptions(
  //         apiKey: "AIzaSyCDM04UIi73psmxXX_nxjZxnxwNn3hvyME",
  //         appId: "1:598395567919:android:94f9cc9a055fb0a0702bda",
  //         messagingSenderId: "598395567919",
  //         projectId: "novo-app-flattrade",
  //         storageBucket: "novo-app-flattrade.appspot.com",
  //       ),
  //     );
  //   } else {
  //     await Firebase.initializeApp(
  //         options: FirebaseOptions(
  //       apiKey: "AIzaSyCDM04UIi73psmxXX_nxjZxnxwNn3hvyME",
  //       appId: "1:598395567919:android:94f9cc9a055fb0a0702bda",
  //       messagingSenderId: "598395567919",
  //       projectId: "novo-app-flattrade",
  //       storageBucket: "novo-app-flattrade.appspot.com",
  //     ));
  //   }
  // } catch (e) {
  //   //print(e.toString());
  // }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('********Started******************');
  await FirebaseMessaging.instance
      .subscribeToTopic(Firebase.app().options.appId.split(':')[1]);
  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    navigatorKey.currentState!.pushNamed(route.notification);

    print(event);
  }, onError: (error) {
    print("Error handling onMessageOpenedApp: $error");
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(handleMessage);
  var token = await FirebaseMessaging.instance.getToken();
  print('Fcm Token $token 333');

  // await AuthMethods().initPushNotifications();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark),
  );

  // var data = await firestore
  //     .collection('Users')
  //     .doc('first_User')
  //     .collection('NEXt User')
  //     .get();
  // await data.docs[0].reference.parent
  //     .snapshots(includeMetadataChanges: true)
  //     .first
  //     .then((value) => print(value.docs.));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => NavigationProvider(),
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOVO',
      navigatorKey: navigatorKey,
      theme: ThemeClass.lighttheme,
      darkTheme: ThemeClass.Darktheme,
      themeMode: Provider.of<NavigationProvider>(context).themeMode,
      scrollBehavior: MyBehavior(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: route.controller,
      initialRoute: route.flashScreen,
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
