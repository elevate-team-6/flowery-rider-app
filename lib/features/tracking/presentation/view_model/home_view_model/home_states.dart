import 'package:equatable/equatable.dart';

import '../../../../../config/base_state/base_state.dart';
import '../../../domain/entities/order_entity.dart';

class HomeStates extends Equatable {
  final BaseState<PendingOrdersEntity> pendingOrdersState;

  final String? rejectingOrderId;

  const HomeStates({
    this.pendingOrdersState = const BaseState(),
    this.rejectingOrderId,
  });

  HomeStates copyWith({
    BaseState<PendingOrdersEntity>? pendingOrdersState,
    String? rejectingOrderId,
    bool clearRejectingOrderId = false,
  }) {
    return HomeStates(
      pendingOrdersState: pendingOrdersState ?? this.pendingOrdersState,
      rejectingOrderId: clearRejectingOrderId
          ? null
          : (rejectingOrderId ?? this.rejectingOrderId),
    );
  }

  @override
  List<Object?> get props => [pendingOrdersState, rejectingOrderId];
}
