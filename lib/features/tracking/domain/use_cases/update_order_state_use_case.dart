import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateOrderStateUseCase {
  final TrackingRepoContract _repository;

  UpdateOrderStateUseCase(this._repository);

  Future<BaseResponse<OrderEntity>> call(String id, OrderStatus state) {
    return _repository.updateOrderState(id, state);
  }
}
