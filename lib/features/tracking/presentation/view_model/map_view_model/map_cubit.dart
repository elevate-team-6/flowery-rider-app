import 'dart:async';

import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/services/location_service.dart';
import 'package:flowery_rider_app/config/services/osrm_routing_service.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/map_constants.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/open_communication_use_case.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import 'map_events.dart';
import 'map_states.dart';

@injectable
class MapCubit extends BaseCubit<MapState, BaseUiEvent> {
  final LocationService _locationService;
  final OpenCommunicationUseCase _openCommunicationUseCase;
  final OsrmRoutingService _routingService;

  MapCubit(
    this._locationService,
    this._openCommunicationUseCase,
    this._routingService,
  ) : super(const MapState());

  Timer? _locationTimer;

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

  void _onInitialize(MapInitializeEvent event) {
    emit(
      MapState(
        order: event.order,
        locationType: event.locationType,
        target: _parseLatLng(event.targetLat, event.targetLong),
        locating: true,
        routeLoading: true,
      ),
    );
    _resolveCurrentLocation();
  }

  /// Parses a "lat"/"long" string pair into a [LatLng], or null when either is
  /// missing, unparsable, or the placeholder 0,0 the backend uses for "unset".
  LatLng? _parseLatLng(String lat, String long) {
    final la = double.tryParse(lat);
    final lo = double.tryParse(long);
    if (la == null || lo == null) return null;
    if (la == 0 && lo == 0) return null;
    return LatLng(la, lo);
  }

  /// Checks service + permission, reads the current position, starts live
  /// tracking, then loads the route to the target.
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

      // Live updates (marker only) every [_liveUpdateInterval].
      _startLiveTracking();

      // 3a) Use the last known fix first — instant, and works on emulators.
      final last = await _locationService.getLastKnownPosition();
      if (isClosed) return;
      if (last != null) _applyLocation(last);

      // 3b) Then get a fresh position, but don't wait forever (emulators may
      //     never produce a GPS fix). If it times out we keep the last fix.
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
          // On an emulator, set a location in Extended controls → Location.
          _fail(AppStrings.couldNotGetGpsFix);
        }
      }

      // Once we have a location, load the road route to the target.
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

  /// Applies a resolved position to the state.
  void _applyLocation(Position position) {
    emit(
      state.copyWith(
        currentLocation: LatLng(position.latitude, position.longitude),
        locating: false,
        clearLocationError: true,
      ),
    );
  }

  /// Polls the current position on a fixed interval and moves the marker only.
  void _startLiveTracking() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(MapConstants.liveUpdateInterval, (_) async {
      try {
        final position = await _locationService.getCurrentPosition(
          settings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        if (isClosed) return;
        _applyLocation(position);
      } catch (_) {
        // Ignore a failed tick; the next one will try again.
      }
    });
  }

  /// Asks OSRM for the road route. Falls back to a straight line when OSRM
  /// can't produce one (empty result / error / points too far apart).
  Future<void> _loadRoute(LatLng start, LatLng end) async {
    emit(
      state.copyWith(
        routeLoading: true,
        routeError: false,
        usingFallback: false,
      ),
    );
    try {
      final points = await _routingService.getRoute(start, end);
      if (isClosed) return;
      if (points.isEmpty) {
        _applyFallbackRoute(start, end);
        return;
      }
      emit(state.copyWith(routePoints: points, routeLoading: false));
    } catch (_) {
      if (isClosed) return;
      _applyFallbackRoute(start, end);
    }
  }

  /// Draws a straight line between [start] and [end] as a last resort.
  void _applyFallbackRoute(LatLng start, LatLng end) {
    emit(
      state.copyWith(
        routePoints: [start, end],
        routeLoading: false,
        usingFallback: true,
      ),
    );
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
    _locationTimer?.cancel();
    return super.close();
  }
}
