import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_driver_orders_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_states.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/base_response/base_response.dart';
import '../../../../../config/base_state/base_state.dart';
import '../../../domain/entities/order_entity.dart';

@injectable
class OrderScreenCubit extends BaseCubit<OrderScreenState, BaseUiEvent> {
  final GetDriverOrdersUseCase _getDriverOrdersUseCase;

  OrderScreenCubit(this._getDriverOrdersUseCase)
    : super(const OrderScreenState());

  void doEvent(OrdersScreenEvents event) {
    switch (event) {
      case GetDriverOrdersEvent():
        _getDriverOrders();
      case RefreshOrdersEvent():
        _getDriverOrders();
      case OrderTappedEvent():
        _onOrderTapped(event.order);
    }
  }

  Future<void> _getDriverOrders() async {
    emit(state.copyWith(ordersState: const BaseState(isLoading: true)));

    final response = await _getDriverOrdersUseCase();

    switch (response) {
      case SuccessBaseResponse<List<OrderEntity>>():
        final orders = response.data ?? [];

        // Calculate counts based on order state
        final cancelledCount = orders
            .where((o) => o.state.toLowerCase() == 'cancelled')
            .length;
        final completedCount = orders
            .where((o) => o.state.toLowerCase() == 'completed')
            .length;

        emit(
          state.copyWith(
            ordersState: BaseState(data: orders),
            cancelledCount: cancelledCount,
            completedCount: completedCount,
          ),
        );
      case ErrorBaseResponse<List<OrderEntity>>():
        emit(
          state.copyWith(
            ordersState: BaseState(errorMessage: response.errorMessage),
          ),
        );
    }
  }

  void _onOrderTapped(OrderEntity order) {
    emitUiEvent(NavigateEvent(AppRoutes.driverOrderDetails, arguments: order));
  }
}
