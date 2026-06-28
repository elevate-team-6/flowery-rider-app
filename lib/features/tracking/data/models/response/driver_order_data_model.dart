import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

import 'inner_order_model.dart';
import 'order_store_model.dart';

class DriverOrderDataModel extends Equatable {
  final String? id;
  final String? driver;
  final InnerOrderModel? order;
  final OrderStoreModel? store;

  const DriverOrderDataModel({this.id, this.driver, this.order, this.store});

  factory DriverOrderDataModel.fromJson(Map<String, dynamic> json) {
    return DriverOrderDataModel(
      id: json['_id'] as String?,
      driver: json['driver'] as String?,
      order: json['order'] != null
          ? InnerOrderModel.fromJson(json['order'] as Map<String, dynamic>)
          : null,
      store: json['store'] != null
          ? OrderStoreModel.fromJson(json['store'] as Map<String, dynamic>)
          : null,
    );
  }

  OrderEntity toEntity() {
    if (order == null) throw Exception('Order data is missing');
    if (order?.id == null) throw Exception('Order ID is missing');

    return OrderEntity(
      id: order!.id!,
      orderNumber: order?.orderNumber ?? 'ORD-${order?.id?.substring(0, 5)}',
      totalPrice: order?.totalPrice ?? 0,
      state: order?.state ?? 'pending',
      createdAt: order?.createdAt ?? '',
      paymentType: order?.paymentType ?? 'Cash',
      user:
          order?.user?.toEntity() ??
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
      orderItems: order?.orderItems?.map((e) => e.toEntity()).toList() ?? [],
      shippingAddress:
          order?.shippingAddress?.toEntity() ??
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
  List<Object?> get props => [id, driver, order, store];
}
