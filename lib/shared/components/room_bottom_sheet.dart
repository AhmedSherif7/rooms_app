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
      height: AppSize.s100,
      width: AppSize.deviceWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p20,
        vertical: AppPadding.p20,
      ),
      child: child,
    );
  }
}
