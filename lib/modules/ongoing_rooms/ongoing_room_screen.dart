import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:room_app/shared/components/room_layout.dart';
import 'package:room_app/shared/constants.dart';
import 'package:room_app/shared/resources/assets_manager.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../../models/room_model.dart';
import '../../shared/components/room_bottom_sheet.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
import '../../shared/helper_functions.dart';
import '../../shared/resources/color_manager.dart';
import '../../shared/resources/values_manager.dart';

class OnGoingRoomScreen extends StatefulWidget {
  const OnGoingRoomScreen(this.room, {Key? key}) : super(key: key);

  final RoomModel room;

  @override
  State<OnGoingRoomScreen> createState() => _OnGoingRoomScreenState();
}

class _OnGoingRoomScreenState extends State<OnGoingRoomScreen> {
  late StopWatchTimer _stopWatchTimer;
  late Duration _duration;
  late bool _isSpeaker;
  final List _users = [];
  final _infoStrings = [];
  late RtcEngine _engine;
  late ClientRole _clientRole;
  var temp = {
    'micMuted': true,
  };

  Future<void> initializeAgora() async {
    var status = await Permission.microphone.status;
    if (status != PermissionStatus.granted) {
      await Permission.microphone.request();
    }
    await _initAgoraRtcEngine();

    _addAgoraEventHandlers();

    await _engine.joinChannel(
      null,
      widget.room.id!,
      null,
      0,
    );
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine =
        await RtcEngine.createWithContext(RtcEngineContext(Constants.agoraId));
    await _engine.enableAudio();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(_clientRole);
    await _engine.muteLocalAudioStream(true);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(
      RtcEngineEventHandler(
        error: (code) {
          setState(() {
            final info = 'onError: $code';
            _infoStrings.add(info);
          });
        },
        joinChannelSuccess: (channel, uid, elapsed) async {
          setState(() {
            final info = 'onJoinChannel: $channel, uid: $uid';
            _infoStrings.add(info);
            // localUid = uid;
            // _allUsers.putIfAbsent(uid, () => widget.userName);
          });
          // if (widget.role == ClientRole.Broadcaster) {
          //   setState(() {
          //     _users.add(uid);
          //   });
          // }
        },
        leaveChannel: (stats) async {
          setState(() {
            _infoStrings.add('onLeaveChannel');
            _users.clear();
            // _allUsers.remove(localUid);
          });
        },
        userJoined: (uid, elapsed) {
          setState(() {
            final info = 'userJoined: $uid';
            _infoStrings.add(info);
            _users.add(uid);
          });
        },
        userOffline: (uid, reason) {
          setState(() {
            final info = 'userOffline: $uid , reason: $reason';
            _infoStrings.add(info);
            _users.remove(uid);
          });
        },
      ),
    );
  }

