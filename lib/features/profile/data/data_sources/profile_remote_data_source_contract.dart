import 'dart:io';

import 'package:flowery_rider_app/features/profile/data/models/response/profile_response.dart';

import '../../../../config/base_response/base_response.dart';
import '../models/request/edit_profile_request.dart';
import '../models/response/profile_response_model.dart';

abstract interface class ProfileRemoteDataSourceContract {
  Future<BaseResponse<void>> logout();

  Future<BaseResponse<ProfileResponse>> profile();

  Future<BaseResponse<ProfileResponseModel>> getProfileData();

  Future<BaseResponse<ProfileResponseModel>> editProfile(
    EditProfileRequest request,
  );

  Future<BaseResponse<ProfileResponseModel>> uploadPhoto(File photo);
}
