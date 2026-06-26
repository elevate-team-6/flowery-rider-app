import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/helpers/image_picker_helper.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/apply_use_case.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/get_countries_use_case.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/get_vehicle_type_use_case.dart';
import 'package:flowery_rider_app/core/entities/driver_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/vehicle_type_entity.dart';
import 'package:injectable/injectable.dart';

import 'apply_events.dart';
import 'apply_state.dart';

@injectable
class ApplyCubit extends BaseCubit<ApplyState, BaseUiEvent> {
  final GetCountriesUseCase getCountriesUseCase;
  final ApplyUseCase applyUseCase;
  final GetVehicleTypeUseCase getVehicleTypesUseCase;

  ApplyCubit({
    required this.getCountriesUseCase,
    required this.applyUseCase,
    required this.getVehicleTypesUseCase,
  }) : super(const ApplyState());

  Future<void> doIntent(ApplyEvent event) async {
    switch (event) {
      case GetCountriesEvent():
        await _getCountries();

      case ChangeCountryEvent():
        emit(state.copyWith(selectedCountry: event.country));

      case ChangeVehicleTypeEvent():
        emit(state.copyWith(selectedVehicleType: event.vehicleType));

      case ChangeGenderEvent():
        emit(state.copyWith(selectedGender: event.gender));

      case PickNationalIdImageEvent():
        await _pickNationalIdImage();

      case PickDrivingLicenseImageEvent():
        await _pickDrivingLicenseImage();

      case RemoveNationalIdImageEvent():
        emit(state.copyWith(clearNationalIdImage: true));

      case RemoveDrivingLicenseImageEvent():
        emit(state.copyWith(clearDrivingLicenseImage: true));

      case ApplyDriverEvent():
        await _apply(event.request);
      case GetVehicleTypesEvent():
        await _getVehicleTypes();
    }
  }

  Future<void> _getCountries() async {
    emit(state.copyWith(countriesState: const BaseState(isLoading: true)));
    try {
      final countries = await getCountriesUseCase();

      emit(state.copyWith(countriesState: BaseState(data: countries)));
    } catch (e) {
      emit(
        state.copyWith(countriesState: BaseState(errorMessage: e.toString())),
      );

      emitUiEvent(DisplayErrorEvent(e.toString()));
    }
  }

  Future<void> _pickNationalIdImage() async {
    try {
      final image = await ImagePickerHelper.pickFromGallery();

      if (image == null) return;

      emit(state.copyWith(nationalIdImage: image));
    } catch (e) {
      emitUiEvent(DisplayErrorEvent(e.toString()));
    }
  }

  Future<void> _pickDrivingLicenseImage() async {
    try {
      final image = await ImagePickerHelper.pickFromGallery();

      if (image == null) return;

      emit(state.copyWith(drivingLicenseImage: image));
    } catch (e) {
      emitUiEvent(DisplayErrorEvent(e.toString()));
    }
  }

  Future<void> _apply(SignUpRequest request) async {
    emit(state.copyWith(applyState: const BaseState(isLoading: true)));

    final result = await applyUseCase(request);

    switch (result) {
      case SuccessBaseResponse<DriverEntity>():
        emit(
          state.copyWith(
            applyState: BaseState(data: result.data, isLoading: false),
          ),
        );

        emitUiEvent(NavigateEvent(AppRoutes.submit));

      case ErrorBaseResponse<DriverEntity>():
        emit(
          state.copyWith(
            applyState: BaseState(
              errorMessage: result.errorMessage,
              isLoading: false,
            ),
          ),
        );

        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _getVehicleTypes() async {
    emit(state.copyWith(vehicleTypesState: const BaseState(isLoading: true)));

    final result = await getVehicleTypesUseCase();

    switch (result) {
      case SuccessBaseResponse<List<VehicleTypeEntity>>():
        emit(
          state.copyWith(
            vehicleTypesState: BaseState(data: result.data, isLoading: false),
          ),
        );

      case ErrorBaseResponse<List<VehicleTypeEntity>>():
        emit(
          state.copyWith(
            vehicleTypesState: BaseState(
              errorMessage: result.errorMessage,
              isLoading: false,
            ),
          ),
        );

        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }
}
