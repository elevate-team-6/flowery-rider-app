import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/domain/repo/auth_repo_contract.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/vehicle_type_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetVehicleTypeUseCase {
  final AuthRepoContract _authRepo;
  const GetVehicleTypeUseCase(this._authRepo);
  Future<BaseResponse<List<VehicleTypeEntity>>> call() {
    return _authRepo.getVehicles();
  }
}
