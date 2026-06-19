import 'package:flowery_rider_app/features/auth/domain/entites/driver_entity.dart';

class DriverModel {
  final String? country;
  final String? firstName;
  final String? lastName;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? vehicleLicense;
  final String? nid;
  final String? nidImg;
  final String? email;
  final String? gender;
  final String? phone;
  final String? photo;
  final String? role;
  final String? id;
  final DateTime? createdAt;

  DriverModel({
    this.country,
    this.firstName,
    this.lastName,
    this.vehicleType,
    this.vehicleNumber,
    this.vehicleLicense,
    this.nid,
    this.nidImg,
    this.email,
    this.gender,
    this.phone,
    this.photo,
    this.role,
    this.id,
    this.createdAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      country: json['country'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      vehicleType: json['vehicleType'],
      vehicleNumber: json['vehicleNumber'],
      vehicleLicense: json['vehicleLicense'],
      nid: json['NID'],
      nidImg: json['NIDImg'],
      email: json['email'],
      gender: json['gender'],
      phone: json['phone'],
      photo: json['photo'],
      role: json['role'],
      id: json['_id'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  DriverEntity toEntity() => DriverEntity(
    country: country ?? '',
    firstName: firstName ?? '',
    lastName: lastName ?? '',
    vehicleType: vehicleType??'',
    vehicleNumber: vehicleNumber??'',
    vehicleLicense: vehicleLicense??'',
    nid: nid??'',
    nidImg: nidImg??'',
    email: email??'',
    gender: gender??'',
    phone: phone??'',
    photo: photo??'',
    role: role??'',
    id: id??'',
  );
}
