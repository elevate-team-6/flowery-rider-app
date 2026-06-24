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
      case 'completed':
        return OrderStatus.completed;
      case 'canceled':
        return OrderStatus.canceled;
      default:
        return OrderStatus.inProgress;
    }
  }
}

class UpdateOrderStateRequestModel {
  final OrderStatus state;

  UpdateOrderStateRequestModel({required this.state});

  Map<String, dynamic> toJson() {
    return {'state': state.value};
  }
}
