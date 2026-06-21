import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entites/order_entity.dart';

import 'metadata_model.dart';
import 'order_model.dart';

class PendingOrdersResponseModel extends Equatable {
  final String? message;
  final MetadataModel? metadata;
  final List<OrderModel>? orders;

  const PendingOrdersResponseModel({this.message, this.metadata, this.orders});

  factory PendingOrdersResponseModel.fromJson(Map<String, dynamic> json) {
    return PendingOrdersResponseModel(
      message: json['message'] as String?,
      metadata: json['metadata'] != null
          ? MetadataModel.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      orders: (json['orders'] as List<dynamic>?)
          ?.map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  PendingOrdersEntity toEntity() => PendingOrdersEntity(
    message: message,
    orders: orders?.map((e) => e.toEntity()).toList(),
  );

  @override
  List<Object?> get props => [message, metadata, orders];
}
