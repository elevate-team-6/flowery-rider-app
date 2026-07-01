import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/sign_in_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginCubit extends BaseCubit<LoginState, BaseUiEvent> {
  final SignInUseCase _signInUseCase;
  final SecureCacheHelper _secureCacheHelper;

  LoginCubit(this._signInUseCase, this._secureCacheHelper)
    : super(const LoginState());

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

    final email =
        await _secureCacheHelper.readData(key: AppKeys.emailKey) ?? '';
    emit(state.copyWith(rememberMe: true));
    emitUiEvent(FillTextFieldEvent(email));
  }

  void _togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void _toggleRememberMe(bool value) {
    emit(state.copyWith(rememberMe: value));
  }

  Future<void> _signIn(SignInRequestModel request) async {
    emitUiEvent(ShowLoadingEvent());

    final result = await _signInUseCase(request);

    emitUiEvent(HideLoadingEvent());

    switch (result) {
      case SuccessBaseResponse<SignInEntity>():
        final entity = result.data ?? const SignInEntity();
        await _cacheUserSession(entity, request.email);
        emitUiEvent(DisplaySuccessEvent(AppStrings.loginSuccess.tr()));
        emitUiEvent(
          NavigateEvent(
            AppRoutes.mainLayout,
            navigationType: NavigationType.pushAndRemoveUntil,
          ),
        );
      case ErrorBaseResponse<SignInEntity>():
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _cacheUserSession(SignInEntity entity, String email) async {
    final token = entity.token;
    if (token != null && token.isNotEmpty) {
      await _secureCacheHelper.writeData(key: AppKeys.tokenKey, value: token);
    }

    // Temporary: Cache dummy rider data for Notification Firestore sync
    // This will be replaced by the Profile feature in the next sprint
    await _secureCacheHelper.writeData(
      key: AppKeys.userIdKey,
      value: "6a30164f992612ae599a9362",
    );
    await _secureCacheHelper.writeData(
      key: AppKeys.riderNameKey,
      value: "Ahmed Ali",
    );
    await _secureCacheHelper.writeData(
      key: AppKeys.riderPhoneKey,
      value: "+201010700888",
    );

    await _secureCacheHelper.writeData(
      key: AppKeys.rememberMeKey,
      value: state.rememberMe.toString(),
    );

    if (state.rememberMe) {
      await _secureCacheHelper.writeData(
        key: AppKeys.emailKey,
        value: email.trim(),
      );
    } else {
      await _secureCacheHelper.deleteData(key: AppKeys.emailKey);
    }
  }
}
