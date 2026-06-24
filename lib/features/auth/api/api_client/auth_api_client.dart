import 'package:dio/dio.dart';
import 'package:flowery_rider_app/core/utils/app_end_points.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/signup_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/vehicle_response.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_client.g.dart';

@injectable
@RestApi(baseUrl: AppEndPoints.baseUrl)
abstract class AuthApiClient {
  @factoryMethod
  factory AuthApiClient(Dio dio) = _AuthApiClient;
  @POST(AppEndPoints.apply)
  Future<SignUpResponse> signup(@Body() FormData formData);
  @GET(AppEndPoints.vehcicls)
  Future<VehicleResponse> vehicles();
}
