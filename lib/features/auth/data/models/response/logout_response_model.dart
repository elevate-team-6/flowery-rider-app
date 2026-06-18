import 'package:flowery_rider_app/core/utils/app_params.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/logout_entity.dart';

class LogoutResponseModel {
  final String? message;

  const LogoutResponseModel({this.message});

  factory LogoutResponseModel.fromJson(Map<String, dynamic> json) =>
      LogoutResponseModel(message: json[ApiParameters.message] as String?);

  LogoutEntity toEntity() => LogoutEntity(message: message);
}
