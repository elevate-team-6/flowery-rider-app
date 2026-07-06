import 'package:bloc_test/bloc_test.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/features/notification/domain/entities/user_notification_state.dart';
import 'package:flowery_rider_app/features/notification/domain/use_cases/update_order_progress_use_case.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/cached_active_order.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/cache_active_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/clear_active_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_active_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/open_communication_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/start_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/update_order_state_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_states.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'order_details_cubit_test.mocks.dart';

@GenerateMocks([
  UpdateOrderStateUseCase,
  StartOrderUseCase,
  OpenCommunicationUseCase,
  CacheActiveOrderUseCase,
  GetActiveOrderUseCase,
  ClearActiveOrderUseCase,
  UpdateOrderProgressUseCase,
])
void main() {
  provideDummy<BaseResponse<OrderEntity>>(ErrorBaseResponse('dummy'));
  provideDummy<BaseResponse<void>>(SuccessBaseResponse(null));

  late OrderDetailsCubit cubit;
  late MockUpdateOrderStateUseCase mockUpdateOrderStateUseCase;
  late MockStartOrderUseCase mockStartOrderUseCase;
  late MockOpenCommunicationUseCase mockOpenCommunicationUseCase;
  late MockCacheActiveOrderUseCase mockCacheActiveOrderUseCase;
  late MockGetActiveOrderUseCase mockGetActiveOrderUseCase;
  late MockClearActiveOrderUseCase mockClearActiveOrderUseCase;
  late MockUpdateOrderProgressUseCase mockUpdateOrderProgressUseCase;

  setUp(() {
    mockUpdateOrderStateUseCase = MockUpdateOrderStateUseCase();
    mockStartOrderUseCase = MockStartOrderUseCase();
    mockOpenCommunicationUseCase = MockOpenCommunicationUseCase();
    mockCacheActiveOrderUseCase = MockCacheActiveOrderUseCase();
    mockGetActiveOrderUseCase = MockGetActiveOrderUseCase();
    mockClearActiveOrderUseCase = MockClearActiveOrderUseCase();
    mockUpdateOrderProgressUseCase = MockUpdateOrderProgressUseCase();

    when(
      mockUpdateOrderProgressUseCase(
        userId: anyNamed('userId'),
        orderId: anyNamed('orderId'),
        state: anyNamed('state'),
      ),
    ).thenAnswer((_) async => SuccessBaseResponse(null));

    cubit = OrderDetailsCubit(
      mockUpdateOrderStateUseCase,
      mockStartOrderUseCase,
      mockOpenCommunicationUseCase,
      mockCacheActiveOrderUseCase,
      mockGetActiveOrderUseCase,
      mockClearActiveOrderUseCase,
      mockUpdateOrderProgressUseCase,
    );
  });

  const user = UserEntity(
    id: 'u1',
    fullName: 'Test User',
    phone: '123',
    photo: '',
  );
  const store = StoreEntity(
    name: 'Store',
    image: '',
    address: 'Store Address',
    phoneNumber: '456',
    lat: '30.0',
    long: '31.0',
  );
  const shipping = ShippingAddressEntity(
    street: 'Street',
    city: 'City',
    phone: '789',
    lat: '30.1',
    long: '31.1',
  );

  final tOrder = OrderEntity(
    id: '1',
    state: 'pending',
    orderNumber: 'ORD-1',
    totalPrice: 100,
    createdAt: '2021-01-01',
    paymentType: 'Cash',
    user: user,
    store: store,
    orderItems: [],
    shippingAddress: shipping,
  );

  group('InitializeOrderDetailsEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits initial state and then updated state after startOrder succeeds when no cache',
      build: () {
        when(mockGetActiveOrderUseCase()).thenAnswer((_) async => null);
        when(mockStartOrderUseCase(any)).thenAnswer(
          (_) async =>
              SuccessBaseResponse(tOrder.copyWith(state: 'inProgress')),
        );
        when(mockCacheActiveOrderUseCase(any, any)).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.doEvent(OrderDetailsInitializeEvent(tOrder)),
      expect: () => [
        isA<OrderDetailsState>()
            .having((s) => s.orderDetailsState.data?.id, 'data id', '1')
            .having((s) => s.orderStatus, 'status', OrderStatus.pending),
        isA<OrderDetailsState>().having(
          (s) => s.orderStatus,
          'status',
          OrderStatus.inProgress,
        ),
      ],
      verify: (_) {
        verify(mockStartOrderUseCase('1')).called(1);
        verify(
          mockUpdateOrderProgressUseCase(
            userId: 'u1',
            orderId: '1',
            state: UserNotificationState.accepted,
          ),
        ).called(1);
        verify(mockCacheActiveOrderUseCase(any, any)).called(1);
      },
    );

    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'loads from cache and skips startOrder API if cached order matches',
      build: () {
        when(mockGetActiveOrderUseCase()).thenAnswer(
          (_) async => CachedActiveOrder(
            order: tOrder.copyWith(state: 'inProgress'),
            uiStep: 2,
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvent(OrderDetailsInitializeEvent(tOrder)),
      expect: () => [
        isA<OrderDetailsState>()
            .having((s) => s.uiStep, 'step', 2)
            .having((s) => s.orderStatus, 'status', OrderStatus.inProgress),
      ],
      verify: (_) {
        verifyNever(mockStartOrderUseCase(any));
      },
    );
  });

  group('NextStepEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits loading states and updated step when API succeeds for steps < 6',
      build: () {
        when(mockUpdateOrderStateUseCase(any, any)).thenAnswer(
          (_) async =>
              SuccessBaseResponse(tOrder.copyWith(state: 'inProgress')),
        );
        when(mockCacheActiveOrderUseCase(any, any)).thenAnswer((_) async {});
        return cubit;
      },
      seed: () => OrderDetailsState(
        orderDetailsState: BaseState(data: tOrder),
        uiStep: 1,
      ),
      act: (cubit) => cubit.doEvent(OrderDetailsNextStepEvent()),
      expect: () => [
        isA<OrderDetailsState>().having(
          (s) => s.updateStepState.isLoading,
          'loading true',
          true,
        ),
        isA<OrderDetailsState>().having(
          (s) => s.updateStepState.isLoading,
          'loading false',
          false,
        ),
        isA<OrderDetailsState>()
            .having((s) => s.uiStep, 'step', 2)
            .having((s) => s.orderStatus, 'status', OrderStatus.inProgress),
      ],
      verify: (_) {
        verify(mockCacheActiveOrderUseCase(any, 2)).called(1);
        verify(
          mockUpdateOrderProgressUseCase(
            userId: 'u1',
            orderId: '1',
            state: UserNotificationState.preparing,
          ),
        ).called(1);
      },
    );

    test('emits NavigateEvent and clears cache when reaching step 6', () async {
      when(mockUpdateOrderStateUseCase(any, any)).thenAnswer(
        (_) async => SuccessBaseResponse(tOrder.copyWith(state: 'delivered')),
      );
      when(mockClearActiveOrderUseCase()).thenAnswer((_) async {});

      cubit.emit(
        OrderDetailsState(
          orderDetailsState: BaseState(data: tOrder),
          uiStep: 5,
        ),
      );

      expectLater(
        cubit.eventStream,
        emitsThrough(
          isA<NavigateEvent>()
              .having((e) => e.routeName, 'routeName', AppRoutes.orderSuccess)
              .having(
                (e) => e.navigationType,
                'type',
                NavigationType.pushReplacement,
              ),
        ),
      );

      cubit.doEvent(OrderDetailsNextStepEvent());
      await untilCalled(
        mockUpdateOrderProgressUseCase(
          userId: 'u1',
          orderId: '1',
          state: UserNotificationState.delivered,
        ),
      );
      verify(
        mockUpdateOrderProgressUseCase(
          userId: 'u1',
          orderId: '1',
          state: UserNotificationState.delivered,
        ),
      ).called(1);

      await untilCalled(mockClearActiveOrderUseCase());
      verify(mockClearActiveOrderUseCase()).called(1);
    });
  });

  group('RevertOrderToPendingEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits loading then success when cancel API succeeds',
      build: () {
        when(
          mockUpdateOrderStateUseCase(any, OrderStatus.canceled),
        ).thenAnswer((_) async => SuccessBaseResponse(tOrder));
        when(mockClearActiveOrderUseCase()).thenAnswer((_) async {});
        return cubit;
      },
      seed: () => OrderDetailsState(orderDetailsState: BaseState(data: tOrder)),
      act: (cubit) => cubit.doEvent(RevertOrderToPendingEvent('1')),
      expect: () => [
        isA<OrderDetailsState>().having(
          (s) => s.canselOrderState.isLoading,
          'loading true',
          true,
        ),
        isA<OrderDetailsState>().having(
          (s) => s.canselOrderState.isLoading,
          'loading false',
          false,
        ),
      ],
      verify: (_) {
        verify(mockClearActiveOrderUseCase()).called(1);
        verify(
          mockUpdateOrderProgressUseCase(
            userId: 'u1',
            orderId: '1',
            state: UserNotificationState.canceled,
          ),
        ).called(1);
      },
    );
    test('emits NavigateEvent to mainLayout on success', () async {
      when(
        mockUpdateOrderStateUseCase(any, any),
      ).thenAnswer((_) async => SuccessBaseResponse(tOrder));

      expectLater(
        cubit.eventStream,
        emitsThrough(
          isA<NavigateEvent>()
              .having((e) => e.routeName, 'routeName', AppRoutes.mainLayout)
              .having(
                (e) => e.navigationType,
                'type',
                NavigationType.pushAndRemoveUntil,
              ),
        ),
      );

      cubit.doEvent(RevertOrderToPendingEvent('1'));
    });
  });
}
