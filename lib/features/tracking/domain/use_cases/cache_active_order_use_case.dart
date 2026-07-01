import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class CacheActiveOrderUseCase {
  final TrackingRepoContract _repository;

  CacheActiveOrderUseCase(this._repository);

  Future<void> call(OrderEntity order, int uiStep) {
    return _repository.cacheActiveOrder(order, uiStep);
  }
}
