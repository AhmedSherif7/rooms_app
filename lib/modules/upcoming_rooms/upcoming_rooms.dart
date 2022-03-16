import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:room_app/modules/auth/cubit/auth_cubit.dart';
import 'package:room_app/modules/room/room_screen.dart';

import '../../models/room_model.dart';
import '../../shared/resources/values_manager.dart';

class UpcomingRooms extends StatelessWidget {
  const UpcomingRooms({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('rooms')
          .where('status', isEqualTo: 'upcoming')
          .where(
            'dateTime',
            isLessThan: DateTime.now().add(const Duration(days: 7)),
          )
          .orderBy('dateTime')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.face_sharp,
                  size: AppSize.s100,
                ),
                Text(
                  'No Upcoming Rooms',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(
                  height: AppSize.s8,
                ),
                Text(
                  'Create your own room',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            );
          }

          var rooms = snapshot.data!.docs;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSize.s16),
              child: Column(
                children: [
                  Text(
                    'Upcoming Week',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  const SizedBox(
                    height: AppSize.s10,
                  ),
                  const Icon(
                    Icons.arrow_circle_down,
                    size: AppSize.s26,
                  ),
                  const SizedBox(
                    height: AppSize.s10,
                  ),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      RoomModel room = RoomModel.fromJson(
                        rooms[index].data() as Map<String, dynamic>,
                      );

                      var dateTime = room.dateTime!.toDate();
                      var formattedTime =
                          DateFormat('dd MMM, hh:mm a').format(dateTime);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoomScreen(room.id!),
                            ),
                          );
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppPadding.p20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.title!,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                                const SizedBox(
                                  height: AppSize.s10,
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.wysiwyg),
                                    const SizedBox(
                                      width: AppSize.s5,
                                    ),
                                    Text(
                                      room.category!,
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                    const SizedBox(
                                      width: AppSize.s20,
                                    ),
                                    const Icon(Icons.calendar_today_rounded),
                                    const SizedBox(
                                      width: AppSize.s5,
                                    ),
                                    Text(
                                      formattedTime,
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: AppSize.s15,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.person),
                                    const SizedBox(
                                      width: AppSize.s20,
                                    ),
                                    Expanded(
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        primary: false,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: room.invitedSpeakers!.length,
                                        itemBuilder: (context, index) {
                                          return Text(
                                            AuthCubit.get(context)
                                                        .user!
                                                        .phone ==
                                                    room.invitedSpeakers![index]
                                                        ['phone']
                                                ? '${AuthCubit.get(context).user!.name} (Me)'
                                                : room.invitedSpeakers![index]
                                                    ['name'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2,
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(
                                            height: AppSize.s5,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        height: AppSize.s10,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
