import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/notification/domain/entities/user_notification_state.dart';
import 'package:flowery_rider_app/features/notification/domain/repo/notification_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateOrderProgressUseCase {
  final NotificationRepoContract _repository;

  UpdateOrderProgressUseCase(this._repository);

  Future<BaseResponse<void>> call({
    required String userId,
    required String orderId,
    required UserNotificationState state,
  }) {
    return _repository.updateOrderProgress(
      userId: userId,
      orderId: orderId,
      state: state,
    );
  }
}
