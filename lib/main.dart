import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

void main(){
  runApp(MyApp());
  setFirebase();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FCM',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter FCM'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text("Hello World"),
      ),
    );
  }
}

void setFirebase() async {
  var initializationSettingsAndroid =
  new AndroidInitializationSettings('icon_notif');

  var initializationSettingsIOS =
  IOSInitializationSettings();

  var initializationSettings =
  InitializationSettings(
      initializationSettingsAndroid,
      initializationSettingsIOS);

  flutterLocalNotificationsPlugin
      .initialize(initializationSettings,
      onSelectNotification: onSelect);

  final FirebaseMessaging _firebaseMessaging =
  FirebaseMessaging();

  await _firebaseMessaging.requestNotificationPermissions(
    const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
  );

  _firebaseMessaging.configure(
    onBackgroundMessage: Platform.isIOS ?
    null : myBackgroundMessageHandler,
    onMessage: (message) async {
      print("onMessage: $message");
    },
    onLaunch: (message) async {
      print("onLaunch: $message");
    },
    onResume: (message) async {
      print("onResume: $message");
    },
  );

  _firebaseMessaging.getToken()
      .then((String token) {
    print("Push Messaging token: $token");
    // Push messaging to this token later
  });

}

Future<String> onSelect(String data) async {
  print("onSelectNotification $data");
}

Future<dynamic> myBackgroundMessageHandler(Map<String,
    dynamic> message) async {
  print("myBackgroundMessageHandler message: $message");
  int msgId = int.tryParse(message["data"]["msgId"]
      .toString()) ?? 0;
  print("msgId $msgId");
  var androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
      'your channel id', 'your channel name',
      'your channel description', color: Colors.blue.shade800,
      importance: Importance.Max,
      priority: Priority.High, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics);
  flutterLocalNotificationsPlugin
      .show(msgId,
      message["data"]["msgTitle"],
      message["data"]["msgBody"], platformChannelSpecifics,
      payload: message["data"]["data"]);
  return Future<void>.value();
}