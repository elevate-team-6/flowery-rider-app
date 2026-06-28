import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class ClearActiveOrderUseCase {
  final TrackingRepoContract _repository;

  ClearActiveOrderUseCase(this._repository);

  Future<void> call() {
    return _repository.clearCachedActiveOrder();
  }
}
