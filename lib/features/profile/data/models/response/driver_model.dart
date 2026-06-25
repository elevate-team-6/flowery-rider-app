import 'package:flowery_rider_app/core/utils/app_params.dart';
import 'package:flowery_rider_app/features/profile/domain/entities/driver_entity.dart';

class DriverModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? gender;
  final String? photo;
  final String? vehicleType;
  final String? vehicleNumber;

  const DriverModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.gender,
    this.photo,
    this.vehicleType,
    this.vehicleNumber,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
    id: json[ApiParameters.id] as String?,
    firstName: json[ApiParameters.firstName] as String?,
    lastName: json[ApiParameters.lastName] as String?,
    email: json[ApiParameters.email] as String?,
    phone: json[ApiParameters.phone] as String?,
    gender: json[ApiParameters.gender] as String?,
    photo: json[ApiParameters.photo] as String?,
    vehicleType: json[ApiParameters.vehicleType] as String?,
    vehicleNumber: json[ApiParameters.vehicleNumber] as String?,
  );

  DriverEntity toEntity() => DriverEntity(
    id: id,
    firstName: firstName,
    lastName: lastName,
    email: email,
    phone: phone,
    gender: gender,
    photo: photo,
    vehicleType: vehicleType,
    vehicleNumber: vehicleNumber,
  );
}
