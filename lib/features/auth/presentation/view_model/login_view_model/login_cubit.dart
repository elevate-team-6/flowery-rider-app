import 'dart:async';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/sign_in_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_side_effect.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  final SignInUseCase _signInUseCase;
  final SecureCacheHelper _secureCacheHelper;

  LoginCubit(this._signInUseCase, this._secureCacheHelper)
    : super(const LoginState());

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final StreamController<LoginSideEffect> _sideEffectController =
      StreamController<LoginSideEffect>.broadcast();
  Stream<LoginSideEffect> get sideEffects => _sideEffectController.stream;

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

    _sideEffectController.add(const ShowLoadingEffect());

    final result = await _signInUseCase(request);

    _sideEffectController.add(const HideLoadingEffect());

    switch (result) {
      case SuccessBaseResponse<SignInEntity>():
        final entity = result.data ?? const SignInEntity();
        await _cacheUserSession(entity);
        _sideEffectController.add(const LoginSuccessEffect());
      case ErrorBaseResponse<SignInEntity>():
        _sideEffectController.add(LoginFailureEffect(result.errorMessage));
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
    _sideEffectController.close();
    return super.close();
  }
}
