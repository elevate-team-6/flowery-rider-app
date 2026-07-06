import 'package:flowery_rider_app/features/tracking/domain/entities/cached_active_order.dart';
import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetActiveOrderUseCase {
  final TrackingRepoContract _repository;

  GetActiveOrderUseCase(this._repository);

  Future<CachedActiveOrder?> call() {
    return _repository.getCachedActiveOrder();
  }
}
