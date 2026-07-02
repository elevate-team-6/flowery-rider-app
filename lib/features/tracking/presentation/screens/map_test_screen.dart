import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../config/di/di.dart';
import '../../../../config/services/location_service.dart';
import '../../../../config/services/osrm_routing_service.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Where the route line should go from the rider's location.
enum MapDestination { store, customer }

/// Pickup location screen (step 1 of tracking).
///
/// Shows the rider's real current location and draws a route to either the
/// store or the customer, depending on [destination].
/// TODO: feed the store / user addresses from the accepted [OrderEntity].
class MapTestScreen extends StatefulWidget {
  final MapDestination destination;

  const MapTestScreen({super.key, this.destination = MapDestination.customer});

  @override
  State<MapTestScreen> createState() => _MapTestScreenState();
}

class _MapTestScreenState extends State<MapTestScreen> {
  final LocationService _locationService = getIt<LocationService>();
  final OsrmRoutingService _routingService = OsrmRoutingService();
  final MapController _mapController = MapController();

  // Road-following route points from OSRM (empty until loaded).
  List<LatLng> _routePoints = [];
  // Starts true so the loading chip shows immediately on open (while we resolve
  // the location and then fetch the route).
  bool _routeLoading = true;
  bool _routeError = false; // OSRM request failed / returned nothing

  // Store + customer locations — TEST data placed in Beni Suef, near the rider.
  // TODO: read these from order.store.lat/long and order.shippingAddress.lat/long.
  static const LatLng _storeLocation = LatLng(29.0620, 31.0960); // بني سويف
  static const LatLng _customerLocation = LatLng(
    29.0700,
    31.1010,
  ); // العميل - بني سويف

  LatLng? _currentLocation; // null until we resolve the device location
  bool _loading = true;
  String? _error;

  /// The point the route line goes to (store or customer).
  LatLng get _target => widget.destination == MapDestination.store
      ? _storeLocation
      : _customerLocation;

  @override
  void initState() {
    super.initState();
    _resolveCurrentLocation();
  }

  /// Checks service + permission, then reads the current position.
  Future<void> _resolveCurrentLocation() async {
    try {
      // 1) Location services (GPS) must be on.
      final serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _fail('Please turn on location services (GPS).');
        return;
      }

      // 2) Permission must be granted.
      var permission = await _locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _locationService.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _fail('Location permission is required to show your location.');
        return;
      }

      // 3a) Use the last known fix first — instant, and works on emulators.
      final last = await _locationService.getLastKnownPosition();
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
        _applyLocation(position);
      } catch (_) {
        // Timeout / no fresh fix. If we never got any location, surface an error.
        if (_currentLocation == null) {
          _fail(
            'Could not get a GPS fix. On an emulator, set a location in '
            'Extended controls → Location.',
          );
        }
      }

      // Once we have a location, load the road route to the chosen target.
      if (_currentLocation != null) {
        await _loadRoute(_currentLocation!, _target);
      }
    } catch (e) {
      _fail('Could not get your location. Please try again.');
    }
  }

  /// Asks OSRM for the road route and stores it. Tracks loading / error state
  /// so the UI can show a small indicator.
  Future<void> _loadRoute(LatLng start, LatLng end) async {
    setState(() {
      _routeLoading = true;
      _routeError = false;
    });
    try {
      final points = await _routingService.getRoute(start, end);
      if (!mounted) return;
      if (points.isEmpty) {
        setState(() {
          _routeLoading = false;
          _routeError = true;
        });
        return;
      }
      setState(() {
        _routePoints = points;
        _routeLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _routeLoading = false;
        _routeError = true;
      });
    }
  }

  /// Retry loading the route (used by the error chip).
  void _retryRoute() {
    if (_currentLocation != null) _loadRoute(_currentLocation!, _target);
  }

  /// Applies a resolved position to the map state.
  void _applyLocation(Position position) {
    if (!mounted) return;
    final latLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentLocation = latLng;
      _loading = false;
      _error = null;
    });
    _mapController.move(latLng, 15);
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _routeLoading = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          widget.destination == MapDestination.store
              ? 'Route to store'
              : 'Route to customer',
          style: AppTextStyles.black18500,
        ),
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          // Circular pink back button to match the design.
          child: GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.chevron_left,
                color: AppColors.white,
                size: 24.w,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ---- Full-screen map ----
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              // Start on the store; we re-center once the location resolves.
              initialCenter: _storeLocation,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'flowery_rider_app',
              ),

              // Pink route line — only shown once the OSRM road route is
              // loaded (no straight-line fallback).
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.0,
                      color: AppColors.primary,
                    ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  // Rider marker only after we know the real location.
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 150.w,
                      height: 24.h,
                      child: const _MapPill(
                        label: 'Your location',
                        icon: Icons.location_on,
                      ),
                    ),
                  // Customer marker — only when heading to the customer.
                  if (widget.destination == MapDestination.customer)
                    Marker(
                      point: _customerLocation,
                      width: 150.w,
                      height: 24.h,
                      child: const _MapPill(
                        label: 'Nour mohamed',
                        icon: Icons.person_pin_circle,
                      ),
                    ),
                  // Store marker — only when heading to the store.
                  if (widget.destination == MapDestination.store)
                    Marker(
                      point: _storeLocation,
                      width: 150.w,
                      height: 24.h,
                      child: const _MapPill(label: 'Flowery', isFlowery: true),
                    ),
                ],
              ),
            ],
          ),

          // ---- Loading / error overlay ----
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          if (_error != null) _LocationError(message: _error!, onRetry: _retry),

          // ---- Route status chip (loading / failed) ----
          if (_routeLoading || _routeError)
            Positioned(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 8.h,
              left: 0,
              right: 0,
              child: Center(
                child: _RouteStatusChip(
                  loading: _routeLoading,
                  onRetry: _retryRoute,
                ),
              ),
            ),

          // ---- Draggable bottom sheet with the addresses ----
          DraggableScrollableSheet(
            initialChildSize: 0.36,
            minChildSize: 0.36,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.08),
                      blurRadius: 12.r,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    // Drag handle.
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 12.h),
                        width: 64.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                      ),
                    ),

                    Text('Pickup address', style: AppTextStyles.gray14400),
                    SizedBox(height: 8.h),
                    const _AddressCard(
                      name: 'Flowery store',
                      address: '20th st, Sheikh Zayed, Giza',
                      isFlowery: true,
                    ),
                    SizedBox(height: 16.h),

                    Text('User address', style: AppTextStyles.gray14400),
                    SizedBox(height: 8.h),
                    const _AddressCard(
                      name: 'Nour mohamed',
                      address: '20th st, Sheikh Zayed, Giza',
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _resolveCurrentLocation();
  }
}

