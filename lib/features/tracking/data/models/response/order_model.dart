import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

import 'order_item_model.dart';
import 'shipping_address_model.dart';
import 'store_model.dart';
import 'user_model.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final UserModel? user;
  final List<OrderItemModel>? orderItems;
  final num? totalPrice;
  final String? paymentType;
  final bool? isPaid;
  final bool? isDelivered;
  final String? state;
  final String? createdAt;
  final String? updatedAt;
  final String? orderNumber;
  @JsonKey(name: '__v')
  final int? v;
  final StoreModel? store;
  final ShippingAddressModel? shippingAddress;
  final String? paidAt;

  const OrderModel({
    this.id,
    this.user,
    this.orderItems,
    this.totalPrice,
    this.paymentType,
    this.isPaid,
    this.isDelivered,
    this.state,
    this.createdAt,
    this.updatedAt,
    this.orderNumber,
    this.v,
    this.store,
    this.shippingAddress,
    this.paidAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderEntity toEntity() => OrderEntity(
    id: id,
    orderNumber: orderNumber,
    totalPrice: totalPrice,
    state: state,
    createdAt: createdAt,
    paymentType: paymentType,
    user: user?.toEntity(),
    store: store?.toEntity(),
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
    isDelivered,
    state,
    createdAt,
    updatedAt,
    orderNumber,
    v,
    store,
    shippingAddress,
    paidAt,
  ];
}
