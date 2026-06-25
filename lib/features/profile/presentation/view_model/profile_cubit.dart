import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/profile/domain/use_cases/profile_use_case.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/profile_events.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/profile_states.dart';
import 'package:injectable/injectable.dart';

import '../../domain/use_cases/logout_use_case.dart';

@injectable
class ProfileCubit extends BaseCubit<ProfileStates, BaseUiEvent> {
  final LogoutUseCase _logoutUseCase;
    final ProfileUseCase _profileUseCase;
  ProfileCubit(this._logoutUseCase,this._profileUseCase) : super(const ProfileStates());

  void doEvent(ProfileEvents event) {
    switch (event) {
      case LogoutEvent():
        _logout();
      case GetProfileEvent():
       _getProfile();
    }
  }
   Future<void> _getProfile() async {
    emit(
      state.copyWith(
        profileState: const BaseState(
          isLoading: true,
        ),
      ),
    );

    final response = await _profileUseCase.call();

    switch (response) {
      case SuccessBaseResponse():
        emit(
          state.copyWith(
            profileState: BaseState(
              data: response.data,
            ),
          ),
        );

      case ErrorBaseResponse():
        emit(
          state.copyWith(
            profileState: const BaseState(),
          ),
        );

        emitUiEvent(
          DisplayErrorEvent(
            AppStrings.someThingWentWrong.tr(),
          ),
        );
    }
  }

  void _logout() async {
    emit(state.copyWith(logoutState: BaseState(isLoading: true)));
    final response = await _logoutUseCase.call();
    emit(state.copyWith(logoutState: BaseState()));
    emitUiEvent(
      NavigateEvent(AppRoutes.onboarding, navigationType: NavigationType.pop),
    );
    switch (response) {
      case SuccessBaseResponse():
        emitUiEvent(DisplaySuccessEvent(AppStrings.loginSuccess.tr()));
      case ErrorBaseResponse():
        emitUiEvent(DisplayErrorEvent(AppStrings.someThingWentWrong.tr()));
    }
    emitUiEvent(
      NavigateEvent(
        AppRoutes.onboarding,
        navigationType: NavigationType.pushAndRemoveUntil,
      ),
    );
  }
}