/// Small centered error card with a retry button.
class _LocationError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LocationError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 32.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 8.r,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off, color: AppColors.primary, size: 32.w),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.black14400,
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text('Retry', style: AppTextStyles.white14600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small floating chip that shows route loading / failure state.
class _RouteStatusChip extends StatelessWidget {
  final bool loading;
  final VoidCallback onRetry;

  const _RouteStatusChip({required this.loading, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8.r,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: loading
            ? [
                SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 8.w),
                Text('Loading route…', style: AppTextStyles.black12400),
              ]
            : [
                Icon(Icons.error_outline, color: AppColors.primary, size: 16.w),
                SizedBox(width: 6.w),
                Text('Route unavailable', style: AppTextStyles.black12400),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: onRetry,
                  child: Text('Retry', style: AppTextStyles.primary12600),
                ),
              ],
      ),
    );
  }
}

/// Pink pill marker used on the map ("Your location" / "Flowery").
class _MapPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isFlowery;

  const _MapPill({
    required this.label,
    this.icon = Icons.location_on,
    this.isFlowery = false,
  });

  @override
  Widget build(BuildContext context) {
    // flutter_map gives the marker child a tight box, so wrap in Center to let
    // the pill shrink to its content (width = the word, not the whole box).
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // White circle with the icon (or flower logo) inside.
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: isFlowery
                  ? SvgPicture.asset(
                      AppIcons.flowerAppIcon,
                      width: 8.w,
                      height: 8.w,
                    )
                  : Icon(icon, size: 8.w, color: AppColors.primary),
            ),
            SizedBox(width: 3.w),
            // No Flexible/ellipsis → the text keeps its natural width, so the
            // pill is always exactly as wide as the word.
            Text(
              label,
              style: AppTextStyles.white12600.copyWith(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              softWrap: false,
            ),
            SizedBox(width: 3.w),
          ],
        ),
      ),
    );
  }
}

/// Address card in the bottom sheet with two call action buttons.
class _AddressCard extends StatelessWidget {
  final String name;
  final String address;
  final bool isFlowery;

  const _AddressCard({
    required this.name,
    required this.address,
    this.isFlowery = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.black10),
      ),
      child: Row(
        children: [
          _Avatar(isFlowery: isFlowery),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.black14600),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14.w,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        address,
                        style: AppTextStyles.gray12400,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Two call buttons. TODO: wire to url_launcher (tel: / whatsapp).
          _CallButton(filled: false, onTap: () {}),
          SizedBox(width: 8.w),
          _CallButton(filled: true, onTap: () {}),
        ],
      ),
    );
  }
}

/// Card avatar — Flowery brand circle or a user photo placeholder.
class _Avatar extends StatelessWidget {
  final bool isFlowery;

  const _Avatar({required this.isFlowery});

  @override
  Widget build(BuildContext context) {
    if (isFlowery) {
      return CircleAvatar(
        radius: 22.r,
        backgroundColor: AppColors.primary,
        child: SvgPicture.asset(
          AppIcons.flowerAppIcon,
          width: 22.w,
          height: 22.w,
        ),
      );
    }
    return CircleAvatar(
      radius: 22.r,
      backgroundColor: AppColors.pink10,
      backgroundImage: const AssetImage(AppImages.defaultImage),
    );
  }
}

/// Circular call button — outlined (icon only) or filled variant.
class _CallButton extends StatelessWidget {
  final bool filled;
  final VoidCallback onTap;

  const _CallButton({required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? AppColors.primary : Colors.transparent,
          border: filled ? null : Border.all(color: AppColors.primary),
        ),
        child: Icon(
          Icons.call,
          size: 18.w,
          color: filled ? AppColors.white : AppColors.primary,
        ),
      ),
    );
  }
}
