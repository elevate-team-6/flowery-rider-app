import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/helpers/phone_extension.dart';
import 'package:flowery_rider_app/core/extensions/app_multipart_file.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flowery_rider_app/core/widgets/custom_gender_selector.dart';
import 'package:flowery_rider_app/core/widgets/custom_snack_bar.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/apply_view_model/apply_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/apply_view_model/apply_events.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/apply_view_model/apply_state.dart';
import 'package:flowery_rider_app/features/auth/presentation/widgets/apply_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApplyPage extends StatefulWidget {
  const ApplyPage({super.key});

  @override
  State<ApplyPage> createState() => _ApplyPageState();
}

class _ApplyPageState extends State<ApplyPage> {
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final drivingLicenseController = TextEditingController();
  final lastNameController = TextEditingController();
  final vehicleNumberController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final nidController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ApplyCubit>();
    cubit.doIntent(const GetCountriesEvent());
    _eventSubscription = cubit.eventStream.listen(_handleUiEvent);
  }

  void _handleUiEvent(BaseUiEvent event) {
    switch (event) {
      case DisplayErrorEvent():
        CustomSnackBar.showErrorMessage(event.errorMessage.tr());
      case NavigateEvent():
        Navigator.pushReplacementNamed(context, event.routeName);
      default:
        break;
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    firstNameController.dispose();
    nationalIdController.dispose();
    drivingLicenseController.dispose();
    lastNameController.dispose();
    vehicleNumberController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nidController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new_outlined),
        title: Text(AppStrings.apply.tr()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.welcome.tr(), style: AppTextStyles.black20500),
              SizedBox(height: 8.h),
              Text(
                AppStrings.applyDescription.tr(),
                style: AppTextStyles.gray16400,
              ),
              SizedBox(height: 32.h),

              BlocBuilder<ApplyCubit, ApplyState>(
                builder: (context, state) {
                  nationalIdController.text =
                      state.nationalIdImage?.path.split('/').last ?? '';

                  drivingLicenseController.text =
                      state.drivingLicenseImage?.path.split('/').last ?? '';

                  return ApplyForm(
                    formKey: formKey,
                    nationalIdImage: state.nationalIdImage,
                    drivingLicenseImage: state.drivingLicenseImage,
                    onPickNationalIdImage: () {
                      context.read<ApplyCubit>().doIntent(
                        const PickNationalIdImageEvent(),
                      );
                    },
                    onPickDrivingLicenseImage: () {
                      context.read<ApplyCubit>().doIntent(
                        const PickDrivingLicenseImageEvent(),
                      );
                    },
                    countries: state.countriesState.data ?? [],
                    selectedCountry: state.selectedCountry,
                    onCountryChanged: (country) {
                      if (country != null) {
                        context.read<ApplyCubit>().doIntent(
                          ChangeCountryEvent(country),
                        );
                      }
                    },
                    selectedVehicleType: state.selectedVehicleType,
                    onVehicleTypeChanged: (type) {
                      if (type != null) {
                        context.read<ApplyCubit>().doIntent(
                          ChangeVehicleTypeEvent(type),
                        );
                      }
                    },
                    firstNameController: firstNameController,
                    lastNameController: lastNameController,
                    vehicleNumberController: vehicleNumberController,
                    emailController: emailController,
                    phoneController: phoneController,
                    nidController: nidController,
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                    nationalIdController: nationalIdController,
                    drivingLicenseController: drivingLicenseController,
                  );
                },
              ),

              SizedBox(height: 16.h),

              BlocBuilder<ApplyCubit, ApplyState>(
                builder: (context, state) {
                  return CustomGenderSelector(
                    selectedGender: state.selectedGender,
                    onChanged: (gender) {
                      if (gender != null) {
                        context.read<ApplyCubit>().doIntent(
                          ChangeGenderEvent(gender),
                        );
                      }
                    },
                  );
                },
              ),

              SizedBox(height: 16.h),

              BlocBuilder<ApplyCubit, ApplyState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.applyState.isLoading
                        ? null
                        : () {
                            if (!formKey.currentState!.validate()) return;

                            if (state.selectedGender == null) {
                              CustomSnackBar.showErrorMessage(
                                AppStrings.pleaseSelectGender.tr(),
                              );
                              return;
                            }

                            if (state.nationalIdImage == null ||
                                state.drivingLicenseImage == null) {
                              CustomSnackBar.showErrorMessage(
                                AppStrings.uploadImageRequired.tr(),
                              );
                              return;
                            }

                            context.read<ApplyCubit>().doIntent(
                              ApplyDriverEvent(
                                SignUpRequest(
                                  country: state.selectedCountry?.name,
                                  firstName: firstNameController.text,
                                  lastName: lastNameController.text,
                                  vehicleType: '6856f4a1c8e2ab1234567890',
                                  vehicleNumber: vehicleNumberController.text,
                                  nid: nidController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                  rePassword: confirmPasswordController.text,
                                  gender: state.selectedGender,
                                  phone: phoneController.text.toEgyptianPhone(),
                                  vehicleLicense: AppMultipartFile(
                                    path: state.drivingLicenseImage!.path,
                                  ),
                                  nidImg: AppMultipartFile(
                                    path: state.nationalIdImage!.path,
                                  ),
                                ),
                              ),
                            );
                          },
                    child: state.applyState.isLoading
                        ? const CircularProgressIndicator()
                        : Text(AppStrings.continueText),
                  );
                },
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
