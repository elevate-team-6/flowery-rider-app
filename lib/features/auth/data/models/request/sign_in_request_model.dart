import 'package:flowery_rider_app/core/utils/app_params.dart';

class SignInRequestModel {
  final String email;
  final String password;

  const SignInRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    ApiParameters.email: email,
    ApiParameters.password: password,
  };
}
