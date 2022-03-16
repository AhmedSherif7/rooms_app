import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../models/room_model.dart';
import '../constants.dart';

class NotificationManager {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final BehaviorSubject<String> selectNotificationSubject =
      BehaviorSubject<String>();

  static initializeNotification(BuildContext context) async {
    tz.initializeTimeZones();
    _configureSelectNotificationSubject();
    await _configureLocalTimeZone();
    const initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const initializationSettings = InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? roomId) async {
        if (roomId != null) {
          debugPrint('notification payload: ' + roomId);
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => RoomScreen(roomId),
          //   ),
          // );
        }
        selectNotificationSubject.add(roomId!);
      },
    );
  }

  // displayNotification({required String title, required String body}) async {
  //   print('doing test');
  //   var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
  //     'your channel id',
  //     'your channel name',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
  //   var platformChannelSpecifics = NotificationDetails(
  //       android: androidPlatformChannelSpecifics,
  //       iOS: iOSPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     title,
  //     body,
  //     platformChannelSpecifics,
  //     payload: 'Default_Sound',
  //   );
  // }

  static List<Map> notifications = [];

  static void getNotifications() {
    notifications.clear();
    FirebaseFirestore.instance
        .collection('users')
        .doc(Constants.uid)
        .collection('notifications')
        .get()
        .then((res) {
      for (var notification in res.docs) {
        if ((notification['roomDateTime'].toDate() as DateTime)
            .subtract(const Duration(minutes: 5))
            .isAfter(DateTime.now())) {
          scheduledNotification(
            notification['roomId'],
            notification['roomTitle'],
            notification['roomDateTime'].toDate(),
            myRoom: notification['myRoom'],
          );
        }
      }
    });
  }

  static Future<void> scheduledNotification(
      String roomId, String roomTitle, DateTime dateTime,
      {required bool myRoom}) async {
    notifications.add({
      'roomId': roomId,
      'roomTitle': roomTitle,
      'notificationDateTime': dateTime,
      'myRoom': myRoom,
    });
    return flutterLocalNotificationsPlugin.zonedSchedule(
      dateTime.millisecondsSinceEpoch ~/ 1000,
      myRoom ? 'your room $roomTitle' : 'room $roomTitle',
      myRoom ? 'time is about to come' : 'is about to start',
      _nextInstanceOfTenAM(
        dateTime,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: roomId,
    );
  }

  static tz.TZDateTime _nextInstanceOfTenAM(
    DateTime dateTime,
  ) {
    var scheduleDateTime = dateTime.subtract(const Duration(minutes: 5));
    tz.TZDateTime formattedLocalDate =
        tz.TZDateTime.from(scheduleDateTime, tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      formattedLocalDate.year,
      formattedLocalDate.month,
      formattedLocalDate.day,
      scheduleDateTime.hour,
      scheduleDateTime.minute,
    );
    return scheduledDate;
  }

  static Future<void> cancelNotification(RoomModel room) async {
    notifications
        .removeWhere((notification) => notification['roomId'] == room.id);
    await flutterLocalNotificationsPlugin
        .cancel(room.dateTime!.toDate().millisecondsSinceEpoch ~/ 1000);
  }

  static Future<void> cancelAllNotifications() async {
    notifications.clear();
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

/*   Future selectNotification(String? payload) async {
    if (payload != null) {
      //selectedNotificationPayload = "The best";
      selectNotificationSubject.add(payload);
      print('notification payload: $payload');
    } else {
      print("Notification Done");
    }
    Get.to(() => SecondScreen(selectedNotificationPayload));
  } */

//Older IOS
  static Future onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // display a dialog with the notification details, tap ok to go to another page
    /* showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Title'),
        content: const Text('Body'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Container(color: Colors.white),
                ),
              );
            },
          )
        ],
      ),
    );
 */
    // Get.dialog(Text(body!));
  }

  static void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      debugPrint('My payload is ' + payload);
      // await Get.to(() => NotificationScreen(payload: payload));
    });
  }
}
