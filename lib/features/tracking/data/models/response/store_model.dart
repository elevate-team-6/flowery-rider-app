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
    return StoreEntity(
      name: name ?? (throw Exception('Store Name is required')),
      image: (image != null && image!.isNotEmpty)
          ? (image!.startsWith('http')
                ? image!
                : '${AppConstants.imageBaseUrl}$image')
          : '',
      address: address ?? '',
      phoneNumber: phoneNumber ?? '',
      // TODO: temporary — the backend returns a fixed dummy store location
      // (San Francisco, US). Pin it to Sheikh Zayed, Giza so routing works for
      // Egyptian testing. Remove once the API sends real store coordinates.
      lat: '30.0716',
      long: '30.9754',
    );
  }

  @override
  List<Object?> get props => [name, image, address, phoneNumber, latLong];
}
