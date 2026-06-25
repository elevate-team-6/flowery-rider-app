import 'package:flowery_rider_app/config/services/multi_part_service.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/edit_vehicle_request.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response_model.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../config/error_handler/error_handler.dart';
import '../../data/data_sources/profile_remote_data_source_contract.dart';
import '../api_client/profile_api_client.dart';

@Injectable(as: ProfileRemoteDataSourceContract)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSourceContract {
  final ProfileApiClient _apiClient;
  final MultipartService _multipartService;

  ProfileRemoteDataSourceImpl(this._apiClient,this._multipartService);

  @override
  Future<BaseResponse<void>> logout() async {
    return await ErrorHandler.handleApiCall(() => _apiClient.logout());
  }
  @override
Future<BaseResponse<ProfileResponseModel>> editVehicle(
  EditVehicleRequest request,
) {
  print('REMOTE DATASOURCE CALLED');
  return ErrorHandler.handleApiCall(() async {
    final formData = await _multipartService.createEditVehicleFormData(
      request,
    );
  print(formData.fields);
    print(formData.files);
    return _apiClient.editVehicle(formData);
  });
}
}
