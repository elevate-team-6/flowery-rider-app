import '../../../../config/base_response/base_response.dart';

abstract interface class ProfileRemoteDataSourceContract {
  Future<BaseResponse<void>> logout();
}
