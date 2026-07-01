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

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    return OrderEntity(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      totalPrice: json['totalPrice'] as num,
      state: json['state'] as String,
      createdAt: json['createdAt'] as String,
      paymentType: json['paymentType'] as String,
      user: UserEntity.fromJson(json['user'] as Map<String, dynamic>),
      store: StoreEntity.fromJson(json['store'] as Map<String, dynamic>),
      orderItems: (json['orderItems'] as List)
          .map((e) => OrderItemEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      shippingAddress: ShippingAddressEntity.fromJson(
        json['shippingAddress'] as Map<String, dynamic>,
      ),
    );
  }

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
      shippingAddress: remote.shippingAddress,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderNumber': orderNumber,
    'totalPrice': totalPrice,
    'state': state,
    'createdAt': createdAt,
    'paymentType': paymentType,
    'user': user.toJson(),
    'store': store.toJson(),
    'orderItems': orderItems.map((e) => e.toJson()).toList(),
    'shippingAddress': shippingAddress.toJson(),
  };

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

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      photo: json['photo'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'photo': photo,
  };

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

  factory StoreEntity.fromJson(Map<String, dynamic> json) {
    return StoreEntity(
      name: json['name'] as String,
      image: json['image'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String,
      lat: json['lat'] as String,
      long: json['long'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'image': image,
    'address': address,
    'phoneNumber': phoneNumber,
    'lat': lat,
    'long': long,
  };

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

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    return OrderItemEntity(
      productName: json['productName'] as String,
      productImage: json['productImage'] as String,
      price: json['price'] as num,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'productImage': productImage,
    'price': price,
    'quantity': quantity,
  };

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

  factory ShippingAddressEntity.fromJson(Map<String, dynamic> json) {
    return ShippingAddressEntity(
      street: json['street'] as String,
      city: json['city'] as String,
      phone: json['phone'] as String,
      lat: json['lat'] as String,
      long: json['long'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'street': street,
    'city': city,
    'phone': phone,
    'lat': lat,
    'long': long,
  };

  @override
  List<Object?> get props => [street, city, phone, lat, long];
}
