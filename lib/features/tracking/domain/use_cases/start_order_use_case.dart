import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class StartOrderUseCase {
  final TrackingRepoContract _repository;

  StartOrderUseCase(this._repository);

  Future<BaseResponse<OrderEntity>> call(String id) {
    return _repository.startOrder(id);
  }
}
