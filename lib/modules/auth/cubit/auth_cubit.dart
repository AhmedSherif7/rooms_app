import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_app/models/user_model.dart';
import 'package:room_app/shared/constants.dart';
import 'package:room_app/shared/resources/notifications_manager.dart';

import '../../../database/local/cache_helper.dart';
import 'auth_states.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(AuthInitialState());

  static AuthCubit get(BuildContext context) => BlocProvider.of(context);

  UserModel? user;
  String? verificationCode;

  void verifyPhoneNumber(String phoneNumber) {
    emit(AuthVerifyPhoneLoadingState());
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        emit(AuthVerifyPhoneSuccessState());
      },
      verificationFailed: (FirebaseAuthException e) {
        emit(AuthVerifyPhoneErrorState(e.message.toString()));
      },
      codeSent: (String verificationId, int? resendToken) {
        verificationCode = verificationId;
        emit(AuthVerifyPhoneCodeSentState());
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        verificationCode = verificationId;
        emit(AuthVerifyPhoneCodeSentState());
      },
      timeout: const Duration(seconds: 120),
    );
  }

  void login(String sms, String countryCode, String number) {
    emit(AuthLoadingState());

    FirebaseAuth.instance
        .signInWithCredential(
      PhoneAuthProvider.credential(
        verificationId: verificationCode!,
        smsCode: sms,
      ),
    )
        .then((userData) async {
      var isUserExist = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: countryCode + number)
          .get();

      // check if it is a new user or not
      if (isUserExist.docs.isNotEmpty) {
        var userData = isUserExist.docs.first.data();
        user = UserModel.fromJson(userData);
      } else {
        user = UserModel(
          uid: userData.user!.uid,
          name: '',
          phone: userData.user!.phoneNumber,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userData.user!.uid)
            .set(user!.toMap());
      }
      Constants.uid = user!.uid;
      Constants.name = user!.name;
      Constants.phone = user!.phone;
      await CacheHelper.saveUserId(user!.uid!);
      NotificationManager.getNotifications();
      emit(AuthLoginSuccessState());
    }).catchError((error) {
      emit(AuthWrongOtpState('Invalid verification code'));
    });
  }

  void getUserData() {
    emit(AuthGetUserDataLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(CacheHelper.getUserId())
        .get()
        .then((value) async {
      user = UserModel.fromJson(value.data() as Map<String, dynamic>);
      Constants.uid = user!.uid;
      Constants.name = user!.name;
      Constants.phone = user!.phone;
      NotificationManager.getNotifications();
      emit(AuthGetUserDataSuccessState());
    });
  }

  bool checkUserLogged() {
    return CacheHelper.getUserId() != null;
  }

  void setUserName(String name) {
    emit(AuthSetUserNameLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid!)
        .update({'name': name}).then((value) {
      getUserData();
    });
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    await CacheHelper.removeData('uid');
    verificationCode = null;
    user = null;
    Constants.uid = null;
    Constants.name = null;
    Constants.phone = null;
    NotificationManager.cancelAllNotifications();
    emit(AuthLogoutSuccessState());
  }
}
