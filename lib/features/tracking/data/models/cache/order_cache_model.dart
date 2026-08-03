import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

/// Serialization layer for the locally cached active order.
///
/// Keeps JSON parsing out of the domain [OrderEntity]: the repo converts an
/// entity to this model to write the cache, and back to an entity when reading
/// it. The JSON shape mirrors the entity's fields one-to-one.
class OrderCacheModel {
  final String id;
  final String orderNumber;
  final num totalPrice;
  final String state;
  final String createdAt;
  final String paymentType;
  final UserCacheModel user;
  final StoreCacheModel store;
  final List<OrderItemCacheModel> orderItems;
  final ShippingAddressCacheModel shippingAddress;

  const OrderCacheModel({
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

  factory OrderCacheModel.fromJson(Map<String, dynamic> json) {
    return OrderCacheModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      totalPrice: json['totalPrice'] as num,
      state: json['state'] as String,
      createdAt: json['createdAt'] as String,
      paymentType: json['paymentType'] as String,
      user: UserCacheModel.fromJson(json['user'] as Map<String, dynamic>),
      store: StoreCacheModel.fromJson(json['store'] as Map<String, dynamic>),
      orderItems: (json['orderItems'] as List)
          .map((e) => OrderItemCacheModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      shippingAddress: ShippingAddressCacheModel.fromJson(
        json['shippingAddress'] as Map<String, dynamic>,
      ),
    );
  }

  factory OrderCacheModel.fromEntity(OrderEntity entity) {
    return OrderCacheModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      totalPrice: entity.totalPrice,
      state: entity.state,
      createdAt: entity.createdAt,
      paymentType: entity.paymentType,
      user: UserCacheModel.fromEntity(entity.user),
      store: StoreCacheModel.fromEntity(entity.store),
      orderItems: entity.orderItems
          .map(OrderItemCacheModel.fromEntity)
          .toList(),
      shippingAddress: ShippingAddressCacheModel.fromEntity(
        entity.shippingAddress,
      ),
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

  OrderEntity toEntity() => OrderEntity(
    id: id,
    orderNumber: orderNumber,
    totalPrice: totalPrice,
    state: state,
    createdAt: createdAt,
    paymentType: paymentType,
    user: user.toEntity(),
    store: store.toEntity(),
    orderItems: orderItems.map((e) => e.toEntity()).toList(),
    shippingAddress: shippingAddress.toEntity(),
  );
}

class UserCacheModel {
  final String id;
  final String fullName;
  final String phone;
  final String photo;

  const UserCacheModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.photo,
  });

  factory UserCacheModel.fromJson(Map<String, dynamic> json) => UserCacheModel(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    phone: json['phone'] as String,
    photo: json['photo'] as String,
  );

  factory UserCacheModel.fromEntity(UserEntity entity) => UserCacheModel(
    id: entity.id,
    fullName: entity.fullName,
    phone: entity.phone,
    photo: entity.photo,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'photo': photo,
  };

  UserEntity toEntity() =>
      UserEntity(id: id, fullName: fullName, phone: phone, photo: photo);
}

class StoreCacheModel {
  final String name;
  final String image;
  final String address;
  final String phoneNumber;
  final String lat;
  final String long;

  const StoreCacheModel({
    required this.name,
    required this.image,
    required this.address,
    required this.phoneNumber,
    required this.lat,
    required this.long,
  });

  factory StoreCacheModel.fromJson(Map<String, dynamic> json) =>
      StoreCacheModel(
        name: json['name'] as String,
        image: json['image'] as String,
        address: json['address'] as String,
        phoneNumber: json['phoneNumber'] as String,
        lat: json['lat'] as String,
        long: json['long'] as String,
      );

  factory StoreCacheModel.fromEntity(StoreEntity entity) => StoreCacheModel(
    name: entity.name,
    image: entity.image,
    address: entity.address,
    phoneNumber: entity.phoneNumber,
    lat: entity.lat,
    long: entity.long,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'image': image,
    'address': address,
    'phoneNumber': phoneNumber,
    'lat': lat,
    'long': long,
  };

  StoreEntity toEntity() => StoreEntity(
    name: name,
    image: image,
    address: address,
    phoneNumber: phoneNumber,
    lat: lat,
    long: long,
  );
}

class OrderItemCacheModel {
  final String productName;
  final String productImage;
  final num price;
  final int quantity;

  const OrderItemCacheModel({
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
  });

  factory OrderItemCacheModel.fromJson(Map<String, dynamic> json) =>
      OrderItemCacheModel(
        productName: json['productName'] as String,
        productImage: json['productImage'] as String,
        price: json['price'] as num,
        quantity: json['quantity'] as int,
      );

  factory OrderItemCacheModel.fromEntity(OrderItemEntity entity) =>
      OrderItemCacheModel(
        productName: entity.productName,
        productImage: entity.productImage,
        price: entity.price,
        quantity: entity.quantity,
      );

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'productImage': productImage,
    'price': price,
    'quantity': quantity,
  };

  OrderItemEntity toEntity() => OrderItemEntity(
    productName: productName,
    productImage: productImage,
    price: price,
    quantity: quantity,
  );
}

class ShippingAddressCacheModel {
  final String street;
  final String city;
  final String phone;
  final String lat;
  final String long;

  const ShippingAddressCacheModel({
    required this.street,
    required this.city,
    required this.phone,
    required this.lat,
    required this.long,
  });

  factory ShippingAddressCacheModel.fromJson(Map<String, dynamic> json) =>
      ShippingAddressCacheModel(
        street: json['street'] as String,
        city: json['city'] as String,
        phone: json['phone'] as String,
        lat: json['lat'] as String,
        long: json['long'] as String,
      );

  factory ShippingAddressCacheModel.fromEntity(ShippingAddressEntity entity) =>
      ShippingAddressCacheModel(
        street: entity.street,
        city: entity.city,
        phone: entity.phone,
        lat: entity.lat,
        long: entity.long,
      );

  Map<String, dynamic> toJson() => {
    'street': street,
    'city': city,
    'phone': phone,
    'lat': lat,
    'long': long,
  };

  ShippingAddressEntity toEntity() => ShippingAddressEntity(
    street: street,
    city: city,
    phone: phone,
    lat: lat,
    long: long,
  );
}
