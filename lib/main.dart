import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_app/database/local/cache_helper.dart';
import 'package:room_app/layout/home_layout.dart';
import 'package:room_app/models/user_model.dart';
import 'package:room_app/modules/auth/auth_screen.dart';
import 'package:room_app/shared/cubit/bloc_observer.dart';
import 'package:room_app/shared/cubit/cubit.dart';
import 'package:room_app/shared/cubit/states.dart';
import 'package:room_app/shared/resources/notifications_manager.dart';
import 'package:room_app/shared/resources/themes_manager.dart';

import 'modules/auth/cubit/auth_cubit.dart';
import 'modules/onboard/onboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await CacheHelper.init();
  BlocOverrides.runZoned(
    () {
      AuthCubit();
      AppCubit();
      runApp(const RoomApp());
    },
    blocObserver: MyBlocObserver(),
  );
}

class RoomApp extends StatelessWidget {
  const RoomApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NotificationManager.initializeNotification(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (BuildContext context) => AuthCubit(),
        ),
        BlocProvider<AppCubit>(
          create: (BuildContext context) => AppCubit(),
        ),
      ],
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          if (AuthCubit.get(context).checkUserLogged()) {
            AuthCubit.get(context).getUserData();
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Room App',
            theme: ThemeManager.light,
            darkTheme: ThemeManager.dark,
            themeMode: AppCubit.get(context).isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: AuthCubit.get(context).checkUserLogged()
                ? const HomeLayout()
                : AppCubit.get(context).onBoardScreen
                    ? const AuthScreen()
                    : const OnBoardingScreen(),
          );
        },
      ),
    );
  }
}
