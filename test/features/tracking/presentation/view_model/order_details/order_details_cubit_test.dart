import 'package:bloc_test/bloc_test.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/cache/hive_helper.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
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
  HiveHelper,
])
void main() {
  provideDummy<BaseResponse<OrderEntity>>(ErrorBaseResponse('dummy'));

  late OrderDetailsCubit cubit;
  late MockUpdateOrderStateUseCase mockUpdateOrderStateUseCase;
  late MockStartOrderUseCase mockStartOrderUseCase;
  late MockOpenCommunicationUseCase mockOpenCommunicationUseCase;
  late MockHiveHelper mockHiveHelper;

  setUp(() {
    mockUpdateOrderStateUseCase = MockUpdateOrderStateUseCase();
    mockStartOrderUseCase = MockStartOrderUseCase();
    mockOpenCommunicationUseCase = MockOpenCommunicationUseCase();
    mockHiveHelper = MockHiveHelper();

    cubit = OrderDetailsCubit(
      mockUpdateOrderStateUseCase,
      mockStartOrderUseCase,
      mockOpenCommunicationUseCase,
      mockHiveHelper,
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
      'emits initial state and then updated state after startOrder succeeds',
      build: () {
        when(mockStartOrderUseCase(any)).thenAnswer(
          (_) async =>
              SuccessBaseResponse(tOrder.copyWith(state: 'inProgress')),
        );
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
          mockHiveHelper.cacheData(
            boxName: AppKeys.activeOrderBox,
            key: AppKeys.activeOrderKey,
            value: anyNamed('value'),
          ),
        ).called(1);
      },
    );

    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'respects initialStep if provided',
      build: () {
        when(mockStartOrderUseCase(any)).thenAnswer(
          (_) async =>
              SuccessBaseResponse(tOrder.copyWith(state: 'inProgress')),
        );
        return cubit;
      },
      act: (cubit) =>
          cubit.doEvent(OrderDetailsInitializeEvent(tOrder, initialStep: 3)),
      expect: () => [
        isA<OrderDetailsState>().having((s) => s.uiStep, 'step', 3),
        isA<OrderDetailsState>(),
      ],
    );
  });

  group('NextStepEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits updated step and caches order when API succeeds for steps < 6',
      build: () {
        when(mockUpdateOrderStateUseCase(any, any)).thenAnswer(
          (_) async =>
              SuccessBaseResponse(tOrder.copyWith(state: 'inProgress')),
        );
        return cubit;
      },
      seed: () => OrderDetailsState(
        orderDetailsState: BaseState(data: tOrder),
        uiStep: 1,
      ),
      act: (cubit) => cubit.doEvent(OrderDetailsNextStepEvent()),
      expect: () => [
        isA<OrderDetailsState>()
            .having((s) => s.uiStep, 'step', 2)
            .having((s) => s.orderStatus, 'status', OrderStatus.inProgress),
      ],
      verify: (_) {
        verify(
          mockHiveHelper.cacheData(
            boxName: AppKeys.activeOrderBox,
            key: AppKeys.activeOrderKey,
            value: anyNamed('value'),
          ),
        ).called(1);
      },
    );

    test('emits ShowLoadingEvent and HideLoadingEvent', () async {
      when(
        mockUpdateOrderStateUseCase(any, any),
      ).thenAnswer((_) async => SuccessBaseResponse(tOrder));

      cubit.emit(
        OrderDetailsState(
          orderDetailsState: BaseState(data: tOrder),
          uiStep: 1,
        ),
      );

      final eventStream = cubit.eventStream;
      expectLater(
        eventStream,
        emitsInOrder([isA<ShowLoadingEvent>(), isA<HideLoadingEvent>()]),
      );

      cubit.doEvent(OrderDetailsNextStepEvent());
    });

    test('emits NavigateEvent and clears cache when reaching step 6', () async {
      when(mockUpdateOrderStateUseCase(any, any)).thenAnswer(
        (_) async => SuccessBaseResponse(tOrder.copyWith(state: 'delivered')),
      );

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
        mockHiveHelper.deleteData(
          boxName: AppKeys.activeOrderBox,
          key: AppKeys.activeOrderKey,
        ),
      );
      verify(
        mockHiveHelper.deleteData(
          boxName: AppKeys.activeOrderBox,
          key: AppKeys.activeOrderKey,
        ),
      ).called(1);
    });

    test('emits DisplayErrorEvent when API fails', () async {
      when(
        mockUpdateOrderStateUseCase(any, any),
      ).thenAnswer((_) async => ErrorBaseResponse('error'));

      cubit.emit(
        OrderDetailsState(
          orderDetailsState: BaseState(data: tOrder),
          uiStep: 1,
        ),
      );

      expectLater(
        cubit.eventStream,
        emitsThrough(
          isA<DisplayErrorEvent>().having(
            (e) => e.errorMessage,
            'errorMessage',
            'error',
          ),
        ),
      );

      cubit.doEvent(OrderDetailsNextStepEvent());
    });

    test('returns early if uiStep >= 6', () async {
      cubit.emit(const OrderDetailsState(uiStep: 6));
      cubit.doEvent(OrderDetailsNextStepEvent());
      verifyNever(mockUpdateOrderStateUseCase(any, any));
    });

    test('returns early if order data is missing', () async {
      cubit.emit(const OrderDetailsState(uiStep: 1));
      cubit.doEvent(OrderDetailsNextStepEvent());
      verifyNever(mockUpdateOrderStateUseCase(any, any));
    });
  });

  group('ConfirmBackButtonPressedEvent', () {
    test('emits ShowConfirmationDialogEvent', () async {
      expectLater(cubit.eventStream, emits(isA<ShowConfirmationDialogEvent>()));
      cubit.doEvent(ConfirmBackButtonPressedEvent());
    });
  });

  group('RevertOrderToPendingEvent', () {
    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits loading then success when cancel API succeeds',
      build: () {
        when(
          mockUpdateOrderStateUseCase(any, any),
        ).thenAnswer((_) async => SuccessBaseResponse(tOrder));
        return cubit;
      },
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
        verify(
          mockHiveHelper.deleteData(
            boxName: AppKeys.activeOrderBox,
            key: AppKeys.activeOrderKey,
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

    blocTest<OrderDetailsCubit, OrderDetailsState>(
      'emits error state when cancel API fails',
      build: () {
        when(
          mockUpdateOrderStateUseCase(any, any),
        ).thenAnswer((_) async => ErrorBaseResponse('cancel error'));
        return cubit;
      },
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
        isA<OrderDetailsState>().having(
          (s) => s.orderDetailsState.errorMessage,
          'error message',
          'cancel error',
        ),
      ],
    );
  });

  group('NavigateToMapEvent', () {
    test('emits NavigateEvent with store coordinates', () async {
      cubit.emit(OrderDetailsState(orderDetailsState: BaseState(data: tOrder)));

      expectLater(
        cubit.eventStream,
        emits(
          isA<NavigateEvent>()
              .having((e) => e.routeName, 'routeName', AppRoutes.mapScreen)
              .having((e) => (e.arguments as Map)['targetLat'], 'lat', '30.0'),
        ),
      );

      cubit.doEvent(NavigateToMapEvent(LocationType.store));
    });

    test('emits NavigateEvent with user coordinates', () async {
      cubit.emit(OrderDetailsState(orderDetailsState: BaseState(data: tOrder)));

      expectLater(
        cubit.eventStream,
        emits(
          isA<NavigateEvent>()
              .having((e) => e.routeName, 'routeName', AppRoutes.mapScreen)
              .having((e) => (e.arguments as Map)['targetLat'], 'lat', '30.1'),
        ),
      );

      cubit.doEvent(NavigateToMapEvent(LocationType.user));
    });

    test('does not emit NavigateEvent if coordinates are missing', () async {
      cubit.emit(
        OrderDetailsState(
          orderDetailsState: BaseState(
            data: tOrder.copyWith(
              store: const StoreEntity(
                name: '',
                image: '',
                address: '',
                phoneNumber: '',
                lat: '',
                long: '',
              ),
            ),
          ),
        ),
      );

      cubit.doEvent(NavigateToMapEvent(LocationType.store));
      // No event should be emitted because lat/long are empty strings
    });
  });

  group('CommunicationEvents', () {
    test('CallPhoneEvent calls use case and handles failure', () async {
      when(
        mockOpenCommunicationUseCase.call(any, any),
      ).thenAnswer((_) async => false);

      expectLater(
        cubit.eventStream,
        emits(
          isA<DisplayErrorEvent>().having(
            (e) => e.errorMessage,
            'errorMessage',
            AppStrings.couldNotLaunchUrl,
          ),
        ),
      );

      cubit.doEvent(CallPhoneEvent('123'));
    });

    test('OpenWhatsAppEvent calls use case and handles failure', () async {
      when(
        mockOpenCommunicationUseCase.call(any, any),
      ).thenAnswer((_) async => false);

      expectLater(
        cubit.eventStream,
        emits(
          isA<DisplayErrorEvent>().having(
            (e) => e.errorMessage,
            'errorMessage',
            AppStrings.couldNotLaunchUrl,
          ),
        ),
      );

      cubit.doEvent(OpenWhatsAppEvent('123'));
    });
  });
}
