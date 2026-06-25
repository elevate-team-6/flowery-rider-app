import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

class UserModel extends Equatable {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? gender;
  final String? phone;
  final String? photo;
  final String? passwordChangedAt;
  final bool? resetCodeVerified;

  const UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.gender,
    this.phone,
    this.photo,
    this.passwordChangedAt,
    this.resetCodeVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
      photo: json['photo'] as String?,
      passwordChangedAt: json['passwordChangedAt'] as String?,
      resetCodeVerified: json['resetCodeVerified'] as bool?,
    );
  }

  UserEntity toEntity() => UserEntity(
    id: id,
    fullName: '$firstName $lastName',
    phone: phone,
    photo: photo,
  );

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    gender,
    phone,
    photo,
    passwordChangedAt,
    resetCodeVerified,
  ];
}
