import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/validations/app_validations.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/country_entity.dart';
import 'package:flowery_rider_app/features/auth/presentation/widgets/selection_drowp_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApplyForm extends StatelessWidget {
  const ApplyForm({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.vehicleNumberController,
    required this.emailController,
    required this.phoneController,
    required this.nidController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nationalIdController,
    required this.drivingLicenseController,
    required this.nationalIdImage,
    required this.drivingLicenseImage,
    required this.onPickNationalIdImage,
    required this.onPickDrivingLicenseImage,
    required this.countries,
    required this.selectedCountry,
    required this.onCountryChanged,
    required this.selectedVehicleType,
    required this.onVehicleTypeChanged,
  });

  final File? nationalIdImage;
  final File? drivingLicenseImage;

  final VoidCallback onPickNationalIdImage;
  final VoidCallback onPickDrivingLicenseImage;

  final GlobalKey<FormState> formKey;

  final TextEditingController nationalIdController;
  final TextEditingController drivingLicenseController;

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController vehicleNumberController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController nidController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final List<CountryEntity> countries;
  final CountryEntity? selectedCountry;
  final ValueChanged<CountryEntity?> onCountryChanged;

  final String? selectedVehicleType;
  final ValueChanged<String?> onVehicleTypeChanged;

  static const List<String> vehicleTypes = [
    'Bike',
    'Motorcycle',
    'Car',
    'Van',
    'Truck',
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          /// Country
          AppDropdownField<CountryEntity>(
            label: AppStrings.country,
            hint: AppStrings.country,

            value: selectedCountry,

            items: countries
                .map(
                  (country) => DropdownMenuItem<CountryEntity>(
                    value: country,
                    child: Text(country.name),
                  ),
                )
                .toList(),

            onChanged: onCountryChanged,

            validator: (value) =>
                AppValidations.validateDropdown(value, AppStrings.country.tr()),
          ),

          SizedBox(height: 16.h),

          TextFormField(
            controller: firstNameController,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              hintText: AppStrings.firstName.tr(),
              labelText: AppStrings.enterFirstName.tr(),
            ),
            validator: AppValidations.validateFirstName,
          ),

          SizedBox(height: 16.h),

          TextFormField(
            controller: lastNameController,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              hintText: AppStrings.enterSecondName.tr(),
              labelText: AppStrings.secondName.tr(),
            ),
            validator: AppValidations.validateLastName,
          ),

          SizedBox(height: 16.h),

          /// Vehicle Type
          AppDropdownField<String>(
            label: AppStrings.vehicleType.tr(),
            hint: AppStrings.vehicleType.tr(),

            value: selectedVehicleType,

            items: vehicleTypes
                .map(
                  (type) =>
                      DropdownMenuItem<String>(value: type, child: Text(type)),
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
            controller: drivingLicenseController,
            readOnly: true,
            onTap: onPickDrivingLicenseImage,
            validator: (_) =>
                AppValidations.drivingLicenseImage(drivingLicenseImage),
            decoration: InputDecoration(
              labelText: AppStrings.vehicleLicense.tr(),
              hintText: AppStrings.uploadVehicleLicense.tr(),
              suffixIcon: const Icon(Icons.cloud_upload_outlined),
            ),
          ),

          SizedBox(height: 16.h),

          TextFormField(
            controller: emailController,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: AppStrings.enterYourEmail.tr(),
              labelText: AppStrings.email.tr(),
            ),
            validator: AppValidations.validateEmail,
          ),

          SizedBox(height: 16.h),

          TextFormField(
            controller: phoneController,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: AppStrings.enterPhoneNumber.tr(),
              labelText: AppStrings.phoneNumber.tr(),
            ),
            validator: AppValidations.validatePhoneNumber,
          ),

          SizedBox(height: 16.h),

          TextFormField(
            controller: nidController,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: AppStrings.enterIdNumber.tr(),
              labelText: AppStrings.idNumber.tr(),
            ),
            validator: AppValidations.validateNationalId,
          ),

          SizedBox(height: 16.h),

          TextFormField(
            controller: nationalIdController,
            readOnly: true,
            onTap: onPickNationalIdImage,
            validator: (_) => AppValidations.nationalIdImage(nationalIdImage),
            decoration: InputDecoration(
              labelText: AppStrings.idImage.tr(),
              hintText: AppStrings.uploadIdImage.tr(),
              suffixIcon: const Icon(Icons.cloud_upload_outlined),
            ),
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: AppStrings.enterYourPassword.tr(),
                    labelText: AppStrings.password.tr(),
                  ),
                  validator: AppValidations.validatePassword,
                ),
              ),

              SizedBox(width: 8.w),

              Expanded(
                child: TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: AppStrings.confirmPassword.tr(),
                    labelText: AppStrings.confirmPassword.tr(),
                  ),
                  validator: (value) => AppValidations.validateConfirmPassword(
                    value,
                    passwordController.text,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
