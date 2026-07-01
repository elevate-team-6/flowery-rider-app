import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_order_state_shipping_address_model.g.dart';

@JsonSerializable(createToJson: false)
class UpdateOrderStateShippingAddressModel extends Equatable {
  final String? street;
  final String? city;
  final String? phone;
  final String? lat;
  final String? long;

  const UpdateOrderStateShippingAddressModel({
    this.street,
    this.city,
    this.phone,
    this.lat,
    this.long,
  });

  factory UpdateOrderStateShippingAddressModel.fromJson(
    Map<String, dynamic> json,
  ) => _$UpdateOrderStateShippingAddressModelFromJson(json);

  ShippingAddressEntity toEntity() => ShippingAddressEntity(
    street: street ?? '_',
    city: city ?? '_',
    phone: phone ?? '',
    lat: lat ?? '',
    long: long ?? '',
  );

  @override
  List<Object?> get props => [street, city, phone, lat, long];
}
