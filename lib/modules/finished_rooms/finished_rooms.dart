import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:room_app/modules/room/room_screen.dart';

import '../../models/room_model.dart';
import '../../shared/constants.dart';
import '../../shared/helper_functions.dart';
import '../../shared/resources/values_manager.dart';

class FinishedRooms extends StatefulWidget {
  const FinishedRooms({Key? key}) : super(key: key);

  @override
  State<FinishedRooms> createState() => _FinishedRoomsState();
}

class _FinishedRoomsState extends State<FinishedRooms> {
  // String createdByName = '';

  @override
  // void initState() {
  //   getCreatedByName();
  //   super.initState();
  // }

  // Future<void> getCreatedByName() async {
  //   var res = await FirebaseFirestore.instance
  //       .collection('users')
  //       .where('phone', isEqualTo: Constants.phone)
  //       .get();
  //   var user = UserModel.fromJson(res.docs.first.data());
  //   setState(() {
  //     createdByName = user.name!;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('rooms')
          .where('status', isEqualTo: 'finished')
          .where(
            'endedAt',
            isGreaterThan: DateTime.now().subtract(const Duration(days: 2)),
          )
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: AppSize.s100,
                ),
                Text(
                  'No Finished Rooms',
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
                    'Finished',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  const SizedBox(
                    height: AppSize.s10,
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      RoomModel room = RoomModel.fromJson(
                        rooms[index].data() as Map<String, dynamic>,
                      );

                      var dateTime = room.endedAt!.toDate();
                      var formattedTime =
                          DateFormat('dd MMM, hh:mm a').format(dateTime);

                      var duration = room.endedAt!
                          .toDate()
                          .difference(room.startedAt!.toDate());

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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.watch_later_outlined),
                                    const SizedBox(
                                      width: AppSize.s20,
                                    ),
                                    Text(
                                      getFormattedDuration(duration),
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: AppSize.s15,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.person),
                                    const SizedBox(
                                      width: AppSize.s20,
                                    ),
                                    Text(
                                      '${room.createdBy!['name']} ${room.createdBy!['phone'] == Constants.phone ? '(Me)' : ''}',
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
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
