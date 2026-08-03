import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../../../../config/base_ui_event/base_ui_event.dart';
import '../../../../config/base_ui_handler/ui_event_handler_mixin.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/map_constants.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/use_cases/open_communication_use_case.dart';
import '../view_model/map_view_model/map_cubit.dart';
import '../view_model/map_view_model/map_events.dart';
import '../view_model/map_view_model/map_states.dart';
import '../view_model/order_details/order_details_events.dart'
    show LocationType;
import '../widgets/address_info_card.dart';
import '../widgets/map/location_error_card.dart';
import '../widgets/map/map_pill.dart';
import '../widgets/map/route_status_chip.dart';

class MapArgs {
  final OrderEntity order;
  final LocationType locationType;
  final String targetLat;
  final String targetLong;

  const MapArgs({
    required this.order,
    required this.locationType,
    required this.targetLat,
    required this.targetLong,
  });
}

class MapScreen extends StatefulWidget {
  final MapArgs args;

  const MapScreen({super.key, required this.args});

  /// Keys for locating the two address cards in widget tests without matching
  /// on the store/rider names, which also render on the map markers.
  static const storeAddressCardKey = ValueKey('map.storeAddressCard');
  static const userAddressCardKey = ValueKey('map.userAddressCard');

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with UiEventHandler {
  final MapController _mapController = MapController();
  StreamSubscription<BaseUiEvent>? _uiEventSubscription;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<MapCubit>();
    _uiEventSubscription = cubit.eventStream.listen(handleUiEvent);
    cubit.doEvent(
      MapInitializeEvent(
        order: widget.args.order,
        locationType: widget.args.locationType,
        targetLat: widget.args.targetLat,
        targetLong: widget.args.targetLong,
      ),
    );
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    super.dispose();
  }

  @override
  void onMoveCamera(LatLng target, double zoom) =>
      _mapController.move(target, zoom);

  @override
  void onFitCamera(List<LatLng> points) {
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: EdgeInsets.all(48.w),
      ),
    );
  }

  void _contact(String phone, CommunicationType type) =>
      context.read<MapCubit>().doEvent(MapContactEvent(phone, type));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        final order = state.order ?? widget.args.order;
        final storeName = order.store.name;
        final customerName = order.user.fullName;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(state.toStore),
          body: Stack(
            children: [
              _buildMap(state, storeName, customerName),

              if (state.locating)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              if (state.locationError != null)
                LocationErrorCard(
                  message: state.locationError!,
                  onRetry: () => context.read<MapCubit>().doEvent(
                    const MapRetryLocationEvent(),
                  ),
                ),

              if (state.routeLoading || state.usingFallback || state.routeError)
                Positioned(
                  top:
                      kToolbarHeight + MediaQuery.of(context).padding.top + 8.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: RouteStatusChip(
                      loading: state.routeLoading,
                      fallback: state.usingFallback,
                      onRetry: () => context.read<MapCubit>().doEvent(
                        const MapRetryRouteEvent(),
                      ),
                    ),
                  ),
                ),

              _buildBottomSheet(order, storeName, customerName),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(bool toStore) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.all(8.w),
        // Circular pink back button to match the design.
        child: GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.chevron_left, color: AppColors.white, size: 24.w),
          ),
        ),
      ),
    );
  }

  Widget _buildMap(MapState state, String storeName, String customerName) {
    final target = state.target;
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: target ?? MapConstants.fallbackCenter,
        initialZoom: MapConstants.defaultZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: MapConstants.osmTileUrl,
          userAgentPackageName: MapConstants.tileUserAgent,
        ),

        // Solid for the real OSRM road route, dashed for the fallback line.
        if (state.routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: state.routePoints,
                strokeWidth: 4.0,
                color: AppColors.primary,
                pattern: state.usingFallback
                    ? StrokePattern.dashed(segments: const [10, 8])
                    : const StrokePattern.solid(),
              ),
            ],
          ),

        MarkerLayer(
          markers: [
            if (state.currentLocation != null)
              Marker(
                point: state.currentLocation!,
                width: 150.w,
                height: 24.h,
                child: MapPill(
                  label: AppStrings.yourLocation.tr(),
                  icon: Icons.location_on,
                ),
              ),
            if (target != null)
              Marker(
                point: target,
                width: 150.w,
                height: 24.h,
                child: state.toStore
                    ? MapPill(
                        label: storeName.isNotEmpty ? storeName : 'Flowery',
                        isFlowery: true,
                      )
                    : MapPill(
                        label: customerName.isNotEmpty
                            ? customerName
                            : AppStrings.customer.tr(),
                        icon: Icons.person_pin_circle,
                      ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomSheet(
    OrderEntity order,
    String storeName,
    String customerName,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.36,
      minChildSize: 0.36,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
              Text(
                AppStrings.pickupAddress.tr(),
                style: AppTextStyles.gray14400.copyWith(
                  color: AppColors.white90,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 8.h),
              AddressInfoCard(
                key: MapScreen.storeAddressCardKey,
                imageUrl: order.store.image,
                title: order.store.name,
                address: order.store.address,
                onPhoneTap: () =>
                    _contact(order.store.phoneNumber, CommunicationType.phone),
                onWhatsappTap: () => _contact(
                  order.store.phoneNumber,
                  CommunicationType.whatsapp,
                ),
              ),
              SizedBox(height: 16.h),

              Text(
                AppStrings.userAddress.tr(),
                style: AppTextStyles.gray14400.copyWith(
                  color: AppColors.white90,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 8.h),
              AddressInfoCard(
                key: MapScreen.userAddressCardKey,
                imageUrl: order.user.photo,
                title: order.user.fullName,
                address:
                    '${order.shippingAddress.street}, ${order.shippingAddress.city}',
                onPhoneTap: () =>
                    _contact(order.user.phone, CommunicationType.phone),
                onWhatsappTap: () =>
                    _contact(order.user.phone, CommunicationType.whatsapp),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }
}
