import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flowery_rider_app/core/utils/app_end_points.dart';
import 'package:flowery_rider_app/core/utils/app_params.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/change_password_request.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/change_password_response.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/request/edit_profile_request.dart';
import '../../data/models/response/profile_response_model.dart';

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

  @GET(AppEndPoints.profileData)
  Future<ProfileResponse> profile();

  @GET(AppEndPoints.profileData)
  Future<ProfileResponseModel> getProfileData();

  @PUT(AppEndPoints.editProfile)
  Future<ProfileResponseModel> editProfile(@Body() EditProfileRequest body);

  @PUT(AppEndPoints.uploadPhoto)
  @MultiPart()
  Future<ProfileResponseModel> uploadPhoto(
    @Part(name: ApiParameters.photo) File photo,
  );
}
