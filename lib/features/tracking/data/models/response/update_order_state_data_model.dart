import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

import 'update_order_state_item_model.dart';
import 'update_order_state_shipping_address_model.dart';

part 'update_order_state_data_model.g.dart';

@JsonSerializable(createToJson: false)
class UpdateOrderStateDataModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String? user;
  final List<UpdateOrderStateItemModel>? orderItems;
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
  final UpdateOrderStateShippingAddressModel? shippingAddress;

  const UpdateOrderStateDataModel({
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

  factory UpdateOrderStateDataModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateOrderStateDataModelFromJson(json);

  OrderEntity toEntity() {
    if (id == null) throw Exception('Order ID is required');

    return OrderEntity(
      id: id!,
      orderNumber: orderNumber ?? '',
      totalPrice: totalPrice ?? 0,
      state: state ?? '',
      createdAt: createdAt ?? '',
      paymentType: paymentType ?? '',
      user: UserEntity(id: user ?? '', fullName: '', phone: '', photo: ''),
      store: const StoreEntity(
        name: '',
        image: '',
        address: '',
        phoneNumber: '',
        lat: '',
        long: '',
      ),
      orderItems: orderItems?.map((e) => e.toEntity()).toList() ?? [],
      shippingAddress:
          shippingAddress?.toEntity() ??
          const ShippingAddressEntity(
            street: '_',
            city: '_',
            phone: '',
            lat: '',
            long: '',
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
