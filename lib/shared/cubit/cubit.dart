import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_app/database/local/cache_helper.dart';
import 'package:room_app/shared/constants.dart';
import 'package:room_app/shared/cubit/states.dart';
import 'package:room_app/shared/resources/notifications_manager.dart';

import '../../models/room_model.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(BuildContext context) => BlocProvider.of(context);

  bool isDarkMode = CacheHelper.getThemeMode();
  bool onBoardScreen = CacheHelper.getOnBoardScreenStatus();

  void toggleThemeMode(bool value) {
    isDarkMode = value;
    CacheHelper.setThemeMode(value);
    emit(AppToggleThemeModeState());
  }

  void setOnBoardScreenWatched() async {
    await CacheHelper.setOnBoardScreenWatched();
    emit(AppOnBoardScreenWatchedState());
  }

  int pageIndex = 0;

  void changePageIndex(int index) {
    pageIndex = index;
    emit(AppChangePageIndexState());
  }

  void setNotification(String roomId, RoomModel room, bool myRoom) async {
    await NotificationManager.scheduledNotification(
      roomId,
      room.title!,
      room.dateTime!.toDate(),
      myRoom: myRoom,
    );
    FirebaseFirestore.instance
        .collection('users')
        .doc(Constants.uid)
        .collection('notifications')
        .doc(room.id)
        .set({
      'roomId': roomId,
      'roomTitle': room.title,
      'roomDateTime': room.dateTime,
      'myRoom': myRoom,
    }).then((value) async {
      emit(AppSetNotificationSuccessState());
    });
  }

  void cancelNotification(RoomModel room) async {
    await NotificationManager.cancelNotification(room);
    FirebaseFirestore.instance
        .collection('users')
        .doc(Constants.uid)
        .collection('notifications')
        .doc(room.id)
        .delete()
        .then((value) {
      emit(AppCancelNotificationSuccessState());
    });
  }

  List<Map<String, String>> invitedSpeakers = [];

  void inviteSpeaker(String phone) {
    FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        if (!invitedSpeakers.any((element) => element['phone'] == phone)) {
          invitedSpeakers.add({
            'name': value.docs.first.data()['name'],
            'phone': phone,
          });
          emit(AppInviteSpeakerSuccessState());
          print(invitedSpeakers);
        } else {
          emit(AppSpeakerAlreadyInvitedState());
        }
      } else {
        emit(AppUserNotFoundState());
      }
    });
  }

  void unInviteSpeaker(int index) {
    invitedSpeakers.removeAt(index);
    emit(AppUnInviteSpeakerSuccessState());
  }

  void createRoom(
    String title,
    String category,
    DateTime dateTime,
    bool type,
  ) {
    print(Constants.name);
    print(Constants.phone);
    invitedSpeakers.add({
      'name': Constants.name!,
      'phone': Constants.phone!,
    });
    emit(AppCreateRoomLoadingState());
    RoomModel room = RoomModel(
      title: title[0].toUpperCase() + title.substring(1),
      category: category[0].toUpperCase() + category.substring(1),
      createdBy: Constants.phone,
      speakers: [],
      invitedSpeakers: invitedSpeakers,
      audience: [],
      createdOn: Timestamp.now(),
      dateTime: Timestamp.fromDate(dateTime),
      type: type ? 'public' : 'private',
      status: 'upcoming',
    );

    FirebaseFirestore.instance
        .collection('rooms')
        .add(room.toMap())
        .then((doc) {
      doc.update({
        'id': doc.id,
      }).then((value) {
        invitedSpeakers.clear();
        if (room.dateTime!
            .toDate()
            .isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
          setNotification(doc.id, room, true);
        }
        emit(AppCreateRoomSuccessState());
      });
    });
  }

  void startRoom(String roomId) {
    FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
      'status': 'ongoing',
      'startedAt': Timestamp.now(),
    }).then((value) {
      emit(AppStartRoomSuccessState());
    });
  }

  void addSpeaker(RoomModel room) {
    List newSpeakers = room.speakers!;
    newSpeakers.add({
      'name': Constants.name,
      'phone': Constants.phone,
      'micMuted': true,
    });
    FirebaseFirestore.instance.collection('rooms').doc(room.id).update({
      'speakers': newSpeakers,
    }).then((value) {
      newSpeakers.clear();
      emit(AppAddSpeakerSuccessState());
    });
  }

  void addAudience(RoomModel room) {
    List newAudience = room.audience!;
    newAudience.add({
      'name': Constants.name,
      'phone': Constants.phone,
    });
    FirebaseFirestore.instance.collection('rooms').doc(room.id).update({
      'audience': newAudience,
    }).then((value) {
      newAudience.clear();
      emit(AppAddAudienceSuccessState());
    });
  }

  void toggleSpeakerMic(RoomModel room) {
    var newSpeakers = room.speakers!;
    int speakerIndex = newSpeakers
        .indexWhere((speaker) => speaker['phone'] == Constants.phone);
    newSpeakers[speakerIndex]['micMuted'] =
        !newSpeakers[speakerIndex]['micMuted'];
    FirebaseFirestore.instance
        .collection('rooms')
        .doc(room.id)
        .update({'speakers': newSpeakers}).then((value) {
      newSpeakers.clear();
      emit(AppToggleMicSuccessState());
    });
  }

  void removeSpeaker(RoomModel room) {
    List newSpeakers = room.speakers!;
    newSpeakers.removeWhere((speaker) => speaker['phone'] == Constants.phone);
    FirebaseFirestore.instance.collection('rooms').doc(room.id).update({
      'speakers': newSpeakers,
    }).then((value) {
      newSpeakers.clear();
      emit(AppRemoveSpeakerSuccessState());
    });
  }

  void removeAudience(RoomModel room) {
    List newAudience = room.audience!;
    newAudience.removeWhere((audience) => audience['phone'] == Constants.phone);
    FirebaseFirestore.instance.collection('rooms').doc(room.id).update({
      'audience': newAudience,
    }).then((value) {
      newAudience.clear();
      emit(AppRemoveAudienceSuccessState());
    });
  }

  void endRoom(String roomId) {
    FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
      'status': 'finished',
      'audience': null,
      'speakers': null,
      'endedAt': Timestamp.now(),
    }).then((value) {
      emit(AppEndRoomSuccessState());
    });
  }

  void deleteRoom(String roomId) {
    FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
      'status': 'deleted',
      'title': null,
      'category': null,
      'createdOn': null,
      'speakers': null,
      'invitedSpeakers': null,
      'audience': null,
      'dateTime': null,
      'startedAt': null,
      'endedAt': null,
      'type': null,
    }).then((value) {
      emit(AppDeleteRoomSuccessState());
    });
  }
}
