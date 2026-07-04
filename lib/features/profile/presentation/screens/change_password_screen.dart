import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/widgets/custom_snack_bar.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_cubit.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_states.dart';
import 'package:flowery_rider_app/features/profile/presentation/widgets/change_password_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();

    _eventSubscription = context.read<ChangePasswordCubit>().eventStream.listen(
      _handleUiEvent,
    );
  }

  void _handleUiEvent(BaseUiEvent event) {
    switch (event) {
      case DisplaySuccessEvent():
        CustomSnackBar.showSuccessMessage(
          AppStrings.passwordChangedSuccess.tr(),
        );

        Navigator.pop(context);

      case DisplayErrorEvent():
        CustomSnackBar.showErrorMessage(event.errorMessage.tr());

      default:
        break;
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();

    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(AppStrings.resetPassword.tr()),
      ),
      body: BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
        builder: (context, state) {
          return ChangePasswordForm(
            formKey: _formKey,
            currentPasswordController: _currentPasswordController,
            newPasswordController: _newPasswordController,
            confirmPasswordController: _confirmPasswordController,
          );
        },
      ),
    );
  }
}
