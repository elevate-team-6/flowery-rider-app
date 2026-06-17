import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/country_entity.dart';

sealed class ApplyEvents extends Equatable {
  const ApplyEvents();

  @override
  List<Object?> get props => [];
}

/// Load Countries From Local Json
class GetCountriesEvent extends ApplyEvents {
  const GetCountriesEvent();
}

/// Change Selected Country
class ChangeCountryEvent extends ApplyEvents {
  final CountryEntity country;

  const ChangeCountryEvent(this.country);

  @override
  List<Object?> get props => [country];
}

/// Change Selected Vehicle Type
class ChangeVehicleTypeEvent extends ApplyEvents {
  final String vehicleType;

  const ChangeVehicleTypeEvent(this.vehicleType);

  @override
  List<Object?> get props => [vehicleType];
}

/// Change Selected Gender
class ChangeGenderEvent extends ApplyEvents {
  final String gender;

  const ChangeGenderEvent(this.gender);

  @override
  List<Object?> get props => [gender];
}

/// Submit Apply Request
class ApplyDriverEvent extends ApplyEvents {
  final SignUpRequest request;

  const ApplyDriverEvent(this.request);

  @override
  List<Object?> get props => [request];
}