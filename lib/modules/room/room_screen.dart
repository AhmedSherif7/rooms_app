import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:room_app/models/room_model.dart';
import 'package:room_app/modules/ongoing_rooms/ongoing_room_screen.dart';
import 'package:room_app/modules/upcoming_rooms/upcoming_room_screen.dart';

import '../finished_rooms/finished_room_screen.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen(this.id, {Key? key}) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('rooms').doc(id).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          var room =
              RoomModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
          if (room.status == 'upcoming') {
            return UpcomingRoomScreen(room);
          } else if (room.status == 'ongoing') {
            return OnGoingRoomScreen(room);
          } else if (room.status == 'finished') {
            return FinishedRoomScreen(room);
          } else {
            return Scaffold(
              appBar: AppBar(),
              body: null,
            );
          }
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
