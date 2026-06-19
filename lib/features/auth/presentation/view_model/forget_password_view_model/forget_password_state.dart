import 'package:equatable/equatable.dart';

import '../../../../../config/base_state/base_state.dart';
import '../../../domain/entities/forget_password_entity.dart';

class ForgetPasswordState extends Equatable {
  final BaseState<ForgetPasswordEntity> forgotPasswordState;
  final BaseState<ForgetPasswordEntity> verifyResetCodeState;
  final BaseState<ForgetPasswordEntity> resetPasswordState;

  const ForgetPasswordState({
    this.forgotPasswordState = const BaseState(),
    this.verifyResetCodeState = const BaseState(),
    this.resetPasswordState = const BaseState(),
  });

  ForgetPasswordState copyWith({
    BaseState<ForgetPasswordEntity>? forgotPasswordState,
    BaseState<ForgetPasswordEntity>? verifyResetCodeState,
    BaseState<ForgetPasswordEntity>? resetPasswordState,
  }) {
    return ForgetPasswordState(
      forgotPasswordState: forgotPasswordState ?? this.forgotPasswordState,
      verifyResetCodeState: verifyResetCodeState ?? this.verifyResetCodeState,
      resetPasswordState: resetPasswordState ?? this.resetPasswordState,
    );
  }

  @override
  List<Object?> get props => [
    forgotPasswordState,
    verifyResetCodeState,
    resetPasswordState,
  ];
}
