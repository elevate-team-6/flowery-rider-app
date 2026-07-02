import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_order_state_item_model.g.dart';

@JsonSerializable(createToJson: false)
class UpdateOrderStateItemModel extends Equatable {
  final String? product;
  final num? price;
  final int? quantity;
  @JsonKey(name: '_id')
  final String? id;

  const UpdateOrderStateItemModel({
    this.product,
    this.price,
    this.quantity,
    this.id,
  });

  factory UpdateOrderStateItemModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateOrderStateItemModelFromJson(json);

  OrderItemEntity toEntity() => OrderItemEntity(
    productName: product ?? '',
    productImage: '',
    price: price ?? 0,
    quantity: quantity ?? 0,
  );

  @override
  List<Object?> get props => [product, price, quantity, id];
}
