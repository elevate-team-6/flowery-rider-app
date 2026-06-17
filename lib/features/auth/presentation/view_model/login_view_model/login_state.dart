import 'package:equatable/equatable.dart';

final class LoginState extends Equatable {
  final bool obscurePassword;
  final bool rememberMe;

  const LoginState({this.obscurePassword = true, this.rememberMe = false});

  LoginState copyWith({bool? obscurePassword, bool? rememberMe}) {
    return LoginState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  @override
  List<Object?> get props => [obscurePassword, rememberMe];
}
