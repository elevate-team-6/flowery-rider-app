import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

class StoreModel extends Equatable {
  final String? name;
  final String? image;
  final String? address;
  final String? phoneNumber;
  final String? latLong;

  const StoreModel({
    this.name,
    this.image,
    this.address,
    this.phoneNumber,
    this.latLong,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
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
