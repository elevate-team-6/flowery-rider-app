import 'package:flowery_rider_app/core/utils/app_params.dart';

class EditProfileRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const EditProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    ApiParameters.firstName: firstName,
    ApiParameters.lastName: lastName,
    ApiParameters.email: email,
    ApiParameters.phone: phone,
  };
}
