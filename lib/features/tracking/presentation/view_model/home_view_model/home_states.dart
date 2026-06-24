import 'package:equatable/equatable.dart';

import '../../../../../config/base_state/base_state.dart';
import '../../../domain/entities/order_entity.dart';

class HomeStates extends Equatable {
  final BaseState<PendingOrdersEntity> pendingOrdersState;

  const HomeStates({this.pendingOrdersState = const BaseState()});

  HomeStates copyWith({BaseState<PendingOrdersEntity>? pendingOrdersState}) {
    return HomeStates(
      pendingOrdersState: pendingOrdersState ?? this.pendingOrdersState,
    );
  }

  @override
  List<Object?> get props => [pendingOrdersState];
}
