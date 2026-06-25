import 'package:dio/dio.dart';
import 'package:flowery_rider_app/core/utils/app_end_points.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response_model.dart';
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
  @PUT(AppEndPoints.editProfile)
  Future<ProfileResponseModel> editVehicle(@Body() FormData formData);
}
