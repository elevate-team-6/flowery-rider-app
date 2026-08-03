import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

class OrderShippingFirestoreModel {
  final String street;
  final String city;
  final String phone;
  final String lat;
  final String long;

  const OrderShippingFirestoreModel({
    required this.street,
    required this.city,
    required this.phone,
    required this.lat,
    required this.long,
  });

  static OrderShippingFirestoreModel? fromFirestore(Map<String, dynamic> data) {
    final shipping = data[AppConstants.shippingAddressField];
    if (shipping is! Map) return null;

    return OrderShippingFirestoreModel(
      street: _toStr(shipping[AppConstants.streetField]),
      city: _toStr(shipping[AppConstants.cityField]),
      phone: _toStr(shipping[AppConstants.phoneField]),
      lat: _toStr(shipping[AppConstants.latField]),
      long: _toStr(shipping[AppConstants.longField]),
    );
  }

  ShippingAddressEntity toEntity() => ShippingAddressEntity(
    street: street,
    city: city,
    phone: phone,
    lat: lat,
    long: long,
  );

  static String _toStr(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }
}
