import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/driver_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/repo/auth_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class ApplyUseCase {
  final AuthRepoContract _authRepo;
  const ApplyUseCase(this._authRepo);
  Future<BaseResponse<DriverEntity>> call(SignUpRequest request) {
    return _authRepo.signup(request);
  }
}
