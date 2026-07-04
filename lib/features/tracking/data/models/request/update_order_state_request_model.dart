import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  inProgress,
  completed,
  canceled;

  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.inProgress:
        return 'inProgress';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.canceled:
        return 'canceled';
    }
  }

  static OrderStatus fromString(String? state) {
    switch (state) {
      case 'pending':
        return OrderStatus.pending;
      case 'inProgress':
        return OrderStatus.inProgress;
      case 'delivered':
        return OrderStatus.completed;
      case 'canceled':
        return OrderStatus.canceled;
      default:
        return OrderStatus.inProgress;
    }
  }
}

class UpdateOrderStateRequestModel extends Equatable {
  final OrderStatus state;

  const UpdateOrderStateRequestModel({required this.state});

  Map<String, dynamic> toJson() {
    return {'state': state.value};
  }

  @override
  List<Object?> get props => [state];
}
