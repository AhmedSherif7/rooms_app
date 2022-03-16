import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_app/modules/auth/cubit/auth_cubit.dart';
import 'package:room_app/modules/finished_rooms/finished_rooms.dart';
import 'package:room_app/modules/settings/settings_screen.dart';
import 'package:room_app/shared/cubit/states.dart';

import '../modules/auth/auth_screen.dart';
import '../modules/create_room/create_room_screen.dart';
import '../modules/ongoing_rooms/ongoing_rooms.dart';
import '../modules/upcoming_rooms/upcoming_rooms.dart';
import '../shared/cubit/cubit.dart';
import '../shared/helper_functions.dart';
import '../shared/resources/color_manager.dart';
import '../shared/resources/values_manager.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with TickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    _controller = TabController(
      length: 3,
      initialIndex: AppCubit.get(context).pageIndex,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Rooms',
            ),
            bottom: TabBar(
              indicatorColor: Theme.of(context).primaryColor,
              onTap: AppCubit.get(context).changePageIndex,
              controller: _controller,
              tabs: [
                Tab(
                  child: Text(
                    'Live',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  icon: Icon(
                    Icons.online_prediction_outlined,
                    color: AppCubit.get(context).isDarkMode
                        ? ColorManager.white
                        : ColorManager.black,
                  ),
                ),
                Tab(
                  child: Text(
                    'Upcoming',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  icon: Icon(
                    Icons.pending_actions_outlined,
                    color: AppCubit.get(context).isDarkMode
                        ? ColorManager.white
                        : ColorManager.black,
                  ),
                ),
                Tab(
                  child: Text(
                    'Finished',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  icon: Icon(
                    Icons.offline_pin_outlined,
                    color: AppCubit.get(context).isDarkMode
                        ? ColorManager.white
                        : ColorManager.black,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  showConfirmDialog(
                    context: context,
                    title: 'Do you want to log out ?',
                    desc: '',
                    headerIcon: Icons.warning,
                    confirmHandler: () {
                      AuthCubit.get(context).signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                      );
                    },
                    cancelHandler: () {},
                    state: States.warning,
                  );
                },
                icon: const Icon(
                  Icons.power_settings_new_outlined,
                  color: ColorManager.error,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.settings,
                ),
              ),
            ],
          ),
          body: TabBarView(
            controller: _controller,
            children: const [
              OnGoingRooms(),
              UpcomingRooms(),
              FinishedRooms(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateRoomScreen(),
                ),
              ).then((value) {
                if (value != null) {
                  showToast(message: value, state: States.success);
                }
              });
            },
            child: const Icon(Icons.add),
            backgroundColor: ColorManager.success,
          ),
        );
      },
    );
  }
}
