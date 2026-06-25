import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
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
  const EditVehicleScreen({super.key});

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
  print('=== EDIT VEHICLE INIT ===');

    final cubit = context.read<EditVehicleCubit>();

    cubit.doIntent(const GetVehicleTypesEvent());

    vehicleNumberController.addListener(() {
      cubit.doIntent(const ChangeVehicleNumberEvent());
    });

    _eventSubscription = cubit.eventStream.listen(_handleUiEvent);
  }

  void _handleUiEvent(BaseUiEvent event) {
    print('EVENT => ${event.runtimeType}');
    switch (event) {
      case DisplayErrorEvent():
        CustomSnackBar.showErrorMessage(event.errorMessage.tr());

      case DisplaySuccessEvent():
        CustomSnackBar.showSuccessMessage(event.successMessage.tr());

        Navigator.pop(context);

      default:
        break;
    }
  }

  @override
  void dispose() {
      print('=== EDIT VEHICLE DISPOSE ===');

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
                  onPressed:
                      !state.hasChanges || state.editVehicleState.isLoading
                      ? null
                      : () {
                          print('UPDATE BUTTON CLICKED');
                          if (!formKey.currentState!.validate()) {
                                      print('FORM INVALID');

                            return;
                          }
        print('FORM VALID');

                          context.read<EditVehicleCubit>().doIntent(
                            EditVehicleSubmitEvent(
                              vehicleNumber: vehicleNumberController.text,
                            ),
                          );
                        },
                  child: state.editVehicleState.isLoading
                      ? const CircularProgressIndicator()
                      : Text(AppStrings.update.tr()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
