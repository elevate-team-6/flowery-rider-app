import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flowery_rider_app/core/widgets/custom_gender_selector.dart';
import 'package:flowery_rider_app/features/auth/presentation/widgets/apply_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApplyPage extends StatefulWidget {
  const ApplyPage({super.key});

  @override
  State<ApplyPage> createState() => _ApplyPageState();
}

class _ApplyPageState extends State<ApplyPage> {
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final vehicleNumberController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final nidController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios_new_outlined),
        title: Text(AppStrings.apply),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.welcome, style: AppTextStyles.black20500),
              SizedBox(height: 8.h),
              Text(AppStrings.applyDescription, style: AppTextStyles.gray16400),
              SizedBox(height: 32.h),

              ApplyForm(
                formKey: formKey,
                firstNameController: firstNameController,
                lastNameController: lastNameController,
                vehicleNumberController: vehicleNumberController,
                emailController: emailController,
                phoneController: phoneController,
                nidController: nidController,
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
              ),
              CustomGenderSelector(selectedGender: ''),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // call cubit
                  }
                },
                child: Text(AppStrings.continueText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
