import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entites/order_entity.dart';

import 'order_item_model.dart';
import 'shipping_address_model.dart';
import 'store_model.dart';
import 'user_model.dart';

class OrderModel extends Equatable {
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] as String?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      orderItems: (json['orderItems'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPrice: json['totalPrice'] as num?,
      paymentType: json['paymentType'] as String?,
      isPaid: json['isPaid'] as bool?,
      isDelivered: json['isDelivered'] as bool?,
      state: json['state'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      orderNumber: json['orderNumber'] as String?,
      v: json['__v'] as int?,
      store: json['store'] != null
          ? StoreModel.fromJson(json['store'] as Map<String, dynamic>)
          : null,
      shippingAddress: json['shippingAddress'] != null
          ? ShippingAddressModel.fromJson(
              json['shippingAddress'] as Map<String, dynamic>,
            )
          : null,
      paidAt: json['paidAt'] as String?,
    );
  }

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
