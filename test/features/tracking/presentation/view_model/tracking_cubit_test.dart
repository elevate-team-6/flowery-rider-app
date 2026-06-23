import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_pending_orders_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/tracking_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/tracking_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/tracking_states.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'tracking_cubit_test.mocks.dart';

@GenerateMocks([GetPendingOrdersUseCase])
void main() {
  late MockGetPendingOrdersUseCase mockUseCase;
  late TrackingCubit cubit;

  const order1 = OrderEntity(id: '1', orderNumber: 'ORD-1');
  const order2 = OrderEntity(id: '2', orderNumber: 'ORD-2');
  const fakeEntity = PendingOrdersEntity(
    message: 'success',
    orders: [order1, order2],
  );

  setUp(() {
    mockUseCase = MockGetPendingOrdersUseCase();
    cubit = TrackingCubit(mockUseCase);

    provideDummy<BaseResponse<PendingOrdersEntity>>(ErrorBaseResponse('dummy'));
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  group('GetPendingOrdersEvent', () {
    blocTest<TrackingCubit, TrackingStates>(
      'emits loading then data on success',
      setUp: () {
        when(
          mockUseCase.call(page: anyNamed('page')),
        ).thenAnswer((_) async => SuccessBaseResponse(fakeEntity));
      },
      build: () => cubit,
      act: (cubit) => cubit.doEvent(const GetPendingOrdersEvent(page: 1)),
      expect: () => [
        isA<TrackingStates>().having(
          (s) => s.pendingOrdersState.isLoading,
          'isLoading',
          true,
        ),
        isA<TrackingStates>().having(
          (s) => s.pendingOrdersState.data,
          'data',
          fakeEntity,
        ),
      ],
      verify: (_) => verify(mockUseCase.call(page: 1)).called(1),
    );

    test('doEvent does not complete until the use case finishes, so the '
        'RefreshIndicator keeps spinning until loading is done', () async {
      final completer = Completer<BaseResponse<PendingOrdersEntity>>();
      when(
        mockUseCase.call(page: anyNamed('page')),
      ).thenAnswer((_) => completer.future);

      final future = cubit.doEvent(const GetPendingOrdersEvent());
      var completed = false;
      unawaited(future.then((_) => completed = true));

      await Future<void>.delayed(Duration.zero);
      expect(completed, isFalse);

      completer.complete(SuccessBaseResponse(fakeEntity));
      await future;
      expect(completed, isTrue);
    });

    blocTest<TrackingCubit, TrackingStates>(
      'emits loading then error message on failure',
      setUp: () {
        when(
          mockUseCase.call(page: anyNamed('page')),
        ).thenAnswer((_) async => ErrorBaseResponse('network error'));
      },
      build: () => cubit,
      act: (cubit) => cubit.doEvent(const GetPendingOrdersEvent()),
      expect: () => [
        isA<TrackingStates>().having(
          (s) => s.pendingOrdersState.isLoading,
          'isLoading',
          true,
        ),
        isA<TrackingStates>().having(
          (s) => s.pendingOrdersState.errorMessage,
          'errorMessage',
          'network error',
        ),
      ],
    );
  });

  group('AcceptOrderEvent', () {
    test(
      'emits a NavigateEvent to order details with the order argument',
      () async {
        final expectation = expectLater(
          cubit.eventStream,
          emits(
            isA<NavigateEvent>()
                .having((e) => e.routeName, 'routeName', AppRoutes.orderDetails)
                .having((e) => e.arguments, 'arguments', order1),
          ),
        );

        cubit.doEvent(const AcceptOrderEvent(order1));
        await expectation;
      },
    );
  });

  group('RejectOrderEvent', () {
    blocTest<TrackingCubit, TrackingStates>(
      'removes the rejected order from the current list',
      seed: () =>
          const TrackingStates(pendingOrdersState: BaseState(data: fakeEntity)),
      build: () => cubit,
      act: (cubit) => cubit.doEvent(const RejectOrderEvent('1')),
      expect: () => [
        isA<TrackingStates>().having(
          (s) => s.pendingOrdersState.data?.orders,
          'orders',
          [order2],
        ),
      ],
    );

    blocTest<TrackingCubit, TrackingStates>(
      'emits nothing when there is no data loaded',
      build: () => cubit,
      act: (cubit) => cubit.doEvent(const RejectOrderEvent('1')),
      expect: () => [],
    );
  });
}
