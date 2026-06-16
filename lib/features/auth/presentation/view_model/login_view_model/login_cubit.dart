import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/sign_in_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'login_event.dart';
part 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  final SignInUseCase _signInUseCase;
  final SecureCacheHelper _secureCacheHelper;

  LoginCubit(this._signInUseCase, this._secureCacheHelper)
    : super(const LoginState());

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// Single entry point for all UI interactions.
  void doIntent(LoginEvents event) {
    switch (event) {
      case LoadRememberedEmailEvent():
        _loadRememberedEmail();
      case TogglePasswordVisibilityEvent():
        _togglePasswordVisibility();
      case ToggleRememberMeEvent(:final value):
        _toggleRememberMe(value);
      case LoginEvent(:final request):
        _signIn(request);
    }
  }

  Future<void> _loadRememberedEmail() async {
    final isRemembered =
        await _secureCacheHelper.readData(key: AppKeys.rememberMeKey) == 'true';
    if (!isRemembered) return;

    emailController.text =
        await _secureCacheHelper.readData(key: AppKeys.emailKey) ?? '';
    emit(state.copyWith(rememberMe: true));
  }

  void _togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void _toggleRememberMe(bool value) {
    emit(state.copyWith(rememberMe: value));
  }

  Future<void> _signIn(SignInRequestModel request) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    emit(state.copyWith(status: LoginStatus.loading));

    final result = await _signInUseCase(request);

    switch (result) {
      case SuccessBaseResponse<SignInEntity>():
        final entity = result.data ?? const SignInEntity();
        await _cacheUserSession(entity);
        emit(state.copyWith(status: LoginStatus.success, entity: entity));
      case ErrorBaseResponse<SignInEntity>():
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: result.errorMessage,
          ),
        );
    }
  }

  Future<void> _cacheUserSession(SignInEntity entity) async {
    final token = entity.token;
    if (token != null && token.isNotEmpty) {
      await _secureCacheHelper.writeData(key: AppKeys.tokenKey, value: token);
    }
    await _secureCacheHelper.writeData(
      key: AppKeys.rememberMeKey,
      value: state.rememberMe.toString(),
    );

    // Persist the email only while "Remember me" is on, otherwise clear it.
    if (state.rememberMe) {
      await _secureCacheHelper.writeData(
        key: AppKeys.emailKey,
        value: emailController.text.trim(),
      );
    } else {
      await _secureCacheHelper.deleteData(key: AppKeys.emailKey);
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
