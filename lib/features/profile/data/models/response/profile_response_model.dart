import 'package:flowery_rider_app/core/utils/app_params.dart';

import 'driver_model.dart';

class ProfileResponseModel {
  final String? message;
  final DriverModel? driver;

  const ProfileResponseModel({this.message, this.driver});

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final driverJson = json[ApiParameters.driver] as Map<String, dynamic>?;
    return ProfileResponseModel(
      message: json[ApiParameters.message] as String?,
      driver: driverJson != null ? DriverModel.fromJson(driverJson) : null,
    );
  }
}
