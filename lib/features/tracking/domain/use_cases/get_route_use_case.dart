import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

@injectable
class GetRouteUseCase {
  final TrackingRepoContract _repository;

  GetRouteUseCase(this._repository);

  Future<List<LatLng>> call(LatLng start, LatLng end) =>
      _repository.getRoute(start, end);
}
