import 'package:flowery_rider_app/features/profile/domain/entities/driver_entity.dart';

import '../../../../config/base_response/base_response.dart';

abstract interface class ProfileRepoContract {
  Future<BaseResponse<void>> logout();
  Future<BaseResponse<DriverEntity>> profile();
}
