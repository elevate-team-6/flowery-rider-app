import 'package:dio/dio.dart';
import 'package:flowery_rider_app/core/utils/app_end_points.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';

part 'forgot_password_api_client.g.dart';

@injectable
@RestApi(baseUrl: AppEndPoints.baseUrl)
abstract class AuthApiClient {
  @factoryMethod
  factory AuthApiClient(Dio dio) = _AuthApiClient;
}
