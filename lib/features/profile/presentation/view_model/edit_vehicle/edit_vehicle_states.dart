import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/vehicle_type_entity.dart';

class EditVehicleState extends Equatable {
  final BaseState<void> editVehicleState;
  final BaseState<List<VehicleTypeEntity>> vehicleTypesState;

  final VehicleTypeEntity? selectedVehicleType;

  final String? drivingLicenseImageUrl;
  final File? drivingLicenseImage;

  final bool hasChanges;

  const EditVehicleState({
    this.editVehicleState = const BaseState(),
    this.vehicleTypesState = const BaseState(),
    this.selectedVehicleType,
    this.drivingLicenseImageUrl,
    this.drivingLicenseImage,
    this.hasChanges = false,
  });

  EditVehicleState copyWith({
    BaseState<void>? editVehicleState,
    BaseState<List<VehicleTypeEntity>>? vehicleTypesState,
    VehicleTypeEntity? selectedVehicleType,
    String? drivingLicenseImageUrl,
    File? drivingLicenseImage,
    bool? hasChanges,
    bool clearDrivingLicenseImage = false,
  }) {
    return EditVehicleState(
      editVehicleState: editVehicleState ?? this.editVehicleState,
      vehicleTypesState: vehicleTypesState ?? this.vehicleTypesState,
      selectedVehicleType: selectedVehicleType ?? this.selectedVehicleType,
      drivingLicenseImageUrl:
          drivingLicenseImageUrl ?? this.drivingLicenseImageUrl,
      drivingLicenseImage: clearDrivingLicenseImage
          ? null
          : drivingLicenseImage ?? this.drivingLicenseImage,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  @override
  List<Object?> get props => [
    editVehicleState,
    vehicleTypesState,
    selectedVehicleType,
    drivingLicenseImageUrl,
    drivingLicenseImage,
    hasChanges,
  ];
}
