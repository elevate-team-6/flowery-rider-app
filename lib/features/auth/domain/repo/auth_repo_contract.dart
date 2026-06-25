import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/sign_in_entity.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/country_entity.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/driver_entity.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/vehicle_type_entity.dart';

import '../entities/forget_password_entity.dart';

abstract interface class AuthRepoContract {
  Future<BaseResponse<SignInEntity>> signIn(SignInRequestModel request);
  Future<BaseResponse<DriverEntity>> signup(SignUpRequest request);
  Future<List<CountryEntity>> getCountries();
  Future<BaseResponse<List<VehicleTypeEntity>>> getVehicles();
  // Forget Password contract functions
  Future<BaseResponse<ForgetPasswordEntity>> forgotPassword({
    required String email,
  });

  Future<BaseResponse<ForgetPasswordEntity>> verifyResetCode({
    required String resetCode,
  });

  Future<BaseResponse<ForgetPasswordEntity>> resetPassword({
    required String email,
    required String newPassword,
  });
}
