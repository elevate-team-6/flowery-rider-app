import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/data/data_sources/auth_local_data_source_contract.dart';
import 'package:flowery_rider_app/features/auth/data/data_sources/auth_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/signup_response.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/country_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/driver_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/repo/auth_repo_contract.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AuthRepoContract)
class AuthRepoImpl implements AuthRepoContract {
  final AuthRemoteDataSourceContract _remoteDataSource;
    final AuthLocalDataSourceContract localDataSource;
  const AuthRepoImpl(this._remoteDataSource,this.localDataSource);

  @override
  Future<BaseResponse<DriverEntity>> signup(SignUpRequest request) async {
    final response = await _remoteDataSource.signup(request);
    switch (response) {
      case SuccessBaseResponse<SignUpResponse>():
        if (response.data!.driver == null) {
          return ErrorBaseResponse(AppStrings.signupFailedUserIsNull.tr());
        }
        return SuccessBaseResponse(response.data!.driver!.toDomain());
      case ErrorBaseResponse<SignUpResponse>():
        return ErrorBaseResponse(response.errorMessage.tr());
    }
  }

@override
Future<List<CountryEntity>> getCountries() async =>
    (await localDataSource.getCountries())
        .map((e) => e.toDomain())
        .toList();
}
