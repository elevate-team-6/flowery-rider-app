import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/core/entities/driver_entity.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/edit_vehicle_request.dart';
import 'package:flowery_rider_app/features/profile/domain/repo/profile_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class EditVehicleUseCase {
  final ProfileRepoContract _repoContract;
  const EditVehicleUseCase(this._repoContract);
  Future<BaseResponse<DriverEntity>> call(EditVehicleRequest request) {
    return _repoContract.editVehicle(request);
  }
}
