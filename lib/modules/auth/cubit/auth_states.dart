abstract class AuthStates {}

class AuthInitialState extends AuthStates {}

class AuthVerifyPhoneLoadingState extends AuthStates {}

class AuthVerifyPhoneSuccessState extends AuthStates {}

class AuthVerifyPhoneCodeSentState extends AuthStates {}

class AuthVerifyPhoneErrorState extends AuthStates {
  final String error;

  AuthVerifyPhoneErrorState(this.error);
}

class AuthLoadingState extends AuthStates {}

class AuthWrongOtpState extends AuthStates {
  final String error;

  AuthWrongOtpState(this.error);
}

class AuthLoginSuccessState extends AuthStates {}

class AuthLogoutSuccessState extends AuthStates {}

class AuthGetUserDataLoadingState extends AuthStates {}

class AuthGetUserDataSuccessState extends AuthStates {}

class AuthSetUserNameLoadingState extends AuthStates {}
