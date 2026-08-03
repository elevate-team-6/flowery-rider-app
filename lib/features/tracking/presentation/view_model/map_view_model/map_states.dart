import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/entities/order_entity.dart';
import '../order_details/order_details_events.dart' show LocationType;

class MapState extends Equatable {
  final OrderEntity? order;
  final LocationType locationType;
  final LatLng? target;
  final LatLng? currentLocation;
  final List<LatLng> routePoints;
  final bool locating;
  final String? locationError;
  final bool routeLoading;
  final bool routeError;
  final bool usingFallback;

  const MapState({
    this.order,
    this.locationType = LocationType.store,
    this.target,
    this.currentLocation,
    this.routePoints = const [],
    this.locating = true,
    this.locationError,
    this.routeLoading = true,
    this.routeError = false,
    this.usingFallback = false,
  });

  bool get toStore => locationType == LocationType.store;

  MapState copyWith({
    OrderEntity? order,
    LocationType? locationType,
    LatLng? target,
    LatLng? currentLocation,
    List<LatLng>? routePoints,
    bool? locating,
    String? locationError,
    bool clearLocationError = false,
    bool? routeLoading,
    bool? routeError,
    bool? usingFallback,
  }) {
    return MapState(
      order: order ?? this.order,
      locationType: locationType ?? this.locationType,
      target: target ?? this.target,
      currentLocation: currentLocation ?? this.currentLocation,
      routePoints: routePoints ?? this.routePoints,
      locating: locating ?? this.locating,
      locationError: clearLocationError
          ? null
          : (locationError ?? this.locationError),
      routeLoading: routeLoading ?? this.routeLoading,
      routeError: routeError ?? this.routeError,
      usingFallback: usingFallback ?? this.usingFallback,
    );
  }

  @override
  List<Object?> get props => [
    order,
    locationType,
    target,
    currentLocation,
    routePoints,
    locating,
    locationError,
    routeLoading,
    routeError,
    usingFallback,
  ];
}
