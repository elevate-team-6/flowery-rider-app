import 'dart:async';

import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/services/location_service.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/map_constants.dart';
import 'package:flowery_rider_app/features/notification/domain/entities/user_notification_state.dart';
import 'package:flowery_rider_app/features/notification/domain/use_cases/update_order_progress_use_case.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/cache_active_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/clear_active_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_active_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/open_communication_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/start_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/update_order_state_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/update_rider_location_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/map_screen.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_states.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/base_state/base_state.dart';

// UI step at which the order is out for delivery ("onWay"). Live location
// tracking to Firestore runs from this step until the order is delivered or
// canceled.
const int _outForDeliveryStep = 4;

@injectable
class OrderDetailsCubit extends BaseCubit<OrderDetailsState, BaseUiEvent> {
  final UpdateOrderStateUseCase _updateOrderStateUseCase;
  final StartOrderUseCase _startOrderUseCase;
  final OpenCommunicationUseCase _openCommunicationUseCase;
  final CacheActiveOrderUseCase _cacheActiveOrderUseCase;
  final GetActiveOrderUseCase _getActiveOrderUseCase;
  final ClearActiveOrderUseCase _clearActiveOrderUseCase;
  final UpdateOrderProgressUseCase _updateOrderProgressUseCase;
  final LocationService _locationService;
  final UpdateRiderLocationUseCase _updateRiderLocationUseCase;

  OrderDetailsCubit(
    this._updateOrderStateUseCase,
    this._startOrderUseCase,
    this._openCommunicationUseCase,
    this._cacheActiveOrderUseCase,
    this._getActiveOrderUseCase,
    this._clearActiveOrderUseCase,
    this._updateOrderProgressUseCase,
    this._locationService,
    this._updateRiderLocationUseCase,
  ) : super(const OrderDetailsState());

  // Live location tracking runs while the order is out for delivery, regardless
  // of whether the delivery map screen is open. This keeps Firestore updated so
  // the customer always sees the rider moving.
  StreamSubscription<Position>? _locationSubscription;

  void doEvent(OrderDetailsEvents event) {
    switch (event) {
      case OrderDetailsInitializeEvent():
        _onInitialize(event.order, initialStep: event.initialStep);
      case OrderDetailsNextStepEvent():
        _onNextStep();
      case ConfirmBackButtonPressedEvent():
        _onBackButtonPressed();
      case RevertOrderToPendingEvent():
        _onRevertToPending(event.orderId);
      case NavigateToMapEvent():
        _onNavigateToMap(event.locationType);
      case CallPhoneEvent():
        _onCallPhone(event.phoneNumber);
      case OpenWhatsAppEvent():
        _onOpenWhatsApp(event.phoneNumber);
    }
  }

  Future<void> _onInitialize(OrderEntity order, {int? initialStep}) async {
    final initialBackendStatus = OrderStatus.fromString(order.state);
    int step = initialStep ?? 1;

    // Check Cache first
    final cachedData = await _getActiveOrderUseCase();
    if (cachedData != null) {
      final cachedOrder = cachedData.order;
      if (cachedOrder.id == order.id) {
        emit(
          state.copyWith(
            orderDetailsState: BaseState(data: cachedOrder),
            orderStatus: OrderStatus.fromString(cachedOrder.state),
            uiStep: cachedData.uiStep,
          ),
        );
        // Resume live tracking if the order was already out for delivery when
        // the app was reopened.
        _syncLocationTracking(cachedOrder.id, cachedData.uiStep);
        return; // Don't call startOrder API if cached
      }
    }

    // Fallback if no cache
    if (initialStep == null) {
      if (initialBackendStatus == OrderStatus.completed) {
        step = 6;
      } else if (initialBackendStatus == OrderStatus.inProgress) {
        step = 1;
      }
    }

    emit(
      state.copyWith(
        orderDetailsState: BaseState(data: order),
        orderStatus: initialBackendStatus,
        uiStep: step,
      ),
    );

    BaseResponse<OrderEntity> startResult = await _startOrderUseCase(order.id);

    if (startResult is SuccessBaseResponse<OrderEntity>) {
      final updatedOrder = startResult.data;
      final mergedOrder = order.mergeWith(updatedOrder);

      emit(
        state.copyWith(
          orderDetailsState: BaseState(data: mergedOrder),
          orderStatus: OrderStatus.fromString(mergedOrder.state),
        ),
      );
      await _cacheActiveOrderUseCase(mergedOrder, state.uiStep);
      // Resume tracking if this order is already at/after the out-for-delivery
      // step.
      _syncLocationTracking(mergedOrder.id, state.uiStep);
      // Notify User: Step 1 (Accepted)
      _updateProgress(UserNotificationState.accepted);
    }
  }

