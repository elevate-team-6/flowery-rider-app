import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/logout_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/logout_view_model/logout_event.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/logout_view_model/logout_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogoutCubit extends BaseCubit<LogoutState, BaseUiEvent> {
  final LogoutUseCase _logoutUseCase;
  final SecureCacheHelper _secureCacheHelper;

  LogoutCubit(this._logoutUseCase, this._secureCacheHelper)
    : super(const LogoutState());

  void doIntent(LogoutEvents event) {
    switch (event) {
      case LogoutEvent():
        _logout();
    }
  }

  Future<void> _logout() async {
    emitUiEvent(ShowLoadingEvent());

    final result = await _logoutUseCase();

    emitUiEvent(HideLoadingEvent());

    switch (result) {
      case SuccessBaseResponse<LogoutEntity>():
        await _clearSession();
        emitUiEvent(DisplaySuccessEvent(AppStrings.logoutSuccess.tr()));
        emitUiEvent(NavigateEvent(AppRoutes.login));
      case ErrorBaseResponse<LogoutEntity>():
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _clearSession() async {
    await _secureCacheHelper.deleteData(key: AppKeys.tokenKey);
    await _secureCacheHelper.deleteData(key: AppKeys.rememberMeKey);
  }
}
