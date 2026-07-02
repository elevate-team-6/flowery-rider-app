import 'dart:async';

import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/di/di.dart';
import 'package:flowery_rider_app/features/mainLayout/presentation/view_model/main_layout_cubit.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/orders_screen.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_states.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/order_card_item.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/orders_tab_summary_section.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/pagination_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'orders_screen_test.mocks.dart';

@GenerateMocks([OrderScreenCubit])
void main() {
  late MockOrderScreenCubit mockCubit;
  late MainLayoutCubit mainLayoutCubit;
  late StreamController<BaseUiEvent> eventController;
  late StreamController<OrderScreenState> stateController;

  setUp(() {
    mockCubit = MockOrderScreenCubit();
    mainLayoutCubit = MainLayoutCubit();
    eventController = StreamController<BaseUiEvent>.broadcast();
    stateController = StreamController<OrderScreenState>.broadcast();

    // Default stubs to prevent MissingStubError
    when(mockCubit.state).thenReturn(const OrderScreenState());
    when(mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(mockCubit.eventStream).thenAnswer((_) => eventController.stream);
    when(mockCubit.close()).thenAnswer((_) async => {});
    when(mockCubit.doEvent(any)).thenReturn(null);

    // Mock getIt
    if (getIt.isRegistered<OrderScreenCubit>()) {
      getIt.unregister<OrderScreenCubit>();
    }
    getIt.registerFactory<OrderScreenCubit>(() => mockCubit);
  });

  tearDown(() {
    eventController.close();
    stateController.close();
    mainLayoutCubit.close();
    if (getIt.isRegistered<OrderScreenCubit>()) {
      getIt.unregister<OrderScreenCubit>();
    }
  });

  Widget createWidget({int mainIndex = 1}) {
    mainLayoutCubit.changeIndex(mainIndex);

    return MaterialApp(
      home: Scaffold(
        body: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => BlocProvider<MainLayoutCubit>.value(
            value: mainLayoutCubit,
            child: const OrdersScreen(),
          ),
        ),
      ),
    );
  }

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

  group('OrdersScreen Lazy Loading Tests', () {
    testWidgets('calls GetDriverOrdersEvent when index is 1 on init', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(mainIndex: 1));
      verify(mockCubit.doEvent(argThat(isA<GetDriverOrdersEvent>()))).called(1);
    });

    testWidgets(
      'does not call GetDriverOrdersEvent when index is not 1 on init',
      (tester) async {
        await tester.pumpWidget(createWidget(mainIndex: 0));
        verifyNever(mockCubit.doEvent(any));
      },
    );

    testWidgets('calls GetDriverOrdersEvent when index changes from 0 to 1', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(mainIndex: 0));
      verifyNever(mockCubit.doEvent(any));

      // Simulate index change
      mainLayoutCubit.changeIndex(1);

      await tester.pump();
      verify(mockCubit.doEvent(argThat(isA<GetDriverOrdersEvent>()))).called(1);
    });
  });

  group('OrdersScreen Widget Rendering Tests', () {
    testWidgets('shows Skeletonizer when ordersState is loading', (
      tester,
    ) async {
      final state = const OrderScreenState(
        ordersState: BaseState(isLoading: true),
      );

      when(mockCubit.state).thenReturn(state);

      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final skeletonizerFinder = find.byWidgetPredicate(
        (widget) => widget is Skeletonizer,
      );
      expect(skeletonizerFinder, findsOneWidget);

      final skeletonizer = tester.widget<Skeletonizer>(skeletonizerFinder);
      expect(skeletonizer.enabled, isTrue);
    });

    testWidgets('shows Lottie empty state when list is empty', (tester) async {
      final state = const OrderScreenState(ordersState: BaseState(data: []));

      when(mockCubit.state).thenReturn(state);

      await tester.pumpWidget(createWidget());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Lottie), findsOneWidget);
    });

    testWidgets('shows Orders list and summary when data is loaded', (
      tester,
    ) async {
      final state = OrderScreenState(
        ordersState: const BaseState(data: [tOrder]),
        completedCount: 1,
        cancelledCount: 0,
      );

      when(mockCubit.state).thenReturn(state);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(OrdersTabSummarySection), findsOneWidget);
      expect(find.byType(OrderCardItem), findsOneWidget);
    });

    testWidgets('shows PaginationBar when totalPages > 1', (tester) async {
      final state = OrderScreenState(
        ordersState: const BaseState(data: [tOrder]),
        currentPage: 1,
        totalPages: 5,
      );

      when(mockCubit.state).thenReturn(state);

      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PaginationBar, skipOffstage: false), findsOneWidget);
    });

    testWidgets('does not show PaginationBar when totalPages <= 1', (
      tester,
    ) async {
      final state = OrderScreenState(
        ordersState: const BaseState(data: [tOrder]),
        currentPage: 1,
        totalPages: 1,
      );

      when(mockCubit.state).thenReturn(state);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PaginationBar), findsNothing);
    });
  });
}
