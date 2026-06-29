import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

class OrderStoreModel extends Equatable {
  final String? name;
  final String? image;
  final String? address;
  final String? phoneNumber;
  final String? latLong;

  const OrderStoreModel({
    this.name,
    this.image,
    this.address,
    this.phoneNumber,
    this.latLong,
  });

  factory OrderStoreModel.fromJson(Map<String, dynamic> json) {
    return OrderStoreModel(
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
      name: name ?? '',
      image: (image != null && image!.isNotEmpty)
          ? (image!.startsWith('http')
                ? image!
                : '${AppConstants.imageBaseUrl}$image')
          : '',
      address: address ?? '',
      phoneNumber: phoneNumber ?? '',
      lat: (latLngList != null && latLngList.isNotEmpty) ? latLngList[0] : '',
      long: (latLngList != null && latLngList.length > 1) ? latLngList[1] : '',
    );
  }

  @override
  List<Object?> get props => [name, image, address, phoneNumber, latLong];
}
