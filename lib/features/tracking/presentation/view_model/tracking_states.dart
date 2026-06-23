import 'package:equatable/equatable.dart';

import '../../../../config/base_state/base_state.dart';
import '../../domain/entities/order_entity.dart';

class TrackingStates extends Equatable {
  final BaseState<PendingOrdersEntity> pendingOrdersState;

  const TrackingStates({this.pendingOrdersState = const BaseState()});

  TrackingStates copyWith({
    BaseState<PendingOrdersEntity>? pendingOrdersState,
  }) {
    return TrackingStates(
      pendingOrdersState: pendingOrdersState ?? this.pendingOrdersState,
    );
  }

  @override
  List<Object?> get props => [pendingOrdersState];
}
