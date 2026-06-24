import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_action_response_model.g.dart';

@JsonSerializable()
class OrderActionResponseModel extends Equatable {
  final String? message;
  @JsonKey(name: 'orders')
  final OrderActionDataModel? order;

  const OrderActionResponseModel({this.message, this.order});

  factory OrderActionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$OrderActionResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderActionResponseModelToJson(this);

  @override
  List<Object?> get props => [message, order];
}

@JsonSerializable()
class OrderActionDataModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String? user;
  final List<OrderActionItemModel>? orderItems;
  final num? totalPrice;
  final String? paymentType;
  final bool? isPaid;
  final String? paidAt;
  final bool? isDelivered;
  final String? state;
  final String? createdAt;
  final String? updatedAt;
  final String? orderNumber;
  @JsonKey(name: '__v')
  final int? v;
  final OrderActionShippingAddressModel? shippingAddress;

  const OrderActionDataModel({
    this.id,
    this.user,
    this.orderItems,
    this.totalPrice,
    this.paymentType,
    this.isPaid,
    this.paidAt,
    this.isDelivered,
    this.state,
    this.createdAt,
    this.updatedAt,
    this.orderNumber,
    this.v,
    this.shippingAddress,
  });

  factory OrderActionDataModel.fromJson(Map<String, dynamic> json) =>
      _$OrderActionDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderActionDataModelToJson(this);

  OrderEntity toEntity() => OrderEntity(
    id: id,
    orderNumber: orderNumber,
    totalPrice: totalPrice,
    state: state,
    createdAt: createdAt,
    paymentType: paymentType,
    user: UserEntity(id: user),
    orderItems: orderItems?.map((e) => e.toEntity()).toList(),
    shippingAddress: shippingAddress?.toEntity(),
  );

  @override
  List<Object?> get props => [
    id,
    user,
    orderItems,
    totalPrice,
    paymentType,
    isPaid,
    paidAt,
    isDelivered,
    state,
    createdAt,
    updatedAt,
    orderNumber,
    v,
    shippingAddress,
  ];
}

@JsonSerializable()
class OrderActionItemModel extends Equatable {
  final String? product;
  final num? price;
  final int? quantity;
  @JsonKey(name: '_id')
  final String? id;

  const OrderActionItemModel({
    this.product,
    this.price,
    this.quantity,
    this.id,
  });

  factory OrderActionItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderActionItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderActionItemModelToJson(this);

  OrderItemEntity toEntity() => OrderItemEntity(
    productName: product, // ID because only ID is returned
    price: price,
    quantity: quantity,
  );

  @override
  List<Object?> get props => [product, price, quantity, id];
}

@JsonSerializable()
class OrderActionShippingAddressModel extends Equatable {
  final String? street;
  final String? city;
  final String? phone;
  final String? lat;
  final String? long;

  const OrderActionShippingAddressModel({
    this.street,
    this.city,
    this.phone,
    this.lat,
    this.long,
  });

  factory OrderActionShippingAddressModel.fromJson(Map<String, dynamic> json) =>
      _$OrderActionShippingAddressModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$OrderActionShippingAddressModelToJson(this);

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
