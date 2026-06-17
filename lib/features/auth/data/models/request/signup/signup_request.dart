import 'package:flowery_rider_app/core/extensions/app_multipart_file.dart';

class SignUpRequest {
  final String? country;
  final String? firstName;
  final String? lastName;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? nid;
  final String? email;
  final String? password;
  final String? rePassword;
  final String? gender;
  final String? phone;
  final AppMultipartFile? vehicleLicense;
  final AppMultipartFile? nidImg;

  const SignUpRequest({
    this.country,
    this.firstName,
    this.lastName,
    this.vehicleType,
    this.vehicleNumber,
    this.nid,
    this.email,
    this.password,
    this.rePassword,
    this.gender,
    this.phone,
    this.vehicleLicense,
    this.nidImg,
  });

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'firstName': firstName,
      'lastName': lastName,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'NID': nid,
      'email': email,
      'password': password,
      'rePassword': rePassword,
      'gender': gender,
      'phone': phone,
    };
  }
}
