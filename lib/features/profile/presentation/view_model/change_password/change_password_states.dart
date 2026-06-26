import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';

class ChangePasswordState extends Equatable {
  final BaseState<void> changePasswordState;

  const ChangePasswordState({this.changePasswordState = const BaseState()});

  ChangePasswordState copyWith({BaseState<void>? changePasswordState}) {
    return ChangePasswordState(
      changePasswordState: changePasswordState ?? this.changePasswordState,
    );
  }

  @override
  List<Object?> get props => [changePasswordState];
}
