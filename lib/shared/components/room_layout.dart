import 'package:flutter/material.dart';
import 'package:room_app/shared/cubit/cubit.dart';

import '../../models/room_model.dart';
import '../../shared/resources/color_manager.dart';
import '../../shared/resources/values_manager.dart';

class RoomLayout extends StatefulWidget {
  const RoomLayout(this.room, this.roomBody, this.image, {Key? key})
      : super(key: key);

  final RoomModel room;
  final Widget roomBody;
  final String image;

  @override
  State<RoomLayout> createState() => _RoomLayoutState();
}

class _RoomLayoutState extends State<RoomLayout> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(AppPadding.p20),
        width: AppSize.deviceWidth,
        height: AppSize.deviceHeight - 92.0,
        decoration: BoxDecoration(
          color: AppCubit.get(context).isDarkMode
              ? ColorManager.darkGrey
              : ColorManager.white,
          borderRadius: BorderRadius.circular(AppSize.s40),
        ),
        child: Column(
          children: [
            Image.asset(
              widget.image,
              height: AppSize.s200,
            ),
            const SizedBox(
              height: AppSize.s20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.room.title!,
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(
                  width: AppSize.s8,
                ),
                Icon(
                  widget.room.type == 'private' ? Icons.lock : Icons.public,
                ),
              ],
            ),
            const SizedBox(
              height: AppSize.s8,
            ),
            Text(
              'in ${widget.room.category!}',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(
              height: AppSize.s30,
            ),
            Expanded(
              child: widget.roomBody,
            ),
            const SizedBox(
              height: AppSize.s10,
            ),
          ],
        ),
      ),
    );
  }
}
