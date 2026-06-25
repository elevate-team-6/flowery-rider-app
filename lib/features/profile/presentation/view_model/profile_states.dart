import 'package:equatable/equatable.dart';

import '../../../../config/base_state/base_state.dart';

class ProfileStates extends Equatable {
  final BaseState<void> logoutState;

  const ProfileStates({this.logoutState = const BaseState()});

  ProfileStates copyWith({BaseState<void>? logoutState}) {
    return ProfileStates(logoutState: logoutState ?? this.logoutState);
  }

  @override
  List<Object?> get props => [logoutState];
}
