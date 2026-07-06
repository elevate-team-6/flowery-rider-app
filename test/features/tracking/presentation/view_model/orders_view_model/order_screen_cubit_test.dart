import 'package:bloc_test/bloc_test.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/driver_orders_summary.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_driver_orders_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_order_shipping_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_states.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'order_screen_cubit_test.mocks.dart';

@GenerateMocks([GetDriverOrdersUseCase, GetOrderShippingUseCase])
void main() {
  provideDummy<BaseResponse<DriverOrdersSummary>>(ErrorBaseResponse('dummy'));

  late OrderScreenCubit cubit;
  late MockGetDriverOrdersUseCase mockGetDriverOrdersUseCase;
  late MockGetOrderShippingUseCase mockGetOrderShippingUseCase;

  setUp(() {
    mockGetDriverOrdersUseCase = MockGetDriverOrdersUseCase();
    mockGetOrderShippingUseCase = MockGetOrderShippingUseCase();
    when(mockGetOrderShippingUseCase(any)).thenAnswer((_) async => null);
    cubit = OrderScreenCubit(
      mockGetDriverOrdersUseCase,
      mockGetOrderShippingUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  const tOrder = OrderEntity(
    id: '1',
    orderNumber: '#123',
    totalPrice: 100,
    state: 'completed',
    createdAt: '2021-01-01',
    paymentType: 'cash',
    user: UserEntity(id: 'u1', fullName: 'User', phone: '', photo: ''),
    store: StoreEntity(
      name: 'Store',
      image: '',
      address: '',
      phoneNumber: '',
      lat: '',
      long: '',
    ),
    orderItems: [],
    shippingAddress: ShippingAddressEntity(
      street: '',
      city: '',
      phone: '',
      lat: '',
      long: '',
    ),
  );

  const tCanceledOrder = OrderEntity(
    id: '2',
    orderNumber: '#124',
    totalPrice: 100,
    state: 'canceled', // Match Cubit logic (one 'l')
    createdAt: '2021-01-01',
    paymentType: 'cash',
    user: UserEntity(id: 'u2', fullName: 'User 2', phone: '', photo: ''),
    store: StoreEntity(
      name: 'Store',
      image: '',
      address: '',
      phoneNumber: '',
      lat: '',
      long: '',
    ),
    orderItems: [],
    shippingAddress: ShippingAddressEntity(
      street: '',
      city: '',
      phone: '',
      lat: '',
      long: '',
    ),
  );

  final tDriverOrdersEntity = DriverOrdersEntity(
    orders: [tOrder, tCanceledOrder],
    currentPage: 1,
    totalPages: 2,
  );

  group('OrderScreenCubit', () {
    test('initial state should be correct', () {
      expect(cubit.state, const OrderScreenState());
    });

    blocTest<OrderScreenCubit, OrderScreenState>(
      'emits [loading, success] when GetDriverOrdersEvent is successful',
      build: () {
        when(mockGetDriverOrdersUseCase(page: anyNamed('page'))).thenAnswer(
          (_) async => SuccessBaseResponse(
            DriverOrdersSummary(
              driverOrders: tDriverOrdersEntity,
              completedCount: 1,
              canceledCount: 1,
            ),
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvent(GetDriverOrdersEvent()),
      expect: () => [
        const OrderScreenState(ordersState: BaseState(isLoading: true)),
        OrderScreenState(
          ordersState: BaseState(data: tDriverOrdersEntity.orders),
          completedCount: 1,
          cancelledCount: 1,
          currentPage: 1,
          totalPages: 2,
        ),
      ],
      verify: (_) {
        verify(mockGetDriverOrdersUseCase(page: 1)).called(1);
      },
    );

    blocTest<OrderScreenCubit, OrderScreenState>(
      'emits [loading, error] when GetDriverOrdersEvent fails',
      build: () {
        when(
          mockGetDriverOrdersUseCase(page: anyNamed('page')),
        ).thenAnswer((_) async => ErrorBaseResponse('server error'));
        return cubit;
      },
      act: (cubit) => cubit.doEvent(GetDriverOrdersEvent()),
      expect: () => [
        const OrderScreenState(ordersState: BaseState(isLoading: true)),
        const OrderScreenState(
          ordersState: BaseState(errorMessage: 'server error'),
        ),
      ],
    );

    blocTest<OrderScreenCubit, OrderScreenState>(
      'emits [loading, success] with different page when ChangePageEvent is called',
      build: () {
        when(mockGetDriverOrdersUseCase(page: 2)).thenAnswer(
          (_) async => SuccessBaseResponse(
            DriverOrdersSummary(
              driverOrders: DriverOrdersEntity(
                orders: const [tOrder],
                currentPage: 2,
                totalPages: 2,
              ),
              completedCount: 1,
              canceledCount: 0,
            ),
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvent(ChangePageEvent(2)),
      expect: () => [
        const OrderScreenState(ordersState: BaseState(isLoading: true)),
        OrderScreenState(
          ordersState: const BaseState(data: [tOrder]),
          completedCount: 1,
          cancelledCount: 0,
          currentPage: 2,
          totalPages: 2,
        ),
      ],
      verify: (_) {
        verify(mockGetDriverOrdersUseCase(page: 2)).called(1);
      },
    );

    test('emits NavigateEvent when OrderTappedEvent is called', () async {
      expectLater(
        cubit.eventStream,
        emits(
          isA<NavigateEvent>()
              .having(
                (e) => e.routeName,
                'routeName',
                AppRoutes.driverOrderDetails,
              )
              .having((e) => e.arguments, 'arguments', tOrder),
        ),
      );

      cubit.doEvent(OrderTappedEvent(tOrder));
    });
  });
}
