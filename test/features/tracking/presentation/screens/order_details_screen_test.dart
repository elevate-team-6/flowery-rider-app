import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/cache/hive_helper.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/widgets/custom_flower_loading.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/open_communication_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/start_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/update_order_state_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/order_details_screen.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/confirm_cancel_dialog.dart';
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
  HiveHelper,
])
void main() {
  late MockUpdateOrderStateUseCase mockUpdateUseCase;
  late MockStartOrderUseCase mockStartUseCase;
  late MockOpenCommunicationUseCase mockCommUseCase;
  late MockHiveHelper mockHiveHelper;
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
    mockHiveHelper = MockHiveHelper();

    provideDummy<BaseResponse<OrderEntity>>(ErrorBaseResponse('dummy'));

    when(
      mockStartUseCase(any),
    ).thenAnswer((_) async => SuccessBaseResponse(tOrder));

    cubit = OrderDetailsCubit(
      mockUpdateUseCase,
      mockStartUseCase,
      mockCommUseCase,
      mockHiveHelper,
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

    testWidgets('shows loading dialog during initial fetch', (tester) async {
      final completer = Completer<BaseResponse<OrderEntity>>();
      when(mockStartUseCase(any)).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en')],
          path: 'assets/translations',
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
      expect(find.byType(LoadingDialog), findsOneWidget);
    });
  });

  group('OrderDetailsScreen Interactions', () {
    testWidgets('triggers NextStepEvent on button press', (tester) async {
      when(
        mockUpdateUseCase(any, any),
      ).thenAnswer((_) async => SuccessBaseResponse(tOrder));

      await pumpOrderDetailsScreen(tester);
      await tester.tap(find.byType(OrderActionButton));
      await tester.pump();

      verify(mockUpdateUseCase('123456', any)).called(1);
    });

    testWidgets('triggers CallPhoneEvent when phone icon is tapped', (
      tester,
    ) async {
      when(mockCommUseCase(any, any)).thenAnswer((_) async => true);

      await pumpOrderDetailsScreen(tester);

      final phoneIcons = find.byIcon(Icons.phone_outlined);
      expect(phoneIcons, findsAtLeastNWidgets(1));

      await tester.tap(phoneIcons.first);
      await tester.pumpAndSettle();

      verify(mockCommUseCase('01000000000', any)).called(1);
    });

    testWidgets('triggers OpenWhatsAppEvent when WhatsApp icon is tapped', (
      tester,
    ) async {
      when(mockCommUseCase(any, any)).thenAnswer((_) async => true);

      await pumpOrderDetailsScreen(tester);

      final whatsAppIcons = find.byIcon(Icons.chat_outlined);
      expect(whatsAppIcons, findsAtLeastNWidgets(1));

      await tester.tap(whatsAppIcons.first);
      await tester.pumpAndSettle();

      verify(mockCommUseCase('01000000000', any)).called(1);
    });

    testWidgets(
      'triggers ConfirmBackButtonPressedEvent on AppBar back button',
      (tester) async {
        await pumpOrderDetailsScreen(tester);

        await tester.tap(find.byIcon(Icons.arrow_back_ios));
        await tester.pumpAndSettle();

        expect(find.byType(ConfirmCancelDialog), findsOneWidget);
      },
    );
  });

  group('OrderDetailsScreen Side Effects', () {
    testWidgets(
      'shows ConfirmCancelDialog when ShowConfirmationDialogEvent is emitted',
      (tester) async {
        await pumpOrderDetailsScreen(tester);

        cubit.emitUiEvent(ShowConfirmationDialogEvent());
        await tester.pumpAndSettle();

        expect(find.byType(ConfirmCancelDialog), findsOneWidget);
      },
    );
  });

  group('OrderDetailsScreen Edge Cases', () {
    testWidgets('renders empty items list without crashing', (tester) async {
      final orderWithoutItems = tOrder.copyWith(orderItems: []);
      when(
        mockStartUseCase(any),
      ).thenAnswer((_) async => SuccessBaseResponse(orderWithoutItems));

      await pumpOrderDetailsScreen(tester);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Order details'),
        ),
        findsOneWidget,
      );
    });
  });
}
