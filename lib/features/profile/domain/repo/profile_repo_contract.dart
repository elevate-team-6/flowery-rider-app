import 'dart:io';

import 'package:flowery_rider_app/core/entities/driver_entity.dart';
import '../../../../config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/edit_profile_request.dart';

abstract interface class ProfileRepoContract {
  Future<BaseResponse<void>> logout();
  Future<BaseResponse<DriverEntity>> profile();

  Future<BaseResponse<DriverEntity>> getProfileData();

  Future<BaseResponse<DriverEntity>> editProfile(EditProfileRequest request);

  Future<BaseResponse<DriverEntity>> uploadPhoto(File photo);
}
