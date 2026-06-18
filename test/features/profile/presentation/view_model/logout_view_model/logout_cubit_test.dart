import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/logout_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/logout_view_model/logout_cubit.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/logout_view_model/logout_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'logout_cubit_test.mocks.dart';

@GenerateMocks([LogoutUseCase, SecureCacheHelper])
void main() {
  late MockLogoutUseCase mockUseCase;
  late MockSecureCacheHelper mockCache;
  late LogoutCubit cubit;

  const fakeEntity = LogoutEntity(message: 'logged out successfully');

  setUp(() {
    mockUseCase = MockLogoutUseCase();
    mockCache = MockSecureCacheHelper();
    cubit = LogoutCubit(mockUseCase, mockCache);

    provideDummy<BaseResponse<LogoutEntity>>(ErrorBaseResponse('dummy'));
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  group('LogoutEvent', () {
    test(
      'emits loading then success side effects and clears the session',
      () async {
        when(
          mockUseCase(),
        ).thenAnswer((_) async => SuccessBaseResponse(fakeEntity));
        when(
          mockCache.deleteData(key: anyNamed('key')),
        ).thenAnswer((_) async {});

        final expectation = expectLater(
          cubit.eventStream,
          emitsInOrder([
            isA<ShowLoadingEvent>(),
            isA<HideLoadingEvent>(),
            isA<DisplaySuccessEvent>(),
            isA<NavigateEvent>(),
          ]),
        );

        cubit.doIntent(const LogoutEvent());
        await expectation;

        verify(mockCache.deleteData(key: AppKeys.tokenKey)).called(1);
        verify(mockCache.deleteData(key: AppKeys.rememberMeKey)).called(1);
      },
    );

    test('emits loading then failure side effects when logout fails', () async {
      when(
        mockUseCase(),
      ).thenAnswer((_) async => ErrorBaseResponse('logout failed'));

      final expectation = expectLater(
        cubit.eventStream,
        emitsInOrder([
          isA<ShowLoadingEvent>(),
          isA<HideLoadingEvent>(),
          isA<DisplayErrorEvent>().having(
            (e) => e.errorMessage,
            'errorMessage',
            'logout failed',
          ),
        ]),
      );

      cubit.doIntent(const LogoutEvent());
      await expectation;

      verifyNever(mockCache.deleteData(key: anyNamed('key')));
    });
  });
}
