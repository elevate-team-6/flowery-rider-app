import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/error_handler/error_handler.dart';
import 'package:injectable/injectable.dart';

import '../../data/data_sources/auth_remote_data_source_contract.dart';
import '../../data/models/request/sign_in_request_model.dart';
import '../../data/models/response/sign_in_response_model.dart';
import '../api_client/auth_api_client.dart';

@Injectable(as: AuthRemoteDataSourceContract)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSourceContract {
  final AuthApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<SignInResponseModel>> signIn(SignInRequestModel request) {
    return ErrorHandler.handleApiCall(() {
      return _apiClient.signIn(request);
    });
  }
}
