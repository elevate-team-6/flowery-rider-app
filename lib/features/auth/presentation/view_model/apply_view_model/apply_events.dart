import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/country_entity.dart';

sealed class ApplyEvent extends Equatable {
  const ApplyEvent();

  @override
  List<Object?> get props => [];
}

final class GetCountriesEvent extends ApplyEvent {
  const GetCountriesEvent();
}

final class ChangeCountryEvent extends ApplyEvent {
  final CountryEntity country;

  const ChangeCountryEvent(this.country);

  @override
  List<Object?> get props => [country];
}

final class ChangeVehicleTypeEvent extends ApplyEvent {
  final String vehicleType;

  const ChangeVehicleTypeEvent(this.vehicleType);

  @override
  List<Object?> get props => [vehicleType];
}

final class ChangeGenderEvent extends ApplyEvent {
  final String gender;

  const ChangeGenderEvent(this.gender);

  @override
  List<Object?> get props => [gender];
}

final class PickNationalIdImageEvent extends ApplyEvent {
  const PickNationalIdImageEvent();
}

final class PickDrivingLicenseImageEvent extends ApplyEvent {
  const PickDrivingLicenseImageEvent();
}

final class RemoveNationalIdImageEvent extends ApplyEvent {
  const RemoveNationalIdImageEvent();
}

final class RemoveDrivingLicenseImageEvent extends ApplyEvent {
  const RemoveDrivingLicenseImageEvent();
}

final class ApplyDriverEvent extends ApplyEvent {
  final SignUpRequest request;

  const ApplyDriverEvent(this.request);

  @override
  List<Object?> get props => [request];
}
