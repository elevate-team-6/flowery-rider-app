import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/base_cubit/base_cubit.dart';
import '../../../../../config/base_response/base_response.dart';
import '../../../../../config/base_state/base_state.dart';
import '../../../../../config/base_ui_event/base_ui_event.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../domain/entities/driver_entity.dart';
import '../../../domain/use_cases/edit_profile_use_case.dart';
import '../../../domain/use_cases/get_profile_data_use_case.dart';
import '../../../domain/use_cases/upload_photo_use_case.dart';
import 'edit_profile_events.dart';
import 'edit_profile_form.dart';
import 'edit_profile_states.dart';

/// Maximum profile photo size accepted by the backend (4 MB).
const int _maxPhotoSizeInBytes = 4 * 1024 * 1024;

@injectable
class EditProfileCubit extends BaseCubit<EditProfileStates, BaseUiEvent> {
  final EditProfileUseCase _editProfileUseCase;
  final UploadPhotoUseCase _uploadPhotoUseCase;
  final GetProfileDataUseCase _getProfileDataUseCase;

  EditProfileCubit(
    this._editProfileUseCase,
    this._uploadPhotoUseCase,
    this._getProfileDataUseCase,
  ) : super(const EditProfileStates());

  void doEvent(EditProfileEvents event) {
    switch (event) {
      case InitEditProfileEvent():
        _init(event.driver);
      case EditProfileFormChangedEvent():
        _onFormChanged(event);
      case PickAndUploadPhotoEvent():
        _uploadPhoto(event);
      case SubmitEditProfileEvent():
        _submit(event);
    }
  }

  void _init(DriverEntity driver) {
    emit(
      state.copyWith(
        driver: driver,
        gender: driver.gender ?? '',
        form: EditProfileForm.fromDriver(driver),
      ),
    );
  }

  void _onFormChanged(EditProfileFormChangedEvent event) {
    final form = state.form;
    if (form == null) return;
    emit(
      state.copyWith(
        form: form.copyWith(
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          phone: event.phone,
        ),
      ),
    );
  }

  Future<void> _uploadPhoto(PickAndUploadPhotoEvent event) async {
    if (await event.photo.length() > _maxPhotoSizeInBytes) {
      emitUiEvent(DisplayErrorEvent(AppStrings.photoTooLarge.tr()));
      return;
    }

    emit(state.copyWith(uploadState: const BaseState(isLoading: true)));
    emitUiEvent(ShowLoadingEvent());
    final response = await _uploadPhotoUseCase.call(event.photo);

    switch (response) {
      case SuccessBaseResponse<DriverEntity>():
        final refreshed = await _getProfileDataUseCase.call();
        emitUiEvent(HideLoadingEvent());
        final freshDriver = switch (refreshed) {
          SuccessBaseResponse<DriverEntity>() =>
            refreshed.data ?? response.data ?? state.driver,
          ErrorBaseResponse<DriverEntity>() => response.data ?? state.driver,
        };
        emit(
          state.copyWith(
            driver: freshDriver,
            uploadState: BaseState(data: freshDriver),
            form: state.form?.copyWith(photoChanged: true),
          ),
        );
        emitUiEvent(DisplaySuccessEvent(AppStrings.photoUpdatedSuccess.tr()));
      case ErrorBaseResponse<DriverEntity>():
        emitUiEvent(HideLoadingEvent());
        emit(
          state.copyWith(
            uploadState: BaseState(errorMessage: response.errorMessage),
          ),
        );
        emitUiEvent(DisplayErrorEvent(response.errorMessage));
    }
  }

  Future<void> _submit(SubmitEditProfileEvent event) async {
    emit(state.copyWith(editState: const BaseState(isLoading: true)));
    emitUiEvent(ShowLoadingEvent());
    final response = await _editProfileUseCase.call(event.request);
    emitUiEvent(HideLoadingEvent());

    switch (response) {
      case SuccessBaseResponse<DriverEntity>():
        emit(
          state.copyWith(
            driver: response.data,
            editState: BaseState(data: response.data),
          ),
        );
        emitUiEvent(DisplaySuccessEvent(AppStrings.editProfileSuccessfly.tr()));
        emitUiEvent(
          NavigateEvent(
            '',
            navigationType: NavigationType.pop,
            arguments: response.data,
          ),
        );
      case ErrorBaseResponse<DriverEntity>():
        emit(
          state.copyWith(
            editState: BaseState(errorMessage: response.errorMessage),
          ),
        );
        emitUiEvent(DisplayErrorEvent(response.errorMessage));
    }
  }
}
