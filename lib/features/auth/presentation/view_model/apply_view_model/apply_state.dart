import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/country_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/driver_entity.dart';


class ApplyState extends Equatable {
  final BaseState<List<CountryEntity>> countriesState;
  final BaseState<DriverEntity> applyState;

  final CountryEntity? selectedCountry;
  final String? selectedVehicleType;
  final String? selectedGender;

  const ApplyState({
    this.countriesState = const BaseState(),
    this.applyState = const BaseState(),
    this.selectedCountry,
    this.selectedVehicleType,
    this.selectedGender,
  });

  ApplyState copyWith({
    BaseState<List<CountryEntity>>? countriesState,
    BaseState<DriverEntity>? applyState,
    CountryEntity? selectedCountry,
    String? selectedVehicleType,
    String? selectedGender,
  }) {
    return ApplyState(
      countriesState: countriesState ?? this.countriesState,
      applyState: applyState ?? this.applyState,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedVehicleType:
          selectedVehicleType ?? this.selectedVehicleType,
      selectedGender: selectedGender ?? this.selectedGender,
    );
  }

  @override
  List<Object?> get props => [
        countriesState,
        applyState,
        selectedCountry,
        selectedVehicleType,
        selectedGender,
      ];
}