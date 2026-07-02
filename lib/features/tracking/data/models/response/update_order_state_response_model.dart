import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'update_order_state_data_model.dart';

part 'update_order_state_response_model.g.dart';

@JsonSerializable(createToJson: false)
class UpdateOrderStateResponseModel extends Equatable {
  final String? message;
  @JsonKey(name: 'orders')
  final UpdateOrderStateDataModel? order;

  const UpdateOrderStateResponseModel({this.message, this.order});

  factory UpdateOrderStateResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateOrderStateResponseModelFromJson(json);

  @override
  List<Object?> get props => [message, order];
}
