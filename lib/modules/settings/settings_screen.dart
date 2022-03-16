import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_app/modules/auth/cubit/auth_cubit.dart';
import 'package:room_app/modules/auth/cubit/auth_states.dart';
import 'package:room_app/shared/components/custom_switch.dart';
import 'package:room_app/shared/components/custom_text_field.dart';
import 'package:room_app/shared/constants.dart';
import 'package:room_app/shared/helper_functions.dart';
import 'package:room_app/shared/resources/values_manager.dart';

import '../../shared/cubit/cubit.dart';
import '../../shared/resources/color_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _nameController.text = Constants.name!;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is AuthGetUserDataSuccessState) {
          showToast(
            message: 'Data Saved',
            state: States.success,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.p16),
              child: Column(
                children: [
                  Text(
                    'Edit your name',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  const SizedBox(
                    height: AppSize.s20,
                  ),
                  Form(
                    key: _formKey,
                    child: CustomTextField(
                      keyboardType: TextInputType.name,
                      controller: _nameController,
                      hintText: 'Name',
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'name can not be empty';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: AppSize.s20,
                  ),
                  Text(
                    'Edit your theme',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  const SizedBox(
                    height: AppSize.s10,
                  ),
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
                  const SizedBox(
                    height: AppSize.s40,
                  ),
                  ConditionalBuilder(
                    condition: state is AuthSetUserNameLoadingState ||
                        state is AuthGetUserDataLoadingState,
                    builder: (context) {
                      return const CircularProgressIndicator();
                    },
                    fallback: (context) {
                      return SizedBox(
                        width: AppSize.deviceWidth,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              FocusScope.of(context).unfocus();
                              AuthCubit.get(context)
                                  .setUserName(_nameController.text.trim());
                            }
                          },
                          child: const Text('SAVE'),
                        ),
                      );
                    },
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
