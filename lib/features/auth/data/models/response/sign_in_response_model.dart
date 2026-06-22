import 'package:flowery_rider_app/core/utils/app_params.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/sign_in_entity.dart';

class SignInResponseModel {
  final String? message;
  final String? token;

  const SignInResponseModel({this.message, this.token});

  factory SignInResponseModel.fromJson(Map<String, dynamic> json) =>
      SignInResponseModel(
        message: json[ApiParameters.message] as String?,
        token: json[ApiParameters.token] as String?,
      );

  SignInEntity toEntity() => SignInEntity(message: message, token: token);
}
