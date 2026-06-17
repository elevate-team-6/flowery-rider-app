import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/validations/app_validations.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
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
  });

  final GlobalKey<FormState> formKey;

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController vehicleNumberController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController nidController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          AppDropdownField<String>(
            label: AppStrings.country,
            hint: '',
            items: const [],
            validator: (value) =>
                AppValidations.validateDropdown(
                  value,
                  AppStrings.country.tr(),
                ),
            onChanged: (value) {},
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

          AppDropdownField<String>(
            label: AppStrings.vehicleType,
            hint: '',
            items: const [],
            validator: (value) =>
                AppValidations.validateDropdown(
                  value,
                  AppStrings.vehicleType.tr(),
                ),
            onChanged: (value) {},
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

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: passwordController,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: AppStrings.confirmPassword.tr(),
                    labelText: AppStrings.confirmPassword.tr(),
                  ),
                  validator: (value) =>
                      AppValidations.validateConfirmPassword(
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