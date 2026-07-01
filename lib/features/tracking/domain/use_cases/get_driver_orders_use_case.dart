import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetDriverOrdersUseCase {
  final TrackingRepoContract _repository;

  GetDriverOrdersUseCase(this._repository);

  Future<BaseResponse<List<OrderEntity>>> call() {
    return _repository.getDriverOrders();
  }
}
