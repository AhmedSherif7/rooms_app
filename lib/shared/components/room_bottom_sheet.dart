import 'package:flutter/material.dart';
import 'package:room_app/shared/cubit/cubit.dart';

import '../../shared/resources/color_manager.dart';
import '../../shared/resources/values_manager.dart';

class RoomBottomSheet extends StatelessWidget {
  const RoomBottomSheet(this.child, {Key? key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppCubit.get(context).isDarkMode
          ? ColorManager.darkGrey
          : ColorManager.white,
      height: AppSize.s80,
      width: AppSize.deviceWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p20,
        vertical: AppPadding.p12,
      ),
      margin: const EdgeInsets.only(
        bottom: AppMargin.m12,
      ),
      child: child,
    );
  }
}
