import 'package:equatable/equatable.dart';

import 'driver_order_data_model.dart';
import 'metadata_model.dart';

class AllDriverOrdersResponseModel extends Equatable {
  final String? message;
  final MetadataModel? metadata;
  final List<DriverOrderDataModel>? orders;

  const AllDriverOrdersResponseModel({
    this.message,
    this.metadata,
    this.orders,
  });

  factory AllDriverOrdersResponseModel.fromJson(Map<String, dynamic> json) {
    return AllDriverOrdersResponseModel(
      message: json['message'] as String?,
      metadata: json['metadata'] != null
          ? MetadataModel.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      orders: (json['orders'] as List<dynamic>?)
          ?.map((e) => DriverOrderDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [message, metadata, orders];
}
