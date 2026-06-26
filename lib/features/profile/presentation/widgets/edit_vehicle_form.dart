import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/validations/app_validations.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/vehicle_type_entity.dart';
import 'package:flowery_rider_app/features/auth/presentation/widgets/selection_drowp_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditVehicleForm extends StatelessWidget {
  const EditVehicleForm({
    super.key,
    required this.formKey,
    required this.vehicleNumberController,
    required this.drivingLicenseImage,
    required this.drivingLicenseImageUrl,
    required this.onPickDrivingLicenseImage,
    required this.vehicleTypes,
    required this.selectedVehicleType,
    required this.onVehicleTypeChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController vehicleNumberController;

  final File? drivingLicenseImage;
  final String? drivingLicenseImageUrl;

  final VoidCallback onPickDrivingLicenseImage;

  final List<VehicleTypeEntity> vehicleTypes;
  final VehicleTypeEntity? selectedVehicleType;
  final ValueChanged<VehicleTypeEntity?> onVehicleTypeChanged;

  String _getFileName() {
    if (drivingLicenseImage != null) {
      return drivingLicenseImage!.path.split('/').last;
    }

    if (drivingLicenseImageUrl != null && drivingLicenseImageUrl!.isNotEmpty) {
      return Uri.parse(drivingLicenseImageUrl!).pathSegments.last;
    }

    return AppStrings.uploadVehicleLicense.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          AppDropdownField<VehicleTypeEntity>(
            label: AppStrings.vehicleType.tr(),
            hint: AppStrings.vehicleType.tr(),
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
              labelText: AppStrings.vehicleNumber.tr(),
              hintText: AppStrings.enterVehicleNumber.tr(),
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
              hintText: _getFileName(),
              suffixIcon: const Icon(Icons.cloud_upload_outlined),
            ),
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
