import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/cache_active_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/clear_active_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_active_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/open_communication_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/start_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/update_order_state_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/order_details_screen.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/order_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'order_details_screen_test.mocks.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);
  final Map<String, Map<String, dynamic>> _data;
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

@GenerateMocks([
  UpdateOrderStateUseCase,
  StartOrderUseCase,
  OpenCommunicationUseCase,
  CacheActiveOrderUseCase,
  GetActiveOrderUseCase,
  ClearActiveOrderUseCase,
])
void main() {
  late MockUpdateOrderStateUseCase mockUpdateUseCase;
  late MockStartOrderUseCase mockStartUseCase;
  late MockOpenCommunicationUseCase mockCommUseCase;
  late MockCacheActiveOrderUseCase mockCacheUseCase;
  late MockGetActiveOrderUseCase mockGetUseCase;
  late MockClearActiveOrderUseCase mockClearUseCase;
  late OrderDetailsCubit cubit;
  late Map<String, Map<String, dynamic>> translations;

  const surface = Size(700, 1400);
  final tOrder = OrderEntity(
    id: '123456',
    orderNumber: '123456',
    state: 'pending',
    createdAt: 'Wed, 03 Sep 2024, 11:00 AM',
    paymentType: 'Cash',
    store: const StoreEntity(
      name: 'Flowery store',
      image: '',
      address: '20th st, Sheikh Zayed, Giza',
      phoneNumber: '01000000000',
      lat: '0.0',
      long: '0.0',
    ),
    user: const UserEntity(
      id: 'u1',
      fullName: 'Nour mohamed',
      phone: '01111111111',
      photo: '',
    ),
    totalPrice: 150,
    orderItems: const [],
    shippingAddress: const ShippingAddressEntity(
      street: 'Street',
      city: 'Giza',
      phone: '333',
      lat: '0.0',
      long: '0.0',
    ),
  );

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    translations = {
      'en': {
        AppStrings.orderDetails: 'Order details',
        AppStrings.pickupAddress: 'Pickup address',
        AppStrings.userAddress: 'User address',
        AppStrings.cashOnDelivery: 'Cash on delivery',
        AppStrings.orderID: 'Order ID',
        AppStrings.status: 'Status',
        AppStrings.accepted: 'Accepted',
        AppStrings.arrivedAtPickup: 'Arrived at Pickup',
        AppStrings.picked: 'Picked',
        AppStrings.outForDelivery: 'Out for delivery',
        AppStrings.arrived: 'Arrived',
        AppStrings.delivered: 'Delivered',
        AppStrings.total: 'Total',
        AppStrings.paymentMethod: 'Payment method',
        AppStrings.egp: 'EGP',
        AppStrings.arrivedAtPickupPoint: 'Arrived at Pickup point',
        AppStrings.startDeliver: 'Start deliver',
        AppStrings.arrivedToTheUser: 'Arrived to the user',
        AppStrings.deliveredToTheUser: 'Delivered to the user',
        AppStrings.oops: 'Oops',
        'confirm_cancel_order_title': 'Cancel Order?',
        'confirm_cancel_order_message': 'Are you sure?',
        'cancel': 'Cancel',
        'confirm': 'Confirm',
      },
    };
  });

  setUp(() {
    mockUpdateUseCase = MockUpdateOrderStateUseCase();
    mockStartUseCase = MockStartOrderUseCase();
    mockCommUseCase = MockOpenCommunicationUseCase();
    mockCacheUseCase = MockCacheActiveOrderUseCase();
    mockGetUseCase = MockGetActiveOrderUseCase();
    mockClearUseCase = MockClearActiveOrderUseCase();

    provideDummy<BaseResponse<OrderEntity>>(ErrorBaseResponse('dummy'));

    when(mockGetUseCase()).thenAnswer((_) async => null);
    when(
      mockStartUseCase(any),
    ).thenAnswer((_) async => SuccessBaseResponse(tOrder));
    when(mockCacheUseCase(any, any)).thenAnswer((_) async {});

    cubit = OrderDetailsCubit(
      mockUpdateUseCase,
      mockStartUseCase,
      mockCommUseCase,
      mockCacheUseCase,
      mockGetUseCase,
      mockClearUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  Future<void> pumpOrderDetailsScreen(WidgetTester tester) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        assetLoader: _InMemoryAssetLoader(translations),
        child: Builder(
          builder: (context) => ScreenUtilInit(
            designSize: surface,
            builder: (_, _) => MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: BlocProvider<OrderDetailsCubit>.value(
                value: cubit,
                child: OrderDetailsScreen(
                  args: OrderDetailsArgs(order: tOrder),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();
  }

  group('OrderDetailsScreen UI Rendering', () {
    testWidgets('renders all order details correctly', (tester) async {
      await pumpOrderDetailsScreen(tester);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Order details'),
        ),
        findsOneWidget,
      );

      expect(find.textContaining('123456'), findsOneWidget);
      expect(find.text('Flowery store'), findsOneWidget);
      expect(find.text('Nour mohamed'), findsOneWidget);
      expect(find.textContaining('150'), findsOneWidget);
      expect(find.byType(OrderActionButton), findsOneWidget);
    });
  });
}
