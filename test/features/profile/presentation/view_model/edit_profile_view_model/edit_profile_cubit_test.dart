import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/edit_profile_request.dart';
import 'package:flowery_rider_app/features/profile/domain/entities/driver_entity.dart';
import 'package:flowery_rider_app/features/profile/domain/use_cases/edit_profile_use_case.dart';
import 'package:flowery_rider_app/features/profile/domain/use_cases/get_profile_data_use_case.dart';
import 'package:flowery_rider_app/features/profile/domain/use_cases/upload_photo_use_case.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_cubit.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_events.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_states.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'edit_profile_cubit_test.mocks.dart';

@GenerateMocks([
  EditProfileUseCase,
  UploadPhotoUseCase,
  GetProfileDataUseCase,
  File,
])
void main() {
  late MockEditProfileUseCase mockEditUseCase;
  late MockUploadPhotoUseCase mockUploadUseCase;
  late MockGetProfileDataUseCase mockGetProfileUseCase;
  late EditProfileCubit cubit;

  const driver = DriverEntity(
    id: '1',
    firstName: 'Ahmed',
    lastName: 'Ali',
    email: 'ahmed@test.com',
    phone: '+201030313971',
    gender: 'male',
  );

  const updatedDriver = DriverEntity(
    id: '1',
    firstName: 'Mohamed',
    lastName: 'Ali',
    email: 'ahmed@test.com',
    phone: '+201030313971',
    gender: 'male',
  );

  const request = EditProfileRequest(
    firstName: 'Mohamed',
    lastName: 'Ali',
    email: 'ahmed@test.com',
    phone: '+201030313971',
  );

  setUp(() {
    mockEditUseCase = MockEditProfileUseCase();
    mockUploadUseCase = MockUploadPhotoUseCase();
    mockGetProfileUseCase = MockGetProfileDataUseCase();
    cubit = EditProfileCubit(
      mockEditUseCase,
      mockUploadUseCase,
      mockGetProfileUseCase,
    );

    provideDummy<BaseResponse<DriverEntity>>(ErrorBaseResponse('dummy'));
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  group('InitEditProfileEvent', () {
    blocTest<EditProfileCubit, EditProfileStates>(
      'seeds the form with the driver and marks it unchanged',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(const InitEditProfileEvent(driver)),
      expect: () => [
        isA<EditProfileStates>()
            .having((s) => s.driver, 'driver', driver)
            .having((s) => s.gender, 'gender', 'male')
            .having((s) => s.isFormChanged, 'isFormChanged', false),
      ],
    );
  });

  group('FormChangedEvent', () {
    blocTest<EditProfileCubit, EditProfileStates>(
      'marks the form dirty when a field differs from the initial driver',
      build: () => cubit,
      act: (cubit) {
        cubit.doEvent(const InitEditProfileEvent(driver));
        cubit.doEvent(
          const FormChangedEvent(
            firstName: 'Mohamed',
            lastName: 'Ali',
            email: 'ahmed@test.com',
            phone: '01030313971',
          ),
        );
      },
      skip: 1,
      expect: () => [
        isA<EditProfileStates>().having(
          (s) => s.isFormChanged,
          'isFormChanged',
          true,
        ),
      ],
    );

    blocTest<EditProfileCubit, EditProfileStates>(
      'emits nothing when the values match the initial driver',
      build: () => cubit,
      act: (cubit) {
        cubit.doEvent(const InitEditProfileEvent(driver));
        cubit.doEvent(
          const FormChangedEvent(
            firstName: 'Ahmed',
            lastName: 'Ali',
            email: 'ahmed@test.com',
            phone: '01030313971',
          ),
        );
      },
      skip: 1,
      expect: () => [],
    );
  });

  group('SubmitEditProfileEvent', () {
    test(
      'emits loading then success side effects and pops on success',
      () async {
        when(
          mockEditUseCase.call(request),
        ).thenAnswer((_) async => SuccessBaseResponse(updatedDriver));

        final expectation = expectLater(
          cubit.eventStream,
          emitsInOrder([
            isA<ShowLoadingEvent>(),
            isA<HideLoadingEvent>(),
            isA<DisplaySuccessEvent>(),
            isA<NavigateEvent>()
                .having((e) => e.navigationType, 'type', NavigationType.pop)
                .having((e) => e.arguments, 'arguments', updatedDriver),
          ]),
        );

        cubit.doEvent(const SubmitEditProfileEvent(request));
        await expectation;

        verify(mockEditUseCase.call(request)).called(1);
      },
    );

    test('emits loading then error side effects on failure', () async {
      when(
        mockEditUseCase.call(any),
      ).thenAnswer((_) async => ErrorBaseResponse('validation error'));

      final expectation = expectLater(
        cubit.eventStream,
        emitsInOrder([
          isA<ShowLoadingEvent>(),
          isA<HideLoadingEvent>(),
          isA<DisplayErrorEvent>().having(
            (e) => e.errorMessage,
            'errorMessage',
            'validation error',
          ),
        ]),
      );

      cubit.doEvent(const SubmitEditProfileEvent(request));
      await expectation;
    });
  });

  group('PickAndUploadPhotoEvent', () {
    test(
      'rejects a photo larger than the 4 MB limit without uploading',
      () async {
        final photo = MockFile();
        when(photo.length()).thenAnswer((_) async => 5 * 1024 * 1024);

        final expectation = expectLater(
          cubit.eventStream,
          emits(isA<DisplayErrorEvent>()),
        );

        cubit.doEvent(PickAndUploadPhotoEvent(photo));
        await expectation;

        verifyNever(mockUploadUseCase.call(any));
      },
    );

    test('uploads, refreshes profile and reports success', () async {
      final photo = MockFile();
      when(photo.length()).thenAnswer((_) async => 1024);
      when(
        mockUploadUseCase.call(photo),
      ).thenAnswer((_) async => SuccessBaseResponse(updatedDriver));
      when(
        mockGetProfileUseCase.call(),
      ).thenAnswer((_) async => SuccessBaseResponse(updatedDriver));

      final expectation = expectLater(
        cubit.eventStream,
        emitsInOrder([
          isA<ShowLoadingEvent>(),
          isA<HideLoadingEvent>(),
          isA<DisplaySuccessEvent>(),
        ]),
      );

      cubit.doEvent(PickAndUploadPhotoEvent(photo));
      await expectation;

      verify(mockUploadUseCase.call(photo)).called(1);
      verify(mockGetProfileUseCase.call()).called(1);
      expect(cubit.state.isFormChanged, true);
      expect(cubit.state.driver, updatedDriver);
    });

    test('emits error side effects when the upload fails', () async {
      final photo = MockFile();
      when(photo.length()).thenAnswer((_) async => 1024);
      when(
        mockUploadUseCase.call(any),
      ).thenAnswer((_) async => ErrorBaseResponse('upload failed'));

      final expectation = expectLater(
        cubit.eventStream,
        emitsInOrder([
          isA<ShowLoadingEvent>(),
          isA<HideLoadingEvent>(),
          isA<DisplayErrorEvent>().having(
            (e) => e.errorMessage,
            'errorMessage',
            'upload failed',
          ),
        ]),
      );

      cubit.doEvent(PickAndUploadPhotoEvent(photo));
      await expectation;

      verifyNever(mockGetProfileUseCase.call());
    });
  });
}
