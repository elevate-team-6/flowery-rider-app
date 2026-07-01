import 'order_entity.dart';

class DriverOrdersSummary {
  final DriverOrdersEntity driverOrders;
  final int completedCount;
  final int canceledCount;

  const DriverOrdersSummary({
    required this.driverOrders,
    required this.completedCount,
    required this.canceledCount,
  });
}
