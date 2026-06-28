import 'package:equatable/equatable.dart';

class PendingOrdersEntity extends Equatable {
  final String? message;
  final List<OrderEntity>? orders;
  final int? currentPage;
  final int? totalPages;

  const PendingOrdersEntity({
    this.message,
    this.orders,
    this.currentPage,
    this.totalPages,
  });

  @override
  List<Object?> get props => [message, orders, currentPage, totalPages];
}

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

class UserEntity extends Equatable {
  final String? id;
  final String? fullName;
  final String? phone;
  final String? photo;

  const UserEntity({this.id, this.fullName, this.phone, this.photo});

  @override
  List<Object?> get props => [id, fullName, phone, photo];
}

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

  @override
  List<Object?> get props => [name, image, address, phoneNumber, lat, long];
}

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

  @override
  List<Object?> get props => [productName, productImage, price, quantity];
}

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

  @override
  List<Object?> get props => [street, city, phone, lat, long];
}
