import '../models/fcm_config_model.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/notification/data/models/order_firestore_model.dart';
import 'package:flowery_rider_app/features/notification/data/models/user_firestore_model.dart';

abstract class NotificationRemoteDataSourceContract {
  Future<UserFirestoreModel?> getUserData(String userId);
  Future<BaseResponse<bool>> sendPushNotification({
    required String token,
    required String title,
    required String body,
    required String accessToken,
    required String projectId,
    String? orderId,
  });
  Future<FcmConfigModel?> getFcmConfig();
  Future<void> updateOrderInFirestore(OrderFirestoreModel model);
  Future<void> saveNotificationToHistory({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  });
}
