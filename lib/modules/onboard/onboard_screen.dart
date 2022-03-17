import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/components/custom_switch.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';
import '../../shared/resources/assets_manager.dart';
import '../../shared/resources/color_manager.dart';
import '../../shared/resources/values_manager.dart';
import '../auth/auth_screen.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.p20,
              ),
              width: AppSize.deviceWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: AppSize.s40,
                  ),
                  Text(
                    'Welcome to Rooms App',
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                  Image(
                    image: const AssetImage(ImageAssets.onboardingImage),
                    fit: BoxFit.cover,
                    height: AppSize.s300,
                    width: AppSize.deviceWidth,
                  ),
                  Text(
                    'Choose your theme',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  const SizedBox(
                    height: AppSize.s10,
                  ),
                  Text(
                    'you can change it later',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  const SizedBox(
                    height: AppSize.s24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSwitch(
                        enabledText: 'Dark',
                        disabledText: 'Light',
                        activeIcon: Icons.nights_stay_outlined,
                        inActiveIcon: Icons.wb_sunny,
                        activeColor: ColorManager.lightGrey,
                        inActiveColor: ColorManager.darkGrey,
                        value: AppCubit.get(context).isDarkMode,
                        onToggle: AppCubit.get(context).toggleThemeMode,
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: AppSize.deviceWidth,
                    child: ElevatedButton(
                      onPressed: () {
                        AppCubit.get(context).setOnBoardScreenWatched();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthScreen(),
                          ),
                        );
                      },
                      child: const Text('GET STARTED'),
                    ),
                  ),
                  const SizedBox(
                    height: AppSize.s30,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
