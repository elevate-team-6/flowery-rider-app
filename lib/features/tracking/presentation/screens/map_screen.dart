import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

class MapScreen extends StatefulWidget {
  final OrderEntity order;
  final LocationType locationType;
  final String targetLat;
  final String targetLong;

  const MapScreen({
    super.key,
    required this.order,
    required this.locationType,
    required this.targetLat,
    required this.targetLong,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with UiEventHandler {
  final MapController _mapController = MapController();
  StreamSubscription<BaseUiEvent>? _uiEventSubscription;

  bool _centeredOnce = false;
  bool _routeFitted = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<MapCubit>();
    _uiEventSubscription = cubit.eventStream.listen(handleUiEvent);
    cubit.doEvent(
      MapInitializeEvent(
        order: widget.order,
        locationType: widget.locationType,
        targetLat: widget.targetLat,
        targetLong: widget.targetLong,
      ),
    );
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    super.dispose();
  }

  /// Drives the camera from state changes: center on the first fix, fit to the
  /// route once it's available. Live updates afterwards are ignored on purpose.
  void _syncCamera(MapState state) {
    if (!_centeredOnce && state.currentLocation != null) {
      _centeredOnce = true;
      _mapController.move(state.currentLocation!, MapConstants.defaultZoom);
    }
    if (!_routeFitted && state.routePoints.length >= 2) {
      _routeFitted = true;
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(state.routePoints),
          padding: EdgeInsets.all(48.w),
        ),
      );
    }
  }

  void _contact(String phone, CommunicationType type) =>
      context.read<MapCubit>().doEvent(MapContactEvent(phone, type));

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapCubit, MapState>(
      listener: (context, state) => _syncCamera(state),
      child: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          final order = state.order ?? widget.order;
          final storeName = order.store.name;
          final customerName = order.user.fullName;

          return Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: AppColors.white,
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

                if (state.routeLoading ||
                    state.usingFallback ||
                    state.routeError)
                  Positioned(
                    top:
                        kToolbarHeight +
                        MediaQuery.of(context).padding.top +
                        8.h,
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
      ),
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
