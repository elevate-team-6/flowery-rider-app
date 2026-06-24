import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

class OrderActionResponseModel extends Equatable {
  final String? message;
  final OrderActionDataModel? order;

  const OrderActionResponseModel({this.message, this.order});

  factory OrderActionResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderActionResponseModel(
      message: json['message'] as String?,
      order: json['orders'] != null
          ? OrderActionDataModel.fromJson(
              json['orders'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [message, order];
}

class OrderActionDataModel extends Equatable {
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

  factory OrderActionDataModel.fromJson(Map<String, dynamic> json) {
    return OrderActionDataModel(
      id: json['_id'] as String?,
      user: json['user'] as String?,
      orderItems: (json['orderItems'] as List<dynamic>?)
          ?.map((e) => OrderActionItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPrice: json['totalPrice'] as num?,
      paymentType: json['paymentType'] as String?,
      isPaid: json['isPaid'] as bool?,
      paidAt: json['paidAt'] as String?,
      isDelivered: json['isDelivered'] as bool?,
      state: json['state'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      orderNumber: json['orderNumber'] as String?,
      v: json['__v'] as int?,
      shippingAddress: json['shippingAddress'] != null
          ? OrderActionShippingAddressModel.fromJson(
              json['shippingAddress'] as Map<String, dynamic>,
            )
          : null,
    );
  }

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

class OrderActionItemModel extends Equatable {
  final String? product;
  final num? price;
  final int? quantity;
  final String? id;

  const OrderActionItemModel({
    this.product,
    this.price,
    this.quantity,
    this.id,
  });

  factory OrderActionItemModel.fromJson(Map<String, dynamic> json) {
    return OrderActionItemModel(
      product: json['product'] as String?,
      price: json['price'] as num?,
      quantity: json['quantity'] as int?,
      id: json['_id'] as String?,
    );
  }

  OrderItemEntity toEntity() => OrderItemEntity(
    productName: product, // ID because only ID is returned
    price: price,
    quantity: quantity,
  );

  @override
  List<Object?> get props => [product, price, quantity, id];
}

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

  factory OrderActionShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return OrderActionShippingAddressModel(
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