  Future<void> _onNextStep() async {
    final currentStep = state.uiStep;
    if (currentStep >= 6 || state.updateStepState.isLoading) return;

    final currentOrder = state.orderDetailsState.data;
    if (currentOrder == null) return;

    final nextStep = currentStep + 1;
    final orderId = currentOrder.id;

    OrderStatus backendStatus = (nextStep == 6)
        ? OrderStatus.completed
        : OrderStatus.inProgress;

    emitUiEvent(ShowLoadingEvent());
    emit(state.copyWith(updateStepState: const BaseState(isLoading: true)));
    final result = await _updateOrderStateUseCase(orderId, backendStatus);
    emit(state.copyWith(updateStepState: const BaseState(isLoading: false)));
    emitUiEvent(HideLoadingEvent());

    switch (result) {
      case SuccessBaseResponse<OrderEntity>():
        final mergedOrder = currentOrder.mergeWith(result.data);

        emit(
          state.copyWith(
            orderDetailsState: BaseState(data: mergedOrder),
            orderStatus: backendStatus,
            uiStep: nextStep,
          ),
        );

        // Notification logic for specific user-facing steps
        final notifyState = switch (nextStep) {
          2 => UserNotificationState.preparing,
          4 => UserNotificationState.onWay,
          6 => UserNotificationState.delivered,
          _ => null,
        };

        if (notifyState != null) {
          _updateProgress(notifyState);
        }

        // Start live location tracking the moment the order goes out for
        // delivery, so Firestore updates even if the rider never opens the map.
        if (nextStep == _outForDeliveryStep) {
          _startLocationTracking(orderId);
        }

        if (nextStep == 6) {
          _stopLocationTracking();
          await _clearActiveOrderUseCase();
          emitUiEvent(
            NavigateEvent(
              AppRoutes.orderSuccess,
              navigationType: NavigationType.pushReplacement,
            ),
          );
        } else {
          await _cacheActiveOrderUseCase(mergedOrder, nextStep);
        }
      case ErrorBaseResponse<OrderEntity>():
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _updateProgress(UserNotificationState notifyState) async {
    final order = state.orderDetailsState.data;
    if (order?.id == null || order?.user?.id == null) return;

    await _updateOrderProgressUseCase(
      userId: order!.user!.id!,
      orderId: order.id!,
      state: notifyState,
    );
  }

  /// Starts (or resumes) live location tracking only if the order is at/after
  /// the out-for-delivery step. Safe to call multiple times; it is idempotent.
  void _syncLocationTracking(String orderId, int step) {
    if (step >= _outForDeliveryStep && step < 6) {
      _startLocationTracking(orderId);
    }
  }

  /// Streams the rider's live position and mirrors each fix onto the order doc
  /// in Firestore, so the customer app shows the rider moving on the map — even
  /// when the rider hasn't opened the delivery map. Runs from out-for-delivery
  /// until the order is delivered or canceled. Best-effort: permission/GPS
  /// hiccups are swallowed and never disrupt the delivery flow.
  Future<void> _startLocationTracking(String orderId) async {
    if (orderId.isEmpty) return;
    // Already tracking → don't start a second stream.
    if (_locationSubscription != null) return;

    try {
      final serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await _locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _locationService.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      // Publish an immediate first fix so the customer sees the rider right
      // away, without waiting for the first movement past the distance filter.
      final last = await _locationService.getLastKnownPosition();
      if (last != null) _publishRiderLocation(orderId, last);

      _locationSubscription = _locationService
          .getPositionStream(
            settings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: MapConstants.liveDistanceFilter,
            ),
          )
          .listen(
            (position) {
              if (isClosed) return;
              _publishRiderLocation(orderId, position);
            },
            // Ignore a stream error; it stays subscribed and the next fix
            // retries.
            onError: (_) {},
          );
    } catch (_) {
      // Best-effort: never let a location hiccup disrupt the delivery flow.
    }
  }

  void _stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// Fire-and-forget write of the rider's position to Firestore. The repo
  /// swallows failures, so a dropped tick never disrupts the delivery flow.
  void _publishRiderLocation(String orderId, Position position) {
    _updateRiderLocationUseCase(
      orderId: orderId,
      lat: position.latitude.toString(),
      long: position.longitude.toString(),
    );
  }

  void _onBackButtonPressed() {
    emitUiEvent(ShowConfirmationDialogEvent());
  }

  Future<void> _onRevertToPending(String orderId) async {
    emit(state.copyWith(canselOrderState: BaseState(isLoading: true)));
    final result = await _updateOrderStateUseCase(
      orderId,
      OrderStatus.canceled,
    );
    emit(state.copyWith(canselOrderState: BaseState()));
    switch (result) {
      case SuccessBaseResponse<OrderEntity>():
        _stopLocationTracking();
        await _clearActiveOrderUseCase();
        emitUiEvent(
          NavigateEvent(
            AppRoutes.mainLayout,
            navigationType: NavigationType.pushAndRemoveUntil,
          ),
        );
        _updateProgress(UserNotificationState.canceled);
      case ErrorBaseResponse<OrderEntity>():
        emit(
          state.copyWith(
            orderDetailsState: BaseState(errorMessage: result.errorMessage),
          ),
        );
    }
  }

  void _onNavigateToMap(LocationType type) {
    final order = state.orderDetailsState.data;
    if (order == null) return;

    final lat = type == LocationType.store
        ? order.store.lat
        : order.shippingAddress.lat;
    final long = type == LocationType.store
        ? order.store.long
        : order.shippingAddress.long;

    if (lat.isNotEmpty && long.isNotEmpty) {
      emitUiEvent(
        NavigateEvent(
          AppRoutes.mapScreen,
          arguments: MapArgs(
            order: order,
            locationType: type,
            targetLat: lat,
            targetLong: long,
          ),
        ),
      );
    }
  }

  Future<void> _onCallPhone(String phoneNumber) async {
    final success = await _openCommunicationUseCase(
      phoneNumber,
      CommunicationType.phone,
    );
    if (!success) {
      emitUiEvent(DisplayErrorEvent(AppStrings.couldNotLaunchUrl));
    }
  }

  Future<void> _onOpenWhatsApp(String phoneNumber) async {
    final success = await _openCommunicationUseCase(
      phoneNumber,
      CommunicationType.whatsapp,
    );
    if (!success) {
      emitUiEvent(DisplayErrorEvent(AppStrings.couldNotLaunchUrl));
    }
  }

  @override
  Future<void> close() {
    _stopLocationTracking();
    return super.close();
  }
}
