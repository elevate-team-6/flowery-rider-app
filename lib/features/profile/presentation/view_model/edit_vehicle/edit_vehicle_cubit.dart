import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/helpers/image_picker_helper.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/vehicle_type_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/get_vehicle_type_use_case.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_vehicle/edit_vehicle_events.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_vehicle/edit_vehicle_states.dart';
import 'package:injectable/injectable.dart';

@injectable
class EditVehicleCubit extends BaseCubit<EditVehicleState, BaseUiEvent> {
  final GetVehicleTypeUseCase getVehicleTypesUseCase;

  EditVehicleCubit({required this.getVehicleTypesUseCase})
    : super(const EditVehicleState());

  String? _vehicleTypeId;

  Future<void> doIntent(EditVehicleEvent event) async {
    switch (event) {
      case InitializeEditVehicleEvent():
        _initialize(event);

      case GetVehicleTypesEvent():
        await _getVehicleTypes();

      case ChangeVehicleTypeEvent():
        emit(
          state.copyWith(
            selectedVehicleType: event.vehicleType,
            hasChanges: true,
          ),
        );

      case ChangeVehicleNumberEvent():
        emit(state.copyWith(hasChanges: true));

      case PickDrivingLicenseImageEvent():
        await _pickDrivingLicenseImage();

      case RemoveDrivingLicenseImageEvent():
        emit(state.copyWith(clearDrivingLicenseImage: true, hasChanges: true));

      case EditVehicleSubmitEvent():
        _submit();
    }
  }

  void _initialize(InitializeEditVehicleEvent event) {
    _vehicleTypeId = event.vehicleTypeId;

    emit(state.copyWith(drivingLicenseImageUrl: event.vehicleLicenseUrl));
  }

  Future<void> _getVehicleTypes() async {
    emit(state.copyWith(vehicleTypesState: const BaseState(isLoading: true)));

    final result = await getVehicleTypesUseCase();

    switch (result) {
      case SuccessBaseResponse<List<VehicleTypeEntity>>():
        VehicleTypeEntity? selected;

        if (_vehicleTypeId != null) {
          try {
            selected = result.data?.firstWhere((e) => e.id == _vehicleTypeId);
          } catch (_) {}
        }

        emit(
          state.copyWith(
            vehicleTypesState: BaseState(data: result.data),
            selectedVehicleType: selected,
          ),
        );

      case ErrorBaseResponse<List<VehicleTypeEntity>>():
        emit(
          state.copyWith(
            vehicleTypesState: BaseState(errorMessage: result.errorMessage),
          ),
        );

        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _pickDrivingLicenseImage() async {
    try {
      final image = await ImagePickerHelper.pickFromGallery();

      if (image == null) return;

      emit(state.copyWith(drivingLicenseImage: image, hasChanges: true));
    } catch (e) {
      emitUiEvent(DisplayErrorEvent(e.toString()));
    }
  }

  void _submit() {
    emit(state.copyWith(hasChanges: false));

    emitUiEvent(DisplaySuccessEvent(AppStrings.editVehicleSuccessfly.tr()));
  }
}
