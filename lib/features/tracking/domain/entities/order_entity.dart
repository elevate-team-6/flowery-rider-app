import 'package:equatable/equatable.dart';

class PendingOrdersEntity extends Equatable {
  final String message;
  final List<OrderEntity> orders;
  final int? currentPage;
  final int? totalPages;

  const PendingOrdersEntity({
    required this.message,
    required this.orders,
    this.currentPage,
    this.totalPages,
  });

  @override
  List<Object?> get props => [message, orders, currentPage, totalPages];
}

class DriverOrdersEntity extends Equatable {
  final List<OrderEntity> orders;
  final int currentPage;
  final int totalPages;

  const DriverOrdersEntity({
    required this.orders,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [orders, currentPage, totalPages];
}

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final num totalPrice;
  final String state;
  final String createdAt;
  final String paymentType;
  final UserEntity user;
  final StoreEntity store;
  final List<OrderItemEntity> orderItems;
  final ShippingAddressEntity shippingAddress;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.totalPrice,
    required this.state,
    required this.createdAt,
    required this.paymentType,
    required this.user,
    required this.store,
    required this.orderItems,
    required this.shippingAddress,
  });

  OrderEntity copyWith({
    String? id,
    String? orderNumber,
    num? totalPrice,
    String? state,
    String? createdAt,
    String? paymentType,
    UserEntity? user,
    StoreEntity? store,
    List<OrderItemEntity>? orderItems,
    ShippingAddressEntity? shippingAddress,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      totalPrice: totalPrice ?? this.totalPrice,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      paymentType: paymentType ?? this.paymentType,
      user: user ?? this.user,
      store: store ?? this.store,
      orderItems: orderItems ?? this.orderItems,
      shippingAddress: shippingAddress ?? this.shippingAddress,
    );
  }

  /// Merges partial order data from API with rich local data (User/Store)
  OrderEntity mergeWith(OrderEntity? remote) {
    if (remote == null) return this;

    return copyWith(
      id: remote.id,
      orderNumber: remote.orderNumber,
      totalPrice: remote.totalPrice,
      state: remote.state,
      createdAt: remote.createdAt,
      paymentType: remote.paymentType,
      user: (remote.user.fullName.isNotEmpty) ? remote.user : user,
      store: (remote.store.name.isNotEmpty) ? remote.store : store,
      orderItems: (remote.orderItems.isNotEmpty)
          ? remote.orderItems
          : orderItems,
      // Keep the local shipping address when the remote one is empty — the
      // start / update-state responses don't include shippingAddress, so
      // taking it unconditionally would wipe the real coordinates.
      shippingAddress:
          (remote.shippingAddress.lat.isNotEmpty &&
              remote.shippingAddress.long.isNotEmpty)
          ? remote.shippingAddress
          : shippingAddress,
    );
  }

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
  final String id;
  final String fullName;
  final String phone;
  final String photo;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.photo,
  });

  @override
  List<Object?> get props => [id, fullName, phone, photo];
}

class StoreEntity extends Equatable {
  final String name;
  final String image;
  final String address;
  final String phoneNumber;
  final String lat;
  final String long;

  const StoreEntity({
    required this.name,
    required this.image,
    required this.address,
    required this.phoneNumber,
    required this.lat,
    required this.long,
  });

  @override
  List<Object?> get props => [name, image, address, phoneNumber, lat, long];
}

class OrderItemEntity extends Equatable {
  final String productName;
  final String productImage;
  final num price;
  final int quantity;

  const OrderItemEntity({
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productName, productImage, price, quantity];
}

class ShippingAddressEntity extends Equatable {
  final String street;
  final String city;
  final String phone;
  final String lat;
  final String long;

  const ShippingAddressEntity({
    required this.street,
    required this.city,
    required this.phone,
    required this.lat,
    required this.long,
  });

  /// Overlays [other] (e.g. a Firestore address) on top of this one, keeping
  /// this value for any field [other] left empty.
  ShippingAddressEntity mergeWith(ShippingAddressEntity? other) {
    if (other == null) return this;
    String pick(String value, String fallback) =>
        value.isNotEmpty ? value : fallback;
    return ShippingAddressEntity(
      street: pick(other.street, street),
      city: pick(other.city, city),
      phone: pick(other.phone, phone),
      lat: pick(other.lat, lat),
      long: pick(other.long, long),
    );
  }

  @override
  List<Object?> get props => [street, city, phone, lat, long];
}
