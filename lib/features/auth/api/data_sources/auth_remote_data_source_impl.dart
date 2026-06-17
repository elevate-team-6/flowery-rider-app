import 'package:dio/dio.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/error_handler/error_handler.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/signup_response.dart';
import 'package:injectable/injectable.dart';

import '../../data/data_sources/auth_remote_data_source_contract.dart';
import '../api_client/auth_api_client.dart';

@Injectable(as: AuthRemoteDataSourceContract)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSourceContract {
  final AuthApiClient _apiClient;

  const AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<SignUpResponse>> signup(SignUpRequest request) {
    return ErrorHandler.handleApiCall(() async {
      final formData = FormData.fromMap({
        ...request.toJson(),

        if (request.vehicleLicense != null)
          'vehicleLicense': await request.vehicleLicense!.toMultipartFile(),

        if (request.nidImg != null)
          'NIDImg': await request.nidImg!.toMultipartFile(),
      });

      return _apiClient.signup(formData);
    });
  }
}
