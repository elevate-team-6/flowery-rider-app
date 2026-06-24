import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_entity.g.dart';

class PendingOrdersEntity extends Equatable {
  final String? message;
  final List<OrderEntity>? orders;

  const PendingOrdersEntity({this.message, this.orders});

  @override
  List<Object?> get props => [message, orders];
}

@JsonSerializable()
class OrderEntity extends Equatable {
  final String? id;
  final String? orderNumber;
  final num? totalPrice;
  final String? state;
  final String? createdAt;
  final String? paymentType;
  final UserEntity? user;
  final StoreEntity? store;
  final List<OrderItemEntity>? orderItems;
  final ShippingAddressEntity? shippingAddress;

  const OrderEntity({
    this.id,
    this.orderNumber,
    this.totalPrice,
    this.state,
    this.createdAt,
    this.paymentType,
    this.user,
    this.store,
    this.orderItems,
    this.shippingAddress,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) =>
      _$OrderEntityFromJson(json);

  Map<String, dynamic> toJson() => _$OrderEntityToJson(this);

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    totalPrice,
    state,
    createdAt,
    paymentType,
    user,
    store,
    orderItems,
    shippingAddress,
  ];
}

@JsonSerializable()
class UserEntity extends Equatable {
  final String? id;
  final String? fullName;
  final String? phone;
  final String? photo;

  const UserEntity({this.id, this.fullName, this.phone, this.photo});

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  @override
  List<Object?> get props => [id, fullName, phone, photo];
}

@JsonSerializable()
class StoreEntity extends Equatable {
  final String? name;
  final String? image;
  final String? address;
  final String? phoneNumber;
  final String? lat;
  final String? long;

  const StoreEntity({
    this.name,
    this.image,
    this.address,
    this.phoneNumber,
    this.lat,
    this.long,
  });

  factory StoreEntity.fromJson(Map<String, dynamic> json) =>
      _$StoreEntityFromJson(json);

  Map<String, dynamic> toJson() => _$StoreEntityToJson(this);

  @override
  List<Object?> get props => [name, image, address, phoneNumber, lat, long];
}

@JsonSerializable()
class OrderItemEntity extends Equatable {
  final String? productName;
  final String? productImage;
  final num? price;
  final int? quantity;

  const OrderItemEntity({
    this.productName,
    this.productImage,
    this.price,
    this.quantity,
  });

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) =>
      _$OrderItemEntityFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemEntityToJson(this);

  @override
  List<Object?> get props => [productName, productImage, price, quantity];
}

@JsonSerializable()
class ShippingAddressEntity extends Equatable {
  final String? street;
  final String? city;
  final String? phone;
  final String? lat;
  final String? long;

  const ShippingAddressEntity({
    this.street,
    this.city,
    this.phone,
    this.lat,
    this.long,
  });

  factory ShippingAddressEntity.fromJson(Map<String, dynamic> json) =>
      _$ShippingAddressEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ShippingAddressEntityToJson(this);

  @override
  List<Object?> get props => [street, city, phone, lat, long];
}
