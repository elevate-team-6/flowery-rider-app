import 'dart:async';

import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/services/location_service.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/map_constants.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_order_shipping_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_route_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/open_communication_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_events.dart'
    show LocationType;
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import 'map_events.dart';
import 'map_states.dart';

/// Display-only cubit for the delivery map: resolves the rider's location,
/// draws the route, and follows the rider live on-screen. It does NOT write the
/// rider's position to Firestore — that is owned by [OrderDetailsCubit] and runs
/// for the whole active order, independent of whether this map is open.
@injectable
class MapCubit extends BaseCubit<MapState, BaseUiEvent> {
  final LocationService _locationService;
  final OpenCommunicationUseCase _openCommunicationUseCase;
  final GetRouteUseCase _getRouteUseCase;
  final GetOrderShippingUseCase _getOrderShippingUseCase;

  MapCubit(
    this._locationService,
    this._openCommunicationUseCase,
    this._getRouteUseCase,
    this._getOrderShippingUseCase,
  ) : super(const MapState());

  StreamSubscription<Position>? _locationSubscription;

  void doEvent(MapEvents event) {
    switch (event) {
      case MapInitializeEvent():
        _onInitialize(event);
      case MapRetryLocationEvent():
        _resolveCurrentLocation();
      case MapRetryRouteEvent():
        _retryRoute();
      case MapContactEvent():
        _onContact(event.phone, event.type);
    }
  }

  Future<void> _onInitialize(MapInitializeEvent event) async {
    emit(
      MapState(
        order: event.order,
        locationType: event.locationType,
        target: _parseLatLng(event.targetLat, event.targetLong),
        locating: true,
        routeLoading: true,
      ),
    );

    if (event.locationType == LocationType.user) {
      final shipping = await _getOrderShippingUseCase(event.order.id);
      if (isClosed) return;
      if (shipping != null) {
        final merged = event.order.shippingAddress.mergeWith(shipping);
        emit(
          state.copyWith(
            order: event.order.copyWith(shippingAddress: merged),
            target: _parseLatLng(merged.lat, merged.long) ?? state.target,
          ),
        );
      }
    }

    await _resolveCurrentLocation();
  }

  LatLng? _parseLatLng(String lat, String long) {
    final la = double.tryParse(lat);
    final lo = double.tryParse(long);
    if (la == null || lo == null) return null;
    if (la == 0 && lo == 0) return null;
    return LatLng(la, lo);
  }

  Future<void> _resolveCurrentLocation() async {
    emit(state.copyWith(locating: true, clearLocationError: true));
    try {
      // 1) Location services (GPS) must be on.
      final serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (isClosed) return;
      if (!serviceEnabled) {
        _fail(AppStrings.locationServicesDisabled);
        return;
      }

      // 2) Permission must be granted.
      var permission = await _locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _locationService.requestPermission();
      }
      if (isClosed) return;
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _fail(AppStrings.locationPermissionRequired);
        return;
      }

      _startLiveTracking();

      final last = await _locationService.getLastKnownPosition();
      if (isClosed) return;
      if (last != null) _applyLocation(last);
      try {
        final position = await _locationService.getCurrentPosition(
          settings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 15),
          ),
        );
        if (isClosed) return;
        _applyLocation(position);
      } catch (_) {
        if (state.currentLocation == null) {
          _fail(AppStrings.couldNotGetGpsFix);
        }
      }

      final target = state.target;
      if (state.currentLocation != null && target != null) {
        await _loadRoute(state.currentLocation!, target);
      } else if (target == null) {
        emit(state.copyWith(routeLoading: false, routeError: true));
      }
    } catch (_) {
      _fail(AppStrings.couldNotGetLocation);
    }
  }

  void _applyLocation(Position position) {
    final location = LatLng(position.latitude, position.longitude);
    final isFirstFix = state.currentLocation == null;
    emit(
      state.copyWith(
        currentLocation: location,
        locating: false,
        clearLocationError: true,
      ),
    );
    // Center on the very first fix only; live ticks afterwards must not snap
    // the camera back and fight the rider panning the map.
    if (isFirstFix) {
      emitUiEvent(MoveCameraEvent(location, MapConstants.defaultZoom));
    }
  }

  void _startLiveTracking() {
    _locationSubscription?.cancel();
    // Listen to Geolocator's position stream instead of polling on a timer: it
    // pushes a fix only when the rider actually moves past the distance filter,
    // so a stationary rider costs nothing and a moving one updates live. Used
    // here purely to keep the on-screen marker following the rider.
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
            _applyLocation(position);
          },
          // Ignore a stream error; it stays subscribed and the next fix retries.
          onError: (_) {},
        );
  }

  Future<void> _loadRoute(LatLng start, LatLng end) async {
    emit(
      state.copyWith(
        routeLoading: true,
        routeError: false,
        usingFallback: false,
      ),
    );
    try {
      final points = await _getRouteUseCase(start, end);
      if (isClosed) return;
      if (points.isEmpty) {
        _applyFallbackRoute(start, end);
        return;
      }
      emit(state.copyWith(routePoints: points, routeLoading: false));
      if (points.length >= 2) emitUiEvent(FitCameraEvent(points));
    } catch (_) {
      if (isClosed) return;
      _applyFallbackRoute(start, end);
    }
  }

  void _applyFallbackRoute(LatLng start, LatLng end) {
    emit(
      state.copyWith(
        routePoints: [start, end],
        routeLoading: false,
        usingFallback: true,
      ),
    );
    emitUiEvent(FitCameraEvent([start, end]));
  }

  void _retryRoute() {
    final target = state.target;
    if (state.currentLocation != null && target != null) {
      _loadRoute(state.currentLocation!, target);
    }
  }

  void _fail(String message) {
    emit(
      state.copyWith(
        locating: false,
        routeLoading: false,
        locationError: message,
      ),
    );
  }

  Future<void> _onContact(String phone, CommunicationType type) async {
    if (phone.isEmpty) {
      emitUiEvent(DisplayErrorEvent(AppStrings.couldNotLaunchUrl));
      return;
    }
    final success = await _openCommunicationUseCase(phone, type);
    if (isClosed) return;
    if (!success) {
      emitUiEvent(DisplayErrorEvent(AppStrings.couldNotLaunchUrl));
    }
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
