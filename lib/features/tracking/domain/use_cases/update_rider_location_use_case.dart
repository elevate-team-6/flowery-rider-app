import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';

/// Publishes the rider's live position onto the order doc in Firestore so the
/// customer app can render the rider moving on the map. Best-effort: failures
/// are swallowed in the repo, so callers can fire it on every location tick.
@injectable
class UpdateRiderLocationUseCase {
  final TrackingRepoContract _repository;

  UpdateRiderLocationUseCase(this._repository);

  Future<void> call({
    required String orderId,
    required String lat,
    required String long,
  }) {
    return _repository.updateRiderLocation(
      orderId: orderId,
      lat: lat,
      long: long,
    );
  }
}
