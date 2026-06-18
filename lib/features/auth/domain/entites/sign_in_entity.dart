import 'package:equatable/equatable.dart';

class SignInEntity extends Equatable {
  final String? message;
  final String? token;

  const SignInEntity({this.message, this.token});

  @override
  List<Object?> get props => [message, token];
}
