part of 'login_cubit.dart';

enum LoginStatus { initial, loading, success, failure }

final class LoginState extends Equatable {
  final LoginStatus status;
  final bool obscurePassword;
  final bool rememberMe;
  final String? errorMessage;
  final SignInEntity? entity;

  const LoginState({
    this.status = LoginStatus.initial,
    this.obscurePassword = true,
    this.rememberMe = false,
    this.errorMessage,
    this.entity,
  });

  LoginState copyWith({
    LoginStatus? status,
    bool? obscurePassword,
    bool? rememberMe,
    String? errorMessage,
    SignInEntity? entity,
  }) {
    return LoginState(
      status: status ?? this.status,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberMe: rememberMe ?? this.rememberMe,
      errorMessage: errorMessage ?? this.errorMessage,
      entity: entity ?? this.entity,
    );
  }

  @override
  List<Object?> get props => [
    status,
    obscurePassword,
    rememberMe,
    errorMessage,
    entity,
  ];
}
