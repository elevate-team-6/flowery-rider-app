import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../../core/utils/app_constants.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  @JsonKey(name: '_id')
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

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() => UserEntity(
    id: id,
    fullName: '$firstName $lastName',
    phone: phone,
    photo: (photo != null && photo!.isNotEmpty)
        ? (photo!.startsWith('http')
              ? photo
              : '${AppConstants.imageBaseUrl}$photo')
        : photo,
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
