import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/profile/domain/use_cases/change_password_use_case.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_events.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_states.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChangePasswordCubit extends BaseCubit<ChangePasswordState, BaseUiEvent> {
  final ChangePasswordUseCase _changePasswordUseCase;

  ChangePasswordCubit(this._changePasswordUseCase)
    : super(const ChangePasswordState());

  Future<void> doIntent(ChangePasswordEvent event) async {
    switch (event) {
      case SubmitChangePasswordEvent():
        await _changePassword(event.currentPassword, event.newPassword);
    }
  }

  Future<void> _changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    emit(state.copyWith(changePasswordState: const BaseState(isLoading: true)));

    final result = await _changePasswordUseCase(currentPassword, newPassword);
    switch (result) {
      case SuccessBaseResponse<String>():
        emit(state.copyWith(changePasswordState: const BaseState()));

        emitUiEvent(
          DisplaySuccessEvent(AppStrings.passwordChangedSuccess.tr()),
        );
      case ErrorBaseResponse<String>():
        emit(
          state.copyWith(
            changePasswordState: BaseState(errorMessage: result.errorMessage),
          ),
        );

        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }
}
