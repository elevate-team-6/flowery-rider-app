// part of 'login_cubit.dart';

sealed class LoginSideEffect {
  const LoginSideEffect();
}

class ShowLoadingEffect extends LoginSideEffect {
  const ShowLoadingEffect();
}

class HideLoadingEffect extends LoginSideEffect {
  const HideLoadingEffect();
}

class LoginSuccessEffect extends LoginSideEffect {
  const LoginSuccessEffect();
}

class LoginFailureEffect extends LoginSideEffect {
  final String? message;

  const LoginFailureEffect(this.message);
}
