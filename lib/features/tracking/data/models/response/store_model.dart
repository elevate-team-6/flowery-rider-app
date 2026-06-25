import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'store_model.g.dart';

@JsonSerializable()
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

  factory StoreModel.fromJson(Map<String, dynamic> json) =>
      _$StoreModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoreModelToJson(this);

  StoreEntity toEntity() {
    List<String>? latLngList = latLong?.split(',');
    return StoreEntity(
      name: name,
      image: (image != null && image!.isNotEmpty)
          ? (image!.startsWith('http')
                ? image
                : '${AppConstants.imageBaseUrl}$image')
          : image,
      address: address,
      phoneNumber: phoneNumber,
      lat: latLngList != null && latLngList.isNotEmpty ? latLngList[0] : null,
      long: latLngList != null && latLngList.length > 1 ? latLngList[1] : null,
    );
  }

  @override
  List<Object?> get props => [name, image, address, phoneNumber, latLong];
}
