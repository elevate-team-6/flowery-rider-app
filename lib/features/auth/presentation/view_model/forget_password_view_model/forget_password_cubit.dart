import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/forget_password_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/forget_password_use_case.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_state.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/use_cases/reset_password_use_case.dart';
import '../../../domain/use_cases/verify_reset_code_use_case.dart';
import 'forget_password_events.dart';

@injectable
class ForgetPasswordCubit extends BaseCubit<ForgetPasswordState, BaseUiEvent> {
  final ForgetPasswordUseCase _forgetPasswordUseCase;
  final VerifyResetCodeUseCase _verifyResetCodeUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  ForgetPasswordCubit({
    required ForgetPasswordUseCase forgetPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required VerifyResetCodeUseCase verifyResetCodeUseCase,
  }) : _forgetPasswordUseCase = forgetPasswordUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _verifyResetCodeUseCase = verifyResetCodeUseCase,
       super(const ForgetPasswordState());

  void doEvent(ForgetPasswordEvents event) {
    switch (event) {
      case ForgetPasswordEvent():
        _forgetPassword(event.email);
      case VerifyResetCodeEvent():
        _verifyResetCode(event.resetCode, event.email);
      case ResetPasswordEvent():
        _resetPassword(event.newPassword, event.email);
    }
  }

  void _forgetPassword(String email) async {
    emit(state.copyWith(forgotPasswordState: BaseState(isLoading: true)));
    emitUiEvent(ShowLoadingEvent());
    final response = await _forgetPasswordUseCase.call(email: email);
    emit(state.copyWith(forgotPasswordState: BaseState()));
    emitUiEvent(HideLoadingEvent());

    switch (response) {
      case SuccessBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(NavigateEvent(AppRoutes.verifyResetCode, arguments: email));
        emitUiEvent(
          DisplaySuccessEvent(AppStrings.verificationCodeSentToYourEmail.tr()),
        );
      case ErrorBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(DisplayErrorEvent(response.errorMessage));
    }
  }

  void _verifyResetCode(String resetCode, String email) async {
    emit(state.copyWith(verifyResetCodeState: BaseState(isLoading: true)));
    emitUiEvent(ShowLoadingEvent());
    final response = await _verifyResetCodeUseCase.call(resetCode: resetCode);
    emit(state.copyWith(verifyResetCodeState: BaseState()));
    emitUiEvent(HideLoadingEvent());
    switch (response) {
      case SuccessBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(NavigateEvent(AppRoutes.resetPassword, arguments: email));
        emitUiEvent(
          DisplaySuccessEvent(AppStrings.verificationCodeIsCorrect.tr()),
        );
      case ErrorBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(DisplayErrorEvent(response.errorMessage));
    }
  }

  void _resetPassword(String newPassword, String email) async {
    emit(state.copyWith(resetPasswordState: BaseState(isLoading: true)));
    emitUiEvent(ShowLoadingEvent());
    final response = await _resetPasswordUseCase.call(
      newPassword: newPassword,
      email: email,
    );
    emit(state.copyWith(resetPasswordState: BaseState()));
    emitUiEvent(HideLoadingEvent());
    switch (response) {
      case SuccessBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(
          NavigateEvent(
            AppRoutes.login,
            navigationType: NavigationType.pushAndRemoveUntil,
            predicate: (route) => false,
          ),
        );
        emitUiEvent(
          DisplaySuccessEvent(AppStrings.passwordResetSuccessfully.tr()),
        );
      case ErrorBaseResponse<ForgetPasswordEntity>():
        emitUiEvent(DisplayErrorEvent(response.errorMessage));
    }
  }
}
