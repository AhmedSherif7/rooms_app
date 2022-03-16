import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../layout/home_layout.dart';
import '../../shared/components/custom_text_field.dart';
import '../../shared/resources/color_manager.dart';
import '../../shared/resources/values_manager.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_states.dart';

class UserNameEmptyScreen extends StatefulWidget {
  const UserNameEmptyScreen({Key? key}) : super(key: key);

  @override
  State<UserNameEmptyScreen> createState() => _UserNameEmptyScreenState();
}

class _UserNameEmptyScreenState extends State<UserNameEmptyScreen> {
  final _nameController = TextEditingController();

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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeLayout(),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.all(AppPadding.p20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter your name to continue',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                const SizedBox(
                  height: AppSize.s20,
                ),
                CustomTextField(
                  keyboardType: TextInputType.name,
                  hintText: 'Name',
                  controller: _nameController,
                  validator: (String? value) {
                    return null;
                  },
                ),
                const SizedBox(
                  height: AppSize.s30,
                ),
                state is AuthSetUserNameLoadingState ||
                        state is AuthGetUserDataLoadingState
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (_nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Name can not be empty'),
                                backgroundColor: ColorManager.error,
                              ),
                            );
                          } else {
                            FocusScope.of(context).unfocus();
                            AuthCubit.get(context)
                                .setUserName(_nameController.text.trim());
                          }
                        },
                        child: const Text('CONTINUE'),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
