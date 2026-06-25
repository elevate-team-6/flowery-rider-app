import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/helpers/image_picker_helper.dart';
import 'package:flowery_rider_app/core/entities/driver_entity.dart';
import 'package:flowery_rider_app/core/extensions/app_multipart_file.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/vehicle_type_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/get_vehicle_type_use_case.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/edit_vehicle_request.dart';
import 'package:flowery_rider_app/features/profile/domain/use_cases/edit_vehicle_use_case.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_vehicle/edit_vehicle_states.dart';
import 'package:injectable/injectable.dart';

import 'edit_vehicle_events.dart';

@injectable
class EditVehicleCubit extends BaseCubit<EditVehicleState, BaseUiEvent> {
  final GetVehicleTypeUseCase getVehicleTypesUseCase;
  final EditVehicleUseCase editVehicleUseCase;

  EditVehicleCubit({
    required this.getVehicleTypesUseCase,
    required this.editVehicleUseCase,
  }) : super(const EditVehicleState());

  Future<void> doIntent(EditVehicleEvent event) async {
    switch (event) {
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
        await _editVehicle(event.vehicleNumber);
    }
  }

  Future<void> _getVehicleTypes() async {
    emit(state.copyWith(vehicleTypesState: const BaseState(isLoading: true)));

    final result = await getVehicleTypesUseCase();

    switch (result) {
      case SuccessBaseResponse<List<VehicleTypeEntity>>():
        emit(state.copyWith(vehicleTypesState: BaseState(data: result.data)));

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

  Future<void> _editVehicle(String vehicleNumber) async {
    emit(state.copyWith(editVehicleState: const BaseState(isLoading: true)));

    final result = await editVehicleUseCase(
      EditVehicleRequest(
        vehicleType: state.selectedVehicleType?.id ?? '',
        vehicleNumber: vehicleNumber,
        vehicleLicense: state.drivingLicenseImage == null
            ? null
            : AppMultipartFile.fromPath(state.drivingLicenseImage!.path),
      ),
    );

    switch (result) {
      case SuccessBaseResponse<DriverEntity>():
        emit(
          state.copyWith(
            editVehicleState: const BaseState(),
            hasChanges: false,
          ),
        );

        emitUiEvent(DisplaySuccessEvent('Vehicle updated successfully'));

      case ErrorBaseResponse<DriverEntity>():
        emit(
          state.copyWith(
            editVehicleState: BaseState(errorMessage: result.errorMessage),
          ),
        );

        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }
}
