import 'package:flowery_rider_app/core/utils/app_constants.dart';

class OrderFirestoreModel {
  final String orderId;
  final String status;
  final String riderId;
  final String riderName;
  final String riderPhone;

  OrderFirestoreModel({
    required this.orderId,
    required this.status,
    required this.riderId,
    required this.riderName,
    required this.riderPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      AppConstants.statusField: status,
      AppConstants.riderIdField: riderId,
      AppConstants.riderNameField: riderName,
      AppConstants.riderPhoneField: riderPhone,
    };
  }
}
