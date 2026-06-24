import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

import 'product_model.dart';

part 'order_item_model.g.dart';

@JsonSerializable()
class OrderItemModel extends Equatable {
  final ProductModel? product;
  final num? price;
  final int? quantity;
  @JsonKey(name: '_id')
  final String? id;

  const OrderItemModel({this.product, this.price, this.quantity, this.id});

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  OrderItemEntity toEntity() => OrderItemEntity(
    productName: product?.title,
    productImage: product?.imgCover,
    price: price,
    quantity: quantity,
  );

  @override
  List<Object?> get props => [product, price, quantity, id];
}
