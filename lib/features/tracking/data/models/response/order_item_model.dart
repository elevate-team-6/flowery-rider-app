import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entites/order_entity.dart';

import 'product_model.dart';

class OrderItemModel extends Equatable {
  final ProductModel? product;
  final num? price;
  final int? quantity;
  final String? id;

  const OrderItemModel({this.product, this.price, this.quantity, this.id});

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      price: json['price'] as num?,
      quantity: json['quantity'] as int?,
      id: json['_id'] as String?,
    );
  }

  OrderItemEntity toEntity() => OrderItemEntity(
    productName: product?.title,
    productImage: product?.imgCover,
    price: price,
    quantity: quantity,
  );

  @override
  List<Object?> get props => [product, price, quantity, id];
}
