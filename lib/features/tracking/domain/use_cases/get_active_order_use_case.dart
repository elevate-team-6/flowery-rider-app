import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetActiveOrderUseCase {
  final TrackingRepoContract _repository;

  GetActiveOrderUseCase(this._repository);

  Future<Map<String, dynamic>?> call() {
    return _repository.getCachedActiveOrder();
  }
}
