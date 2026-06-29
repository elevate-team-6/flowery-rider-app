import 'package:flowery_rider_app/core/exceptions/missing_field_exception.dart';
import 'package:flowery_rider_app/core/utils/app_params.dart';
import 'package:flowery_rider_app/features/profile/domain/entities/driver_entity.dart';

class DriverResponseModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? gender;
  final String? photo;
  final String? vehicleType;
  final String? vehicleNumber;

  const DriverResponseModel({
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

  factory DriverResponseModel.fromJson(Map<String, dynamic> json) =>
      DriverResponseModel(
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
    id: requireField(id, 'id', owner: _owner),
    firstName: requireField(firstName, 'firstName', owner: _owner),
    lastName: requireField(lastName, 'lastName', owner: _owner),
    email: requireField(email, 'email', owner: _owner),
    phone: requireField(phone, 'phone', owner: _owner),
    gender: gender,
    photo: photo,
    vehicleType: vehicleType,
    vehicleNumber: vehicleNumber,
  );

  static const String _owner = 'DriverResponseModel';
}
