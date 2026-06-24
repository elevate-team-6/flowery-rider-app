import 'package:flowery_rider_app/features/profile/data/models/response/profile_response.dart';

import '../../../../config/base_response/base_response.dart';

abstract interface class ProfileRemoteDataSourceContract {
  Future<BaseResponse<void>> logout();
  Future<BaseResponse<ProfileResponse>> profile();
}
