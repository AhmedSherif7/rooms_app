import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:room_app/shared/resources/color_manager.dart';
import 'package:room_app/shared/resources/font_manager.dart';
import 'package:room_app/shared/resources/values_manager.dart';

enum States {
  success,
  error,
  warning,
}

Color chooseToastColor(States state) {
  Color color;

  switch (state) {
    case States.success:
      color = Colors.green;
      break;
    case States.error:
      color = Colors.red;
      break;
    case States.warning:
      color = Colors.amber;
      break;
  }

  return color;
}

void showToast({required String message, required States state}) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: chooseToastColor(state),
    textColor: ColorManager.white,
    fontSize: FontSize.s16,
  );
}

void showConfirmDialog({
  required BuildContext context,
  required String title,
  required String desc,
  required IconData headerIcon,
  required Function() confirmHandler,
  required Function() cancelHandler,
  required States state,
}) {
  late Color color;
  switch (state) {
    case States.error:
      color = ColorManager.error;
      break;
    case States.success:
      color = ColorManager.success;
      break;
    case States.warning:
      color = ColorManager.warning;
      break;
    default:
      color = ColorManager.primary;
  }

  AwesomeDialog(
    context: context,
    animType: AnimType.SCALE,
    customHeader: CircleAvatar(
      radius: AppSize.s50,
      backgroundColor: color,
      child: Icon(
        headerIcon,
        color: ColorManager.white,
        size: AppSize.s30,
      ),
    ),
    title: title,
    desc: desc,
    btnOkOnPress: confirmHandler,
    btnCancelOnPress: cancelHandler,
    btnOkText: 'OK',
    btnCancelText: 'CANCEL',
  ).show();
}

String getFormattedDuration(Duration duration) {
  String roomTotalTime = '';
  if (duration.inHours <= 9) {
    roomTotalTime = '0${duration.inHours}:';
  } else {
    roomTotalTime = '${duration.inHours}:';
  }
  if (duration.inMinutes - (duration.inHours * 60) <= 9) {
    roomTotalTime += '0${duration.inMinutes - (duration.inHours * 60)}:';
  } else {
    roomTotalTime += '${duration.inMinutes - (duration.inHours * 60)}:';
  }
  if (duration.inSeconds -
          (duration.inHours * 3600 + duration.inMinutes * 60) <=
      9) {
    roomTotalTime +=
        '0${duration.inSeconds - (duration.inHours * 3600 + duration.inMinutes * 60)}';
  } else {
    roomTotalTime +=
        '${duration.inSeconds - (duration.inHours * 3600 + duration.inMinutes * 60)}';
  }
  return roomTotalTime;
}
