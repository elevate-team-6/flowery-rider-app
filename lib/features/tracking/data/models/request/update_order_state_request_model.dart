enum OrderStatus {
  accepted,
  inProgress,
  completed,
  canceled;

  String get value {
    switch (this) {
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.inProgress:
        return 'inProgress';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.canceled:
        return 'canceled';
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
