import 'package:dio/dio.dart';
import 'package:flowery_rider_app/core/utils/app_end_points.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'tracking_api_client.g.dart';

@lazySingleton
@RestApi(baseUrl: AppEndPoints.baseUrl)
abstract class TrackingApiClient {
  @factoryMethod
  factory TrackingApiClient(Dio dio) = _TrackingApiClient;

  @GET(AppEndPoints.logout)
  Future<void> logout();
}
