import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_pending_orders_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/order_details_screen.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/home_view_model/home_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/home_view_model/home_states.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeCubit extends BaseCubit<HomeStates, BaseUiEvent> {
  final GetPendingOrdersUseCase _getPendingOrdersUseCase;

  HomeCubit(this._getPendingOrdersUseCase) : super(const HomeStates());

  Future<void> doEvent(HomeEvents event) async {
    switch (event) {
      case GetPendingOrdersEvent():
        await _getPendingOrders(event.page);
      case AcceptOrderEvent():
        _acceptOrder(event.order);
      case RejectOrderEvent():
        await _rejectOrder(event.orderId);
    }
  }

  Future<void> _getPendingOrders(int? page) async {
    emit(state.copyWith(pendingOrdersState: const BaseState(isLoading: true)));
    final response = await _getPendingOrdersUseCase.call(page: page);
    switch (response) {
      case SuccessBaseResponse():
        emit(
          state.copyWith(pendingOrdersState: BaseState(data: response.data)),
        );
      case ErrorBaseResponse():
        emit(
          state.copyWith(
            pendingOrdersState: BaseState(errorMessage: response.errorMessage),
          ),
        );
    }
  }

  void _acceptOrder(OrderEntity order) {
    emitUiEvent(
      NavigateEvent(
        AppRoutes.orderDetails,
        arguments: OrderDetailsArgs(order: order),
      ),
    );
  }

  Future<void> _rejectOrder(String orderId) async {
    final current = state.pendingOrdersState.data;
    if (current == null) return;

    emit(state.copyWith(rejectingOrderId: orderId));
    await Future.delayed(const Duration(milliseconds: 600));

    final remaining = current.orders
        .where((order) => order.id != orderId)
        .toList();

    emit(
      state.copyWith(
        pendingOrdersState: BaseState(
          data: PendingOrdersEntity(
            message: current.message,
            orders: remaining,
          ),
        ),
        clearRejectingOrderId: true,
      ),
    );
  }
}
