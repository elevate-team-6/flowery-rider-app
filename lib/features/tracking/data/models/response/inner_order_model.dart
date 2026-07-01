import 'package:equatable/equatable.dart';
import 'user_model.dart';
import 'inner_order_item_model.dart';
import 'inner_shipping_address_model.dart';

class InnerOrderModel extends Equatable {
  final String? id;
  final UserModel? user;
  final List<InnerOrderItemModel>? orderItems;
  final num? totalPrice;
  final InnerShippingAddressModel? shippingAddress;
  final String? paymentType;
  final bool? isPaid;
  final String? paidAt;
  final bool? isDelivered;
  final String? state;
  final String? createdAt;
  final String? updatedAt;
  final String? orderNumber;

  const InnerOrderModel({
    this.id,
    this.user,
    this.orderItems,
    this.totalPrice,
    this.shippingAddress,
    this.paymentType,
    this.isPaid,
    this.paidAt,
    this.isDelivered,
    this.state,
    this.createdAt,
    this.updatedAt,
    this.orderNumber,
  });

  factory InnerOrderModel.fromJson(Map<String, dynamic> json) {
    return InnerOrderModel(
      id: json['_id'] as String?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      orderItems: (json['orderItems'] as List<dynamic>?)
          ?.map((e) => InnerOrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPrice: json['totalPrice'] as num?,
      shippingAddress: json['shippingAddress'] != null
          ? InnerShippingAddressModel.fromJson(
              json['shippingAddress'] as Map<String, dynamic>,
            )
          : null,
      paymentType: json['paymentType'] as String?,
      isPaid: json['isPaid'] as bool?,
      paidAt: json['paidAt'] as String?,
      isDelivered: json['isDelivered'] as bool?,
      state: json['state'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      orderNumber: json['orderNumber'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    user,
    orderItems,
    totalPrice,
    shippingAddress,
    paymentType,
    isPaid,
    paidAt,
    isDelivered,
    state,
    createdAt,
    updatedAt,
    orderNumber,
  ];
}
