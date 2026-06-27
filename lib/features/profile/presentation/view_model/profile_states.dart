import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/core/entities/driver_entity.dart';

import '../../../../config/base_state/base_state.dart';

class ProfileStates extends Equatable {
  final BaseState<DriverEntity> profileState;
  final BaseState<void> logoutState;

  const ProfileStates({
    this.profileState = const BaseState(),
    this.logoutState = const BaseState(),
  });

  ProfileStates copyWith({
    BaseState<DriverEntity>? profileState,
    BaseState<void>? logoutState,
  }) {
    return ProfileStates(
      profileState: profileState ?? this.profileState,
      logoutState: logoutState ?? this.logoutState,
    );
  }

  @override
  List<Object?> get props => [profileState, logoutState];
}
