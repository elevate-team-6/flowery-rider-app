import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/country_entity.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/driver_entity.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/vehicle_type_entity.dart';

class ApplyState extends Equatable {
  final BaseState<List<CountryEntity>> countriesState;
  final BaseState<DriverEntity> applyState;
  final BaseState<List<VehicleTypeEntity>> vehicleTypesState;
  final CountryEntity? selectedCountry;
  final VehicleTypeEntity? selectedVehicleType;
  final String? selectedGender;

  final File? nationalIdImage;
  final File? drivingLicenseImage;

  const ApplyState({
    this.countriesState = const BaseState(),
    this.applyState = const BaseState(),
    this.vehicleTypesState = const BaseState(),
    this.selectedCountry,
    this.selectedVehicleType,
    this.selectedGender,
    this.nationalIdImage,
    this.drivingLicenseImage,
  });

  ApplyState copyWith({
    BaseState<List<CountryEntity>>? countriesState,
    BaseState<List<VehicleTypeEntity>>? vehicleTypesState,
    BaseState<DriverEntity>? applyState,
    CountryEntity? selectedCountry,
    VehicleTypeEntity? selectedVehicleType,
    String? selectedGender,
    File? nationalIdImage,
    File? drivingLicenseImage,
    bool clearNationalIdImage = false,
    bool clearDrivingLicenseImage = false,
  }) {
    return ApplyState(
      vehicleTypesState: vehicleTypesState ?? this.vehicleTypesState,
      countriesState: countriesState ?? this.countriesState,
      applyState: applyState ?? this.applyState,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedVehicleType: selectedVehicleType ?? this.selectedVehicleType,
      selectedGender: selectedGender ?? this.selectedGender,
      nationalIdImage: clearNationalIdImage
          ? null
          : nationalIdImage ?? this.nationalIdImage,
      drivingLicenseImage: clearDrivingLicenseImage
          ? null
          : drivingLicenseImage ?? this.drivingLicenseImage,
    );
  }

  @override
  List<Object?> get props => [
    countriesState,
    vehicleTypesState,
    applyState,
    selectedCountry,
    selectedVehicleType,
    selectedGender,
    nationalIdImage,
    drivingLicenseImage,
  ];
}
