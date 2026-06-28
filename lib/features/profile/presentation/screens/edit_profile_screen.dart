import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/base_ui_event/base_ui_event.dart';
import '../../../../config/base_ui_handler/ui_event_handler_mixin.dart';
import '../../../../config/validations/app_validations.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../core/widgets/custom_gender_selector.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/request/edit_profile_request.dart';
import '../../domain/entities/driver_entity.dart';
import '../view_model/edit_profile_view_model/edit_profile_cubit.dart';
import '../view_model/edit_profile_view_model/edit_profile_events.dart';
import '../view_model/edit_profile_view_model/edit_profile_states.dart';
import '../widgets/edit_profile_avatar.dart';
import '../widgets/password_change_field.dart';

class EditProfileScreen extends StatefulWidget {
  final DriverEntity driver;

  const EditProfileScreen({super.key, required this.driver});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with UiEventHandler {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  StreamSubscription<BaseUiEvent>? _uiEventSubscription;

  @override
  void initState() {
    super.initState();
    final driver = widget.driver;
    _firstNameController.text = driver.firstName;
    _lastNameController.text = driver.lastName;
    _emailController.text = driver.email;
    _phoneController.text = PhoneFormatter.toLocal(driver.phone);
    final cubit = context.read<EditProfileCubit>();
    cubit.doEvent(InitEditProfileEvent(driver));
    _uiEventSubscription = cubit.eventStream.listen(handleUiEvent);

    // Notify the cubit on every edit so it can recompute the dirty state.
    for (final controller in [
      _firstNameController,
      _lastNameController,
      _emailController,
      _phoneController,
    ]) {
      controller.addListener(_onFormChanged);
    }
  }

  void _onFormChanged() {
    context.read<EditProfileCubit>().doEvent(
      EditProfileFormChangedEvent(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      ),
    );
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    context.read<EditProfileCubit>().doEvent(
      PickAndUploadPhotoEvent(File(picked.path)),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<EditProfileCubit>().doEvent(
      SubmitEditProfileEvent(
        EditProfileRequest(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: PhoneFormatter.toInternational(_phoneController.text.trim()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(titleSpacing: 0, title: Text(AppStrings.editProfile.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EditProfileAvatar(
                fallbackPhotoUrl: widget.driver.photo,
                onPickPhoto: _pickPhoto,
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _firstNameController,
                      labelText: AppStrings.firstName.tr(),
                      textInputAction: TextInputAction.next,
                      validator: AppValidations.validateFirstName,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _lastNameController,
                      labelText: AppStrings.lastName.tr(),
                      textInputAction: TextInputAction.next,
                      validator: AppValidations.validateLastName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: AppStrings.email.tr(),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: AppValidations.validateEmail,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                labelText: AppStrings.phoneNumber.tr(),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                validator: AppValidations.validatePhoneNumber,
              ),
              const SizedBox(height: 16),
              PasswordChangeField(
                onChangePressed: () =>
                    Navigator.pushNamed(context, AppRoutes.changePassword),
              ),
              const SizedBox(height: 24),
              BlocSelector<EditProfileCubit, EditProfileStates, String>(
                selector: (state) => state.gender,
                builder: (context, gender) {
                  return IgnorePointer(
                    child: CustomGenderSelector(
                      selectedGender: gender.isEmpty ? null : gender,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              BlocSelector<EditProfileCubit, EditProfileStates, bool>(
                selector: (state) => state.isFormChanged,
                builder: (context, isFormChanged) {
                  return ElevatedButton(
                    onPressed: isFormChanged ? _submit : null,
                    child: Text(AppStrings.update.tr()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
