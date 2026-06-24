import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/signup_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/vehicle_response.dart';

abstract interface class AuthRemoteDataSourceContract {
  Future<BaseResponse<SignUpResponse>> signup(SignUpRequest request);
  Future<BaseResponse<VehicleResponse>> vehicles();
}
