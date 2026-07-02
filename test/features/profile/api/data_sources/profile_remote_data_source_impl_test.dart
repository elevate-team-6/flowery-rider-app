import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/services/multi_part_service.dart';
import 'package:flowery_rider_app/features/profile/api/api_client/profile_api_client.dart';
import 'package:flowery_rider_app/features/profile/api/data_sources/profile_remote_data_source_impl.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/edit_profile_request.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/edit_vehicle_request.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/change_password_response.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([ProfileApiClient, MultipartService])
void main() {
  late MockProfileApiClient mockApiClient;
  late MockMultipartService mockMultipartService;
  late ProfileRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockProfileApiClient();
    mockMultipartService = MockMultipartService();

    dataSource = ProfileRemoteDataSourceImpl(
      mockApiClient,
      mockMultipartService,
    );
  });

  const fakeResponse = ProfileResponseModel(message: 'success');
  const request = EditProfileRequest(
    firstName: 'Ahmed',
    lastName: 'Ali',
    email: 'ahmed@test.com',
    phone: '+201030313971',
  );
  const editVehicleRequest = EditVehicleRequest(
    vehicleType: '1',
    vehicleNumber: 'ABC123',
    vehicleLicense: null,
  );
  DioException buildDioException() => DioException(
    requestOptions: RequestOptions(path: ''),
    type: DioExceptionType.connectionError,
  );

  group('getProfileData', () {
    test('returns SuccessBaseResponse when api call succeeds', () async {
      when(
        mockApiClient.getProfileData(),
      ).thenAnswer((_) async => fakeResponse);

      final result = await dataSource.getProfileData();

      verify(mockApiClient.getProfileData()).called(1);
      expect(result, isA<SuccessBaseResponse<ProfileResponseModel>>());
      expect(
        (result as SuccessBaseResponse<ProfileResponseModel>).data,
        fakeResponse,
      );
    });

    test('returns ErrorBaseResponse when api call throws', () async {
      when(mockApiClient.getProfileData()).thenThrow(buildDioException());

      final result = await dataSource.getProfileData();

      expect(result, isA<ErrorBaseResponse<ProfileResponseModel>>());
      expect(
        (result as ErrorBaseResponse<ProfileResponseModel>).errorMessage,
        isNotEmpty,
      );
    });
  });
  group('changePassword', () {
    test('returns SuccessBaseResponse when api succeeds', () async {
      when(mockApiClient.changePassword(any)).thenAnswer(
        (_) async => const ChangePasswordResponse(
          token: 'Password changed successfully',
        ),
      );

      final result = await dataSource.changePassword(
        'oldPassword',
        'newPassword',
      );

      expect(result, isA<SuccessBaseResponse<String>>());

      expect(
        (result as SuccessBaseResponse<String>).data,
        'Password changed successfully',
      );
    });

    test('returns ErrorBaseResponse when api throws', () async {
      when(mockApiClient.changePassword(any)).thenThrow(buildDioException());

      final result = await dataSource.changePassword(
        'oldPassword',
        'newPassword',
      );

      expect(result, isA<ErrorBaseResponse<String>>());
    });
  });
  group('editVehicle', () {
    test('returns SuccessBaseResponse when api succeeds', () async {
      final formData = FormData();

      when(
        mockMultipartService.createEditVehicleFormData(editVehicleRequest),
      ).thenAnswer((_) async => formData);

      when(
        mockApiClient.editVehicle(formData),
      ).thenAnswer((_) async => fakeResponse);

      final result = await dataSource.editVehicle(editVehicleRequest);

      verify(
        mockMultipartService.createEditVehicleFormData(editVehicleRequest),
      ).called(1);

      verify(mockApiClient.editVehicle(formData)).called(1);

      expect(result, isA<SuccessBaseResponse<ProfileResponseModel>>());
    });

    test('returns ErrorBaseResponse when api throws', () async {
      when(
        mockMultipartService.createEditVehicleFormData(editVehicleRequest),
      ).thenThrow(buildDioException());

      final result = await dataSource.editVehicle(editVehicleRequest);

      expect(result, isA<ErrorBaseResponse<ProfileResponseModel>>());
    });
  });
  group('editProfile', () {
    test('returns SuccessBaseResponse when api call succeeds', () async {
      when(
        mockApiClient.editProfile(request),
      ).thenAnswer((_) async => fakeResponse);

      final result = await dataSource.editProfile(request);

      verify(mockApiClient.editProfile(request)).called(1);
      expect(result, isA<SuccessBaseResponse<ProfileResponseModel>>());
      expect(
        (result as SuccessBaseResponse<ProfileResponseModel>).data,
        fakeResponse,
      );
    });

    test('returns ErrorBaseResponse when api call throws', () async {
      when(mockApiClient.editProfile(any)).thenThrow(buildDioException());

      final result = await dataSource.editProfile(request);

      expect(result, isA<ErrorBaseResponse<ProfileResponseModel>>());
    });
  });

  group('uploadPhoto', () {
    final photo = File('avatar.png');

    test('returns SuccessBaseResponse when api call succeeds', () async {
      when(
        mockApiClient.uploadPhoto(photo),
      ).thenAnswer((_) async => fakeResponse);

      final result = await dataSource.uploadPhoto(photo);

      verify(mockApiClient.uploadPhoto(photo)).called(1);
      expect(result, isA<SuccessBaseResponse<ProfileResponseModel>>());
    });

    test('returns ErrorBaseResponse when api call throws', () async {
      when(mockApiClient.uploadPhoto(any)).thenThrow(Exception('boom'));

      final result = await dataSource.uploadPhoto(photo);

      expect(result, isA<ErrorBaseResponse<ProfileResponseModel>>());
    });
  });

  group('profile', () {
    test(
      'should return SuccessBaseResponse<ProfileResponse> when api succeeds',
      () async {
        final response = ProfileResponse();

        when(mockApiClient.profile()).thenAnswer((_) async => response);

        final result = await dataSource.profile();

        expect(result, isA<SuccessBaseResponse<ProfileResponse>>());

        verify(mockApiClient.profile()).called(1);
        verifyNoMoreInteractions(mockApiClient);
      },
    );

    test('should return ErrorBaseResponse when api throws exception', () async {
      when(mockApiClient.profile()).thenThrow(Exception('server error'));

      final result = await dataSource.profile();

      expect(result, isA<ErrorBaseResponse<ProfileResponse>>());

      verify(mockApiClient.profile()).called(1);
      verifyNoMoreInteractions(mockApiClient);
    });
  });

  group('logout', () {
    test('returns SuccessBaseResponse when api call succeeds', () async {
      when(mockApiClient.logout()).thenAnswer((_) async {});

      final result = await dataSource.logout();

      verify(mockApiClient.logout()).called(1);
      expect(result, isA<SuccessBaseResponse<void>>());
    });

    test('returns ErrorBaseResponse when api call throws', () async {
      when(mockApiClient.logout()).thenThrow(buildDioException());

      final result = await dataSource.logout();

      expect(result, isA<ErrorBaseResponse<void>>());
    });
  });
}
