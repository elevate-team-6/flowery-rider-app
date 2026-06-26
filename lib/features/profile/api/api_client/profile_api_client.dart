import 'package:dio/dio.dart';
import 'package:flowery_rider_app/core/utils/app_end_points.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/change_password_request.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/change_password_response.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'profile_api_client.g.dart';

@lazySingleton
@RestApi(baseUrl: AppEndPoints.baseUrl)
abstract class ProfileApiClient {
  @factoryMethod
  factory ProfileApiClient(Dio dio) = _ProfileApiClient;

  @GET(AppEndPoints.logout)
  Future<void> logout();
   @PATCH(AppEndPoints.changePassword)
  Future<ChangePasswordResponse> changePassword(
    @Body() ChangePasswordRequest request,
  );
}
