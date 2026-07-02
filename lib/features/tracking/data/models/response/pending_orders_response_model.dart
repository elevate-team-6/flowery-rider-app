import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

import 'metadata_model.dart';
import 'tracking_order_model.dart';

class PendingOrdersResponseModel extends Equatable {
  final String? message;
  final MetadataModel? metadata;
  final List<TrackingOrderModel>? orders;

  const PendingOrdersResponseModel({this.message, this.metadata, this.orders});

  factory PendingOrdersResponseModel.fromJson(Map<String, dynamic> json) {
    return PendingOrdersResponseModel(
      message: json['message'] as String?,
      metadata: json['metadata'] != null
          ? MetadataModel.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      orders: (json['orders'] as List<dynamic>?)
          ?.map((e) => TrackingOrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  PendingOrdersEntity toEntity() => PendingOrdersEntity(
    message: message ?? '',
    orders: orders?.map((e) => e.toEntity()).toList() ?? [],
    currentPage: metadata?.currentPage,
    totalPages: metadata?.totalPages,
  );

  @override
  List<Object?> get props => [message, metadata, orders];
}
