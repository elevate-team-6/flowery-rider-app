import 'package:equatable/equatable.dart';

class DriverEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? gender;
  final String? photo;
  final String? vehicleType;
  final String? vehicleNumber;

  const DriverEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.gender,
    this.photo,
    this.vehicleType,
    this.vehicleNumber,
  });

  String get fullName =>
      [firstName, lastName].where((part) => part.isNotEmpty).join(' ');

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phone,
    gender,
    photo,
    vehicleType,
    vehicleNumber,
  ];
}
