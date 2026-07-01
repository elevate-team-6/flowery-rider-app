import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_driver_orders_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_states.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/base_response/base_response.dart';
import '../../../../../config/base_state/base_state.dart';
import '../../../domain/entities/driver_orders_summary.dart';
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
      case ChangePageEvent():
        _getDriverOrders(page: event.page);
      case OrderTappedEvent():
        _onOrderTapped(event.order);
    }
  }

  Future<void> _getDriverOrders({int page = 1}) async {
    emit(state.copyWith(ordersState: const BaseState(isLoading: true)));

    final response = await _getDriverOrdersUseCase(page: page);

    switch (response) {
      case SuccessBaseResponse<DriverOrdersSummary>():
        final summary = response.data;
        if (summary == null) return;

        emit(
          state.copyWith(
            ordersState: BaseState(data: summary.driverOrders.orders),
            cancelledCount: summary.canceledCount,
            completedCount: summary.completedCount,
            currentPage: summary.driverOrders.currentPage,
            totalPages: summary.driverOrders.totalPages,
          ),
        );
      case ErrorBaseResponse<DriverOrdersSummary>():
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
