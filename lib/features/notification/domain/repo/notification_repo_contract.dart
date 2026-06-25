import 'package:flowery_rider_app/config/base_response/base_response.dart';
import '../entities/user_notification_state.dart';

abstract interface class NotificationRepoContract {
  Future<BaseResponse<void>> updateOrderProgress({
    required String userId,
    required String orderId,
    required UserNotificationState state,
  });
}
