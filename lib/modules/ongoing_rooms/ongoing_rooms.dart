import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/room_model.dart';
import '../../shared/resources/color_manager.dart';
import '../../shared/resources/values_manager.dart';
import '../room/room_screen.dart';

class OnGoingRooms extends StatelessWidget {
  const OnGoingRooms({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('rooms')
          .where(
            'status',
            isEqualTo: 'ongoing',
          )
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.offline_bolt_outlined,
                  size: AppSize.s100,
                ),
                const SizedBox(
                  height: AppSize.s8,
                ),
                Text(
                  'No Ongoing Rooms Right Now',
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }
          var rooms = snapshot.data!.docs;
          return ListView.separated(
            shrinkWrap: true,
            primary: false,
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              RoomModel room = RoomModel.fromJson(
                rooms[index].data() as Map<String, dynamic>,
              );
              var dateTime =
                  DateTime.parse(room.startedAt!.toDate().toString());
              var formattedTime = DateFormat.jm().format(dateTime);
              return GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomScreen(room.id!),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSize.s12),
                  child: Row(
                    children: [
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          color: ColorManager.success,
                        ),
                      ),
                      const SizedBox(
                        width: AppSize.s20,
                      ),
                      Flexible(
                        child: Text(
                          room.title!,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: AppSize.s20,
                      ),
                      const Icon(
                        Icons.mic,
                        color: ColorManager.error,
                      ),
                      const SizedBox(
                        width: AppSize.s2,
                      ),
                      Text(
                        '${room.speakers!.length}',
                        style: const TextStyle(
                          color: ColorManager.error,
                        ),
                      ),
                      const SizedBox(
                        width: AppSize.s20,
                      ),
                      const Icon(
                        Icons.headphones,
                        color: ColorManager.blueAccent,
                      ),
                      const SizedBox(
                        width: AppSize.s2,
                      ),
                      Text(
                        '${room.audience!.length}',
                        style: const TextStyle(
                          color: ColorManager.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider(
                  // color: ColorManager.dividerColor,
                  );
            },
          );
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
