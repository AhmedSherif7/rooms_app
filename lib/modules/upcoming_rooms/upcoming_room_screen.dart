import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:room_app/modules/auth/cubit/auth_cubit.dart';
import 'package:room_app/shared/components/room_bottom_sheet.dart';
import 'package:room_app/shared/components/room_layout.dart';
import 'package:room_app/shared/constants.dart';
import 'package:room_app/shared/resources/assets_manager.dart';
import 'package:room_app/shared/resources/notifications_manager.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../../models/room_model.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
import '../../shared/helper_functions.dart';
import '../../shared/resources/color_manager.dart';
import '../../shared/resources/values_manager.dart';

class UpcomingRoomScreen extends StatefulWidget {
  const UpcomingRoomScreen(this.room, {Key? key}) : super(key: key);

  final RoomModel room;

  @override
  State<UpcomingRoomScreen> createState() => _UpcomingRoomScreenState();
}

class _UpcomingRoomScreenState extends State<UpcomingRoomScreen> {
  StopWatchTimer? _stopWatchTimer;
  late Duration _duration;
  bool _hasNotification = false;

  @override
  void initState() {
    _duration = widget.room.dateTime!.toDate().difference(DateTime.now());

    if (_duration.inDays < 1) {
      _stopWatchTimer = StopWatchTimer(
        mode: StopWatchMode.countDown,
        presetMillisecond:
            StopWatchTimer.getMilliSecFromSecond(_duration.inSeconds),
      );
      _stopWatchTimer!.onExecute.add(StopWatchExecute.start);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (_stopWatchTimer != null) {
      _stopWatchTimer!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is AppSetNotificationSuccessState) {
          showToast(
            message: 'you will be notified before the room starts',
            state: States.success,
          );
        }
        if (state is AppCancelNotificationSuccessState) {
          showToast(
            message: 'notification canceled',
            state: States.warning,
          );
        }
      },
      builder: (context, state) {
        var cubit = AppCubit.get(context);

        _hasNotification = NotificationManager.notifications
            .any((notification) => notification['roomId'] == widget.room.id);

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: ConditionalBuilder(
              condition: _duration.inDays >= 1,
              builder: (context) => Text(
                '${_duration.inDays} day${_duration.inDays > 1 ? 's' : ''} ${_duration.inHours - (_duration.inDays * 24)} hour${_duration.inHours - (_duration.inDays * 24) > 1 ? 's' : ''}',
              ),
              fallback: (context) {
                return StreamBuilder<int>(
                  stream: _stopWatchTimer!.rawTime,
                  initialData: 0,
                  builder: (context, snap) {
                    final value = snap.data;
                    final displayTime = StopWatchTimer.getDisplayTime(
                      value!,
                      milliSecond: false,
                    );
                    return Text(
                      value == 0 ? 'Room is about to start' : displayTime,
                    );
                  },
                );
              },
            ),
            actions: [
              IconButton(
                onPressed: () {
                  if (_hasNotification) {
                    cubit.cancelNotification(widget.room);
                  } else {
                    if (widget.room.dateTime!
                        .toDate()
                        .subtract(const Duration(minutes: 5))
                        .isBefore(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('The room is about to start'),
                          backgroundColor: ColorManager.warning,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      NotificationManager.requestIOSPermissions();
                      cubit.setNotification(
                        widget.room.id!,
                        widget.room,
                        Constants.phone == widget.room.createdBy!['phone'],
                      );
                    }
                  }
                },
                icon: Icon(
                  _hasNotification
                      ? Icons.alarm_on_outlined
                      : Icons.alarm_add_outlined,
                ),
              ),
            ],
          ),
          body: RoomLayout(
            widget.room,
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
                  itemCount: widget.room.invitedSpeakers!.length,
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
                                widget.room.invitedSpeakers![index]['phone']
                            ? '${AuthCubit.get(context).user!.name} (Me)'
                            : widget.room.invitedSpeakers![index]['name'],
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    );
                  },
                ),
              ],
            ),
            ImageAssets.upcomingRoomImage,
          ),
          bottomSheet: RoomBottomSheet(
            ConditionalBuilder(
              condition: Constants.phone == widget.room.createdBy!['phone'],
              builder: (context) {
                return ElevatedButton.icon(
                  onPressed: () {
                    if (widget.room.dateTime!
                        .toDate()
                        .subtract(const Duration(minutes: 10))
                        .isAfter(DateTime.now())) {
                      showConfirmDialog(
                        context: context,
                        title: 'start room now ?',
                        desc: 'it isn\'t the room time yet',
                        headerIcon: Icons.warning,
                        confirmHandler: () {
                          cubit.startRoom(widget.room.id!);
                        },
                        cancelHandler: () {},
                        state: States.warning,
                      );
                    } else {
                      cubit.startRoom(widget.room.id!);
                    }
                  },
                  icon: const Icon(CupertinoIcons.mic_circle_fill),
                  label: const Text('Start The Room'),
                  style: ElevatedButton.styleFrom(
                    primary: ColorManager.success,
                  ),
                );
              },
              fallback: (context) {
                var dateTime = widget.room.dateTime!.toDate();
                var formattedDateTime =
                    DateFormat('dd MMM, hh:mm a').format(dateTime);

                return Column(
                  children: [
                    Text(
                      'Room is scheduled to start on',
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
                          .copyWith(color: ColorManager.success),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
