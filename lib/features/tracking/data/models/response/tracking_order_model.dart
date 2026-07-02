import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

import 'order_item_model.dart';
import 'shipping_address_model.dart';
import 'store_model.dart';
import 'user_model.dart';

part 'tracking_order_model.g.dart';

@JsonSerializable(createToJson: false)
class TrackingOrderModel extends Equatable {
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

  const TrackingOrderModel({
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

  factory TrackingOrderModel.fromJson(Map<String, dynamic> json) =>
      _$TrackingOrderModelFromJson(json);

  OrderEntity toEntity() {
    if (id == null) {
      throw Exception('Order ID is required');
    }

    return OrderEntity(
      id: id!,
      orderNumber: orderNumber ?? 'ORD-${id?.substring(0, 5)}',
      totalPrice: totalPrice ?? 0,
      state: state ?? 'pending',
      createdAt: createdAt ?? '',
      paymentType: paymentType ?? 'Cash',
      user:
          user?.toEntity() ??
          const UserEntity(
            id: '',
            fullName: 'Unknown User',
            phone: '',
            photo: '',
          ),
      store:
          store?.toEntity() ??
          const StoreEntity(
            name: 'Unknown Store',
            image: '',
            address: '',
            phoneNumber: '',
            lat: '',
            long: '',
          ),
      orderItems: orderItems?.map((e) => e.toEntity()).toList() ?? [],
      // TODO: temporary — the pending-orders API doesn't return shippingAddress,
      // so the customer has no coordinates. Fall back to a fixed Cairo location
      // (Nasr City) so the delivery route is testable. Remove once the API
      // sends the real customer address.
      shippingAddress:
          shippingAddress?.toEntity() ??
          const ShippingAddressEntity(
            street: 'Nasr City, Cairo',
            city: 'Cairo',
            phone: '',
            lat: '30.0511',
            long: '31.3656',
          ),
    );
  }

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
