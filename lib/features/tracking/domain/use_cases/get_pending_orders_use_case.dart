import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entites/order_entity.dart';
import '../repo/tracking_repo_contract.dart';

@injectable
class GetPendingOrdersUseCase {
  final TrackingRepoContract _repo;

  GetPendingOrdersUseCase(this._repo);

  Future<BaseResponse<PendingOrdersEntity>> call({int? page}) {
    return _repo.getPendingOrders(page: page);
  }
}
