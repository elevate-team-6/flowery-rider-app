import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

import 'inner_product_model.dart';

class InnerOrderItemModel extends Equatable {
  final InnerProductModel? product;
  final num? price;
  final int? quantity;
  final String? id;

  const InnerOrderItemModel({this.product, this.price, this.quantity, this.id});

  factory InnerOrderItemModel.fromJson(Map<String, dynamic> json) {
    return InnerOrderItemModel(
      product: json['product'] != null
          ? InnerProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      price: json['price'] as num?,
      quantity: json['quantity'] as int?,
      id: json['_id'] as String?,
    );
  }

  OrderItemEntity toEntity() => OrderItemEntity(
    productName: product?.title ?? 'Unknown Product',
    productImage: '',
    price: price ?? 0,
    quantity: quantity ?? 0,
  );

  @override
  List<Object?> get props => [product, price, quantity, id];
}
