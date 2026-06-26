import '../../../../../../core/models/driver_model.dart';

class SignUpResponse {
  final String? message;
  final DriverModel? driver;
  final String? token;

  SignUpResponse({this.message, this.driver, this.token});

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      message: json['message'],
      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'])
          : null,
      token: json['token'],
    );
  }
}
