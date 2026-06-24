import 'package:flowery_rider_app/features/profile/data/models/response/driver_model.dart';

class ProfileResponse {
  final String? message;
  final DriverModel? driver;

  const ProfileResponse({
    this.message,
    this.driver,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      message: json['message'],
      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'])
          : null,
    );
  }
}