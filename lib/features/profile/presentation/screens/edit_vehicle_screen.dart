import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/entities/driver_entity.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/widgets/custom_snack_bar.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_vehicle/edit_vehicle_cubit.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_vehicle/edit_vehicle_events.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_vehicle/edit_vehicle_states.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/edit_vehicle_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditVehicleScreen extends StatefulWidget {
  final DriverEntity driver;

  const EditVehicleScreen({super.key, required this.driver});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final formKey = GlobalKey<FormState>();

  final vehicleNumberController = TextEditingController();

  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();

    final cubit = context.read<EditVehicleCubit>();

    vehicleNumberController.text = widget.driver.vehicleNumber;

    cubit.doIntent(
      InitializeEditVehicleEvent(
        vehicleTypeId: widget.driver.vehicleType,
        vehicleNumber: widget.driver.vehicleNumber,
        vehicleLicenseUrl: widget.driver.vehicleLicense,
      ),
    );

    cubit.doIntent(const GetVehicleTypesEvent());

    vehicleNumberController.addListener(() {
      cubit.doIntent(const ChangeVehicleNumberEvent());
    });

    _eventSubscription = cubit.eventStream.listen(_handleUiEvent);
  }

  void _handleUiEvent(BaseUiEvent event) {
    switch (event) {
      case DisplayErrorEvent():
        CustomSnackBar.showErrorMessage(event.errorMessage.tr());

      case DisplaySuccessEvent():
        CustomSnackBar.showSuccessMessage(event.successMessage.tr());
        final updatedDriver = widget.driver.copyWith(
  vehicleType:
      context.read<EditVehicleCubit>().state.selectedVehicleType?.type,
  vehicleNumber: vehicleNumberController.text,
  vehicleLicense:
      context.read<EditVehicleCubit>().state.drivingLicenseImageUrl,
);

Navigator.pop(context, updatedDriver);

      default:
        break;
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    vehicleNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(titleSpacing: 0, title: Text(AppStrings.editProfile.tr())),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: BlocBuilder<EditVehicleCubit, EditVehicleState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: EditVehicleForm(
                      formKey: formKey,
                      vehicleNumberController: vehicleNumberController,
                      drivingLicenseImage: state.drivingLicenseImage,
                      drivingLicenseImageUrl: state.drivingLicenseImageUrl,
                      onPickDrivingLicenseImage: () {
                        context.read<EditVehicleCubit>().doIntent(
                          const PickDrivingLicenseImageEvent(),
                        );
                      },
                      vehicleTypes: state.vehicleTypesState.data ?? [],
                      selectedVehicleType: state.selectedVehicleType,
                      onVehicleTypeChanged: (vehicle) {
                        if (vehicle != null) {
                          context.read<EditVehicleCubit>().doIntent(
                            ChangeVehicleTypeEvent(vehicle),
                          );
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: !state.hasChanges
                      ? null
                      : () {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          context.read<EditVehicleCubit>().doIntent(
                            EditVehicleSubmitEvent(
                              vehicleNumber: vehicleNumberController.text,
                            ),
                          );
                        },
                  child: Text(AppStrings.update.tr()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}