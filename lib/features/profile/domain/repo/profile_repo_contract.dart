import '../../../../config/base_response/base_response.dart';

abstract interface class ProfileRepoContract {
  Future<BaseResponse<void>> logout();
  Future<BaseResponse<String>> changePassword(
    String password,
    String newPassword,
  );
}
