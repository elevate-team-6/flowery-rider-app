import 'package:equatable/equatable.dart';

import '../../../../config/base_state/base_state.dart';

class TrackingStates extends Equatable {
  const TrackingStates();

  TrackingStates copyWith({BaseState<void>? logoutState}) {
    return TrackingStates();
  }

  @override
  List<Object?> get props => [];
}
