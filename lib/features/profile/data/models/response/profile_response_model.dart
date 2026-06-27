import 'package:flowery_rider_app/core/models/driver_model.dart';

class ProfileResponseModel {
  final String? message;
  final DriverModel? driver;

  const ProfileResponseModel({this.message, this.driver});

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      message: json['message'] as String?,
      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
    );
  }
}