  @override
  void initState() {
    _isSpeaker = widget.room.invitedSpeakers!
        .any((speaker) => speaker['phone'] == Constants.phone);

    if (_isSpeaker) {
      AppCubit.get(context).addSpeaker(widget.room);
    } else {
      AppCubit.get(context).addAudience(widget.room);
    }
    _clientRole = ClientRole.Broadcaster;

    _duration = DateTime.now().difference(widget.room.startedAt!.toDate());

    _stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countUp,
      presetMillisecond:
          StopWatchTimer.getMilliSecFromSecond(_duration.inSeconds),
    );
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);

    initializeAgora();

    super.initState();
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    _engine.destroy();
    super.dispose();
  }

  void showHostLeaveRoomConfirmDialog(String roomId) {
    showConfirmDialog(
      context: context,
      title: 'You are the host, if you left room will ended',
      desc: 'are you sure ?',
      headerIcon: Icons.warning,
      confirmHandler: () {
        AppCubit.get(context).endRoom(roomId);
        Navigator.pop(context);
      },
      cancelHandler: () {},
      state: States.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is AppAddSpeakerSuccessState) {
          _isSpeaker = true;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () async {
                if (widget.room.createdBy!['phone'] == Constants.phone) {
                  showHostLeaveRoomConfirmDialog(widget.room.id!);
                } else {
                  if (_isSpeaker) {
                    Navigator.pop(context);
                    AppCubit.get(context).removeSpeaker(widget.room);
                  } else {
                    Navigator.pop(context);
                    AppCubit.get(context).removeAudience(widget.room);
                  }
                }
              },
              icon: const Icon(Icons.arrow_back),
            ),
            centerTitle: true,
            title: StreamBuilder<int>(
              stream: _stopWatchTimer.rawTime,
              initialData: 0,
              builder: (context, snap) {
                final value = snap.data;
                final displayTime = StopWatchTimer.getDisplayTime(
                  value!,
                  milliSecond: false,
                );
                return Text(
                  displayTime,
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: ColorManager.success),
                );
              },
            ),
            actions: [
              if (widget.room.createdBy!['phone'] == Constants.phone)
                IconButton(
                  onPressed: () {
                    showConfirmDialog(
                      context: context,
                      title: 'End The Room',
                      desc: 'are you sure ?',
                      headerIcon: Icons.warning,
                      confirmHandler: () =>
                          AppCubit.get(context).endRoom(widget.room.id!),
                      cancelHandler: () {},
                      state: States.error,
                    );
                  },
                  icon: const CircleAvatar(
                    backgroundColor: ColorManager.error,
                    child: Icon(
                      Icons.power_settings_new_outlined,
                      color: ColorManager.white,
                    ),
                  ),
                ),
            ],
          ),
          body: WillPopScope(
            onWillPop: () async {
              if (widget.room.createdBy!['phone'] == Constants.phone) {
                showHostLeaveRoomConfirmDialog(widget.room.id!);
              } else {
                if (_isSpeaker) {
                  AppCubit.get(context).removeSpeaker(widget.room);
                } else {
                  AppCubit.get(context).removeAudience(widget.room);
                }
              }
              return true;
            },
            child: RoomLayout(
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
                        'Speakers',
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
                    itemCount: widget.room.speakers!.length,
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
                          Constants.phone ==
                                  widget.room.speakers![index]['phone']
                              ? '${Constants.name} (Me)'
                              : widget.room.speakers![index]['name'],
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        trailing: widget.room.speakers![index]['micMuted']
                            ? const Icon(Icons.mic_off)
                            : const Icon(
                                Icons.mic,
                                color: ColorManager.success,
                              ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: AppSize.s30,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(),
                      ),
                      const SizedBox(
                        width: AppSize.s4,
                      ),
                      Text(
                        'Listeners',
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
                    itemCount: widget.room.audience!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: ColorManager.blueAccent,
                          child: Icon(
                            Icons.person,
                            color: ColorManager.white,
                          ),
                        ),
                        title: Text(
                          Constants.phone ==
                                  widget.room.audience![index]['phone']
                              ? '${Constants.name} (Me)'
                              : widget.room.audience![index]['name'],
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      );
                    },
                  ),
                ],
              ),
              ImageAssets.ongoingRoomImage,
            ),
          ),
          bottomSheet: RoomBottomSheet(
            ConditionalBuilder(
              condition: Constants.phone == widget.room.createdBy!['phone'] || _isSpeaker,
              builder: (context) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (widget.room.createdBy!['phone'] == Constants.phone) {
                          showHostLeaveRoomConfirmDialog(widget.room.id!);
                        } else {
                          AppCubit.get(context).removeSpeaker(widget.room);
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Leave'),
                      style: ElevatedButton.styleFrom(
                        primary: ColorManager.warning,
                      ),
                    ),
                    RawMaterialButton(
                      onPressed: () {
                        var speaker = widget.room.speakers!.firstWhere(
                            (speaker) => speaker['phone'] == Constants.phone);
                        _engine.muteLocalAudioStream(!speaker['micMuted']);
                        AppCubit.get(context).toggleSpeakerMic(widget.room);
                      },
                      child: Icon(
                        widget.room.speakers!.firstWhere(
                                (speaker) =>
                                    speaker['phone'] == Constants.phone,
                                orElse: () => temp)['micMuted']
                            ? Icons.mic_off
                            : Icons.mic,
                        color: widget.room.speakers!.firstWhere(
                                (speaker) =>
                                    speaker['phone'] == Constants.phone,
                                orElse: () => temp)['micMuted']
                            ? ColorManager.white
                            : ColorManager.blueAccent,
                        size: AppSize.s20,
                      ),
                      shape: const CircleBorder(),
                      elevation: AppSize.s2,
                      fillColor: widget.room.speakers!.firstWhere(
                              (speaker) => speaker['phone'] == Constants.phone,
                              orElse: () => temp)['micMuted']
                          ? ColorManager.blueAccent
                          : ColorManager.white,
                      padding: const EdgeInsets.all(AppPadding.p12),
                    ),
                  ],
                );
              },
              fallback: (context) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        AppCubit.get(context).removeAudience(widget.room);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Leave'),
                      style: ElevatedButton.styleFrom(
                        primary: ColorManager.warning,
                      ),
                    ),
                    if (widget.room.type == 'public')
                      ElevatedButton.icon(
                        onPressed: () {
                          AppCubit.get(context).removeAudience(widget.room);
                          AppCubit.get(context).addSpeaker(widget.room);
                        },
                        icon: const Icon(CupertinoIcons.hand_raised),
                        label: const Text('Join Discussion'),
                        style: ElevatedButton.styleFrom(
                          primary: ColorManager.blueAccent,
                        ),
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
