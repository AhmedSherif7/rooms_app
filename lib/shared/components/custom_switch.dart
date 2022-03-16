import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:room_app/shared/cubit/cubit.dart';

import '../resources/color_manager.dart';
import '../resources/values_manager.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({
    Key? key,
    required this.enabledText,
    required this.disabledText,
    required this.activeIcon,
    required this.inActiveIcon,
    required this.activeColor,
    required this.inActiveColor,
    required this.value,
    required this.onToggle,
  }) : super(key: key);

  final String enabledText;
  final String disabledText;
  final IconData activeIcon;
  final IconData inActiveIcon;
  final Color activeColor;
  final Color inActiveColor;
  final bool value;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          disabledText,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: AppCubit.get(context).isDarkMode
                    ? ColorManager.lightBackground
                    : ColorManager.black,
              ),
        ),
        const SizedBox(
          width: AppSize.s8,
        ),
        FlutterSwitch(
          activeIcon: Icon(
            activeIcon,
            color: ColorManager.black,
          ),
          inactiveIcon: Icon(
            inActiveIcon,
            color: ColorManager.black,
          ),
          activeColor: activeColor,
          inactiveColor: inActiveColor,
          value: value,
          borderRadius: AppSize.s30,
          showOnOff: false,
          onToggle: onToggle,
        ),
        const SizedBox(
          width: AppSize.s8,
        ),
        Text(
          enabledText,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: AppCubit.get(context).isDarkMode
                    ? ColorManager.lightBackground
                    : ColorManager.black,
              ),
        ),
      ],
    );
  }
}
