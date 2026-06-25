import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/validations/app_validations.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/presentation/widgets/selection_drowp_down.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/vehicle_type_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditVehicleForm extends StatelessWidget {
  const EditVehicleForm({
    super.key,
    required this.formKey,
    required this.vehicleNumberController,
    required this.drivingLicenseImage,
    required this.onPickDrivingLicenseImage,
    required this.vehicleTypes,
    required this.selectedVehicleType,
    required this.onVehicleTypeChanged,
  });

  final File? drivingLicenseImage;
  final VoidCallback onPickDrivingLicenseImage;
  final GlobalKey<FormState> formKey;
  final TextEditingController vehicleNumberController;
  final List<VehicleTypeEntity> vehicleTypes;
  final VehicleTypeEntity? selectedVehicleType;
  final ValueChanged<VehicleTypeEntity?> onVehicleTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          AppDropdownField<VehicleTypeEntity>(
            label: AppStrings.vehicleType.tr(),
            hint: vehicleTypes.isNotEmpty
                ? vehicleTypes.first.type
                : AppStrings.vehicleType.tr(),

            value: selectedVehicleType,

            items: vehicleTypes
                .map(
                  (vehicle) => DropdownMenuItem<VehicleTypeEntity>(
                    value: vehicle,
                    child: Text(vehicle.type),
                  ),
                )
                .toList(),

            onChanged: onVehicleTypeChanged,

            validator: (value) => AppValidations.validateDropdown(
              value,
              AppStrings.vehicleType.tr(),
            ),
          ),

          SizedBox(height: 16.h),

          TextFormField(
            controller: vehicleNumberController,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: AppStrings.enterVehicleNumber.tr(),
              labelText: AppStrings.vehicleNumber.tr(),
            ),
            validator: AppValidations.validateVehicleNumber,
          ),

          SizedBox(height: 16.h),

          TextFormField(
            readOnly: true,
            onTap: onPickDrivingLicenseImage,
            validator: (_) =>
                AppValidations.drivingLicenseImage(drivingLicenseImage),
            decoration: InputDecoration(
              labelText: AppStrings.vehicleLicense.tr(),
              hintText: drivingLicenseImage == null
                  ? AppStrings.uploadVehicleLicense.tr()
                  : drivingLicenseImage!.path.split('/').last,
              suffixIcon: const Icon(Icons.cloud_upload_outlined),
            ),
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
