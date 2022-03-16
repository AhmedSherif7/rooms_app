import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_app/modules/auth/cubit/auth_cubit.dart';
import 'package:room_app/modules/auth/cubit/auth_states.dart';
import 'package:room_app/modules/user_name_empty/username_empty_screen.dart';

import '../../layout/home_layout.dart';
import '../../shared/components/custom_text_field.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/helper_functions.dart';
import '../../shared/resources/color_manager.dart';
import '../../shared/resources/font_manager.dart';
import '../../shared/resources/values_manager.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _countryCode = '+20';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);

    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is AuthVerifyPhoneErrorState) {
          showToast(message: state.error, state: States.error);
        }
        if (state is AuthWrongOtpState) {
          showToast(message: state.error, state: States.error);
        }

        if (state is AuthLoginSuccessState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AuthCubit.get(context).user!.name == ''
                  ? const UserNameEmptyScreen()
                  : const HomeLayout(),
            ),
          );
        }
      },
      builder: (context, state) {
        var loginCubit = AuthCubit.get(context);
        var appCubit = AppCubit.get(context);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: ColorManager.primary,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: ColorManager.primary,
              statusBarIconBrightness: Brightness.dark,
            ),
          ),
          body: SafeArea(
            child: Container(
              width: AppSize.deviceWidth,
              color: ColorManager.primary,
              child: Column(
                children: [
                  Container(
                    height: AppSize.s150,
                    padding: const EdgeInsets.only(top: AppPadding.p40),
                    child: Text(
                      'Rooms App',
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                            color: Colors.black,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: appCubit.isDarkMode
                            ? ColorManager.black
                            : ColorManager.lightBackground,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppSize.s60),
                          topRight: Radius.circular(AppSize.s60),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(AppPadding.p20),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: AppSize.s40,
                              ),
                              const Icon(
                                Icons.connect_without_contact,
                                size: AppSize.s60,
                                color: ColorManager.primary,
                              ),
                              const SizedBox(
                                height: AppSize.s12,
                              ),
                              Text(
                                'Login with Phone',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              const SizedBox(
                                height: AppSize.s35,
                              ),
                              ConditionalBuilder(
                                condition: loginCubit.verificationCode == null,
                                builder: (context) => Form(
                                  key: _phoneKey,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CountryCodePicker(
                                          dialogTextStyle: TextStyle(
                                            color: appCubit.isDarkMode
                                                ? ColorManager.white
                                                : ColorManager.black,
                                          ),
                                          dialogBackgroundColor: appCubit
                                                  .isDarkMode
                                              ? ColorManager.darkGrey
                                              : ColorManager.lightBackground,
                                          onChanged: (e) =>
                                              _countryCode = e.code!,
                                          initialSelection: 'EG',
                                          favorite: const ['+20', 'EG'],
                                          showCountryOnly: false,
                                          showOnlyCountryWhenClosed: false,
                                          alignLeft: false,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: CustomTextField(
                                          keyboardType: TextInputType.phone,
                                          controller: _phoneController,
                                          labelText: 'Phone',
                                          validator: (String? value) {
                                            bool isNumber =
                                                int.tryParse(value!) != null;
                                            if (value.trim().isEmpty) {
                                              return 'phone can not be empty';
                                            } else if (!isNumber) {
                                              return 'numbers only';
                                            } else if (value.trim().length <
                                                10) {
                                              return 'too short';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                fallback: (context) => Form(
                                  key: _otpKey,
                                  child: CustomTextField(
                                    keyboardType: TextInputType.number,
                                    controller: _otpController,
                                    labelText: 'OTP',
                                    hintText: 'OTP you got',
                                    validator: (String? value) {
                                      bool isNumber =
                                          int.tryParse(value!) != null;
                                      if (value.trim().isEmpty) {
                                        return 'otp can not be empty';
                                      } else if (!isNumber) {
                                        return 'numbers only';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: AppSize.s50,
                              ),
                              ConditionalBuilder(
                                condition:
                                    state is AuthVerifyPhoneLoadingState ||
                                        state is AuthLoadingState,
                                builder: (context) =>
                                    const CircularProgressIndicator(),
                                fallback: (context) => SizedBox(
                                  width: AppSize.deviceWidth,
                                  child: ElevatedButton(
                                    onPressed: loginCubit.verificationCode ==
                                            null
                                        ? () {
                                            FocusScope.of(context).unfocus();
                                            if (_phoneKey.currentState!
                                                .validate()) {
                                              var phoneNumber = _countryCode +
                                                  _phoneController.text.trim();
                                              loginCubit.verifyPhoneNumber(
                                                  phoneNumber);
                                            }
                                          }
                                        : () {
                                            FocusScope.of(context).unfocus();
                                            if (_otpKey.currentState!
                                                .validate()) {
                                              loginCubit.login(
                                                _otpController.text,
                                                _countryCode,
                                                _phoneController.text.trim(),
                                              );
                                            }
                                          },
                                    child: Text(
                                      loginCubit.verificationCode != null
                                          ? 'LOGIN'
                                          : 'GET OTP',
                                      style: const TextStyle(
                                        fontSize: FontSize.s20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
