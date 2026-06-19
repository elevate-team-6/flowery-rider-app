import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/country_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/driver_entity.dart';

abstract interface class AuthRepoContract {
  Future<BaseResponse<DriverEntity>> signup(SignUpRequest request);
  Future<List<CountryEntity>> getCountries();
}
