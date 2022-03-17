import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:room_app/modules/auth/cubit/auth_cubit.dart';
import 'package:room_app/shared/components/room_layout.dart';
import 'package:room_app/shared/constants.dart';
import 'package:room_app/shared/resources/assets_manager.dart';

import '../../models/room_model.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
import '../../shared/helper_functions.dart';
import '../../shared/resources/color_manager.dart';
import '../../shared/resources/values_manager.dart';

class FinishedRoomScreen extends StatelessWidget {
  const FinishedRoomScreen(this.room, {Key? key}) : super(key: key);

  final RoomModel room;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is AppDeleteRoomSuccessState) {
          // Navigator.pop(context);
          showToast(
            message: 'Room Deleted Successfully',
            state: States.success,
          );
        }
      },
      builder: (context, state) {
        var duration =
            room.endedAt!.toDate().difference(room.startedAt!.toDate());

        var dateTime = room.endedAt!.toDate();
        var formattedDateTime = DateFormat('dd MMM, hh:mm a').format(dateTime);

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(getFormattedDuration(duration)),
            actions: [
              if (room.createdBy!['phone'] == Constants.phone)
                IconButton(
                  onPressed: () {
                    AppCubit.get(context).deleteRoom(room.id!);
                  },
                  icon: const Icon(
                    Icons.delete_forever,
                    color: ColorManager.error,
                  ),
                ),
            ],
          ),
          body: RoomLayout(
            room,
            Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Divider(),
                    ),
                    const SizedBox(
                      width: AppSize.s4,
                    ),
                    Text(
                      'Invited Speakers',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    const SizedBox(
                      width: AppSize.s4,
                    ),
                    const Expanded(
                      child: Divider(),
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: room.invitedSpeakers!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: ColorManager.teal,
                        child: Icon(
                          Icons.person,
                          color: ColorManager.white,
                        ),
                      ),
                      title: Text(
                        AuthCubit.get(context).user!.phone ==
                                room.invitedSpeakers![index]['phone']
                            ? '${AuthCubit.get(context).user!.name} (Me)'
                            : room.invitedSpeakers![index]['name'],
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: AppSize.s20,
                ),
                Text(
                  'Room ended at',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(
                  height: AppSize.s5,
                ),
                Text(
                  formattedDateTime,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: ColorManager.error),
                ),
                const SizedBox(
                  height: AppSize.s5,
                ),
                Text(
                  'Thank you for listening',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
            ImageAssets.finishedRoomImage,
          ),
        );
      },
    );
  }
}
