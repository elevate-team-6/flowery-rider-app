import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

class ShippingAddressModel extends Equatable {
  final String? street;
  final String? city;
  final String? phone;
  final String? lat;
  final String? long;

  const ShippingAddressModel({
    this.street,
    this.city,
    this.phone,
    this.lat,
    this.long,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      street: json['street'] as String?,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      lat: json['lat'] as String?,
      long: json['long'] as String?,
    );
  }

  ShippingAddressEntity toEntity() => ShippingAddressEntity(
    street: street,
    city: city,
    phone: phone,
    lat: lat,
    long: long,
  );

  @override
  List<Object?> get props => [street, city, phone, lat, long];
}
