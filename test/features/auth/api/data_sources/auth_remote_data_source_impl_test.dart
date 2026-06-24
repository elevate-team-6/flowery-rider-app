import 'package:dio/dio.dart';
import 'package:flowery_rider_app/features/auth/api/api_client/auth_api_client.dart';
import 'package:flowery_rider_app/features/auth/api/data_sources/auth_remote_data_source_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/services/multi_part_service.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/signup_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/vehicle_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/vehicle_type_model.dart';

import 'auth_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([AuthApiClient, MultipartService])
void main() {
  late MockAuthApiClient mockApiClient;
  late MockMultipartService mockMultipartService;

  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockAuthApiClient();
    mockMultipartService = MockMultipartService();

    dataSource = AuthRemoteDataSourceImpl(mockApiClient, mockMultipartService);
  });

  group('signup', () {
    test('should return SuccessBaseResponse when api call succeeds', () async {
      final request = const SignUpRequest(
        country: '',
        firstName: '',
        lastName: '',
        vehicleType: '',
        vehicleNumber: '',
        nid: '',
        email: '',
        password: '',
        rePassword: '',
        gender: '',
        phone: '',
        vehicleLicense: null,
        nidImg: null,
      );

      when(
        mockMultipartService.createSignUpFormData(request),
      ).thenAnswer((_) async => FormData());

      when(mockApiClient.signup(any)).thenAnswer((_) async => SignUpResponse());

      final result = await dataSource.signup(request);

      expect(result, isA<SuccessBaseResponse<SignUpResponse>>());

      verify(mockMultipartService.createSignUpFormData(request)).called(1);

      verify(mockApiClient.signup(any)).called(1);
    });
  });

  group('vehicles', () {
    test('should return SuccessBaseResponse when api call succeeds', () async {
      final response = VehicleResponse(
        vehicles: const [VehicleModel(id: '1', type: 'Car', image: 'image')],
      );

      when(mockApiClient.vehicles()).thenAnswer((_) async => response);

      final result = await dataSource.vehicles();

      expect(result, isA<SuccessBaseResponse<VehicleResponse>>());

      final success = result as SuccessBaseResponse<VehicleResponse>;

      expect(success.data?.vehicles.length, 1);

      verify(mockApiClient.vehicles()).called(1);
    });
  });
}
