import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

import 'metadata_model.dart';
import 'user_model.dart';

class DriverOrdersResponseModel extends Equatable {
  final String? message;
  final MetadataModel? metadata;
  final List<DriverOrderModel>? orders;

  const DriverOrdersResponseModel({this.message, this.metadata, this.orders});

  factory DriverOrdersResponseModel.fromJson(Map<String, dynamic> json) {
    return DriverOrdersResponseModel(
      message: json['message'] as String?,
      metadata: json['metadata'] != null
          ? MetadataModel.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      orders: (json['orders'] as List<dynamic>?)
          ?.map((e) => DriverOrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [message, metadata, orders];
}

class DriverOrderModel extends Equatable {
  final String? id;
  final String? driver;
  final InnerOrderModel? order;
  final DriverStoreModel? store;

  const DriverOrderModel({this.id, this.driver, this.order, this.store});

  factory DriverOrderModel.fromJson(Map<String, dynamic> json) {
    return DriverOrderModel(
      id: json['_id'] as String?,
      driver: json['driver'] as String?,
      order: json['order'] != null
          ? InnerOrderModel.fromJson(json['order'] as Map<String, dynamic>)
          : null,
      store: json['store'] != null
          ? DriverStoreModel.fromJson(json['store'] as Map<String, dynamic>)
          : null,
    );
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: order?.id,
      orderNumber: order?.orderNumber,
      totalPrice: order?.totalPrice,
      state: order?.state,
      createdAt: order?.createdAt,
      paymentType: order?.paymentType,
      user: order?.user?.toEntity(),
      store: store?.toEntity(),
      orderItems: order?.orderItems?.map((e) => e.toEntity()).toList(),
      shippingAddress: order?.shippingAddress?.toEntity(),
    );
  }

  @override
  List<Object?> get props => [id, driver, order, store];
}

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

class InnerOrderItemModel extends Equatable {
  final InnerProductModel? product;
  final num? price;
  final int? quantity;
  final String? id;

  const InnerOrderItemModel({this.product, this.price, this.quantity, this.id});

  factory InnerOrderItemModel.fromJson(Map<String, dynamic> json) {
    return InnerOrderItemModel(
      product: json['product'] != null
          ? InnerProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      price: json['price'] as num?,
      quantity: json['quantity'] as int?,
      id: json['_id'] as String?,
    );
  }

  OrderItemEntity toEntity() => OrderItemEntity(
    productName: product?.title,
    productImage: null, // Image not available in this specific nested response
    price: price,
    quantity: quantity,
  );

  @override
  List<Object?> get props => [product, price, quantity, id];
}

class InnerProductModel extends Equatable {
  final String? id;
  final num? price;
  final String? title;

  const InnerProductModel({this.id, this.price, this.title});

  factory InnerProductModel.fromJson(Map<String, dynamic> json) {
    return InnerProductModel(
      id: json['_id'] as String?,
      price: json['price'] as num?,
      title: json['title'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, price, title];
}

class DriverStoreModel extends Equatable {
  final String? name;
  final String? image;
  final String? address;
  final String? phoneNumber;
  final String? latLong;

  const DriverStoreModel({
    this.name,
    this.image,
    this.address,
    this.phoneNumber,
    this.latLong,
  });

  factory DriverStoreModel.fromJson(Map<String, dynamic> json) {
    return DriverStoreModel(
      name: json['name'] as String?,
      image: json['image'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      latLong: json['latLong'] as String?,
    );
  }

  StoreEntity toEntity() {
    List<String>? latLngList = latLong?.split(',');
    return StoreEntity(
      name: name,
      image: image,
      address: address,
      phoneNumber: phoneNumber,
      lat: latLngList != null && latLngList.isNotEmpty ? latLngList[0] : null,
      long: latLngList != null && latLngList.length > 1 ? latLngList[1] : null,
    );
  }

  @override
  List<Object?> get props => [name, image, address, phoneNumber, latLong];
}

class InnerShippingAddressModel extends Equatable {
  final String? street;
  final String? city;
  final String? phone;
  final String? lat;
  final String? long;

  const InnerShippingAddressModel({
    this.street,
    this.city,
    this.phone,
    this.lat,
    this.long,
  });

  factory InnerShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return InnerShippingAddressModel(
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
