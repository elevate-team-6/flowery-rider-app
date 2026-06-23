import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/di/di.dart';
import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/widgets/custom_error_state.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_pending_orders_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/home_screen.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/tracking_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/empty_orders_state.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen_test.mocks.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);

  /// Translations keyed by language code (e.g. `en`, `ar`).
  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

@GenerateMocks([GetPendingOrdersUseCase])
void main() {
  late MockGetPendingOrdersUseCase mockUseCase;
  late Map<String, Map<String, dynamic>> translations;

  const surface = Size(700, 1400);

  const order1 = OrderEntity(
    id: '1',
    orderNumber: 'ORD-1',
    totalPrice: 150,
    store: StoreEntity(name: 'Flower Store', address: 'Cairo'),
    user: UserEntity(fullName: 'Ahmed Ali'),
    shippingAddress: ShippingAddressEntity(street: 'Street 1', city: 'Giza'),
  );
  const order2 = OrderEntity(
    id: '2',
    orderNumber: 'ORD-2',
    totalPrice: 200,
    store: StoreEntity(name: 'Rose Shop', address: 'Alex'),
    user: UserEntity(fullName: 'Sara Mohamed'),
  );
  const ordersEntity = PendingOrdersEntity(
    message: 'success',
    orders: [order1, order2],
  );

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    translations = {
      AppConstants.englishCode:
          json.decode(
                await rootBundle.loadString(
                  '${AppConstants.translationsPath}/${AppConstants.englishCode}.json',
                ),
              )
              as Map<String, dynamic>,
      AppConstants.arabicCode:
          json.decode(
                await rootBundle.loadString(
                  '${AppConstants.translationsPath}/${AppConstants.arabicCode}.json',
                ),
              )
              as Map<String, dynamic>,
    };
  });

  setUp(() {
    mockUseCase = MockGetPendingOrdersUseCase();

    provideDummy<BaseResponse<PendingOrdersEntity>>(ErrorBaseResponse('dummy'));

    // HomeScreen builds its cubit from the service locator, so register one
    // backed by the mocked use case for the duration of each test.
    if (getIt.isRegistered<TrackingCubit>()) {
      getIt.unregister<TrackingCubit>();
    }
    getIt.registerFactory<TrackingCubit>(() => TrackingCubit(mockUseCase));
  });

  tearDown(() {
    if (getIt.isRegistered<TrackingCubit>()) {
      getIt.unregister<TrackingCubit>();
    }
  });

  Future<void> pumpHomeScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      EasyLocalization(
        key: ValueKey(locale),
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: AppConstants.translationsPath,
        fallbackLocale: const Locale('en'),
        startLocale: locale,
        assetLoader: _InMemoryAssetLoader(translations),
        child: Builder(
          builder: (context) => ScreenUtilInit(
            designSize: surface,
            builder: (_, _) => MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              debugShowCheckedModeBanner: false,
              builder: BotToastInit(),
              home: const HomeScreen(),
            ),
          ),
        ),
      ),
    );
  }

  group('HomeScreen - loading', () {
    testWidgets('requests pending orders on init and shows no orders '
        'while loading', (tester) async {
      // Never completes so the screen stays in the loading state.
      when(mockUseCase.call(page: anyNamed('page'))).thenAnswer(
        (_) => Completer<BaseResponse<PendingOrdersEntity>>().future,
      );

      await pumpHomeScreen(tester);
      await tester.pump();

      verify(mockUseCase.call(page: anyNamed('page'))).called(1);
      expect(find.byType(OrderCard), findsNothing);
      expect(find.byType(EmptyOrdersState), findsNothing);
    });
  });

  group('HomeScreen - empty', () {
    testWidgets('shows the empty state when there are no orders', (
      tester,
    ) async {
      when(mockUseCase.call(page: anyNamed('page'))).thenAnswer(
        (_) async => SuccessBaseResponse(const PendingOrdersEntity(orders: [])),
      );

      await pumpHomeScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(EmptyOrdersState), findsOneWidget);
      expect(find.text(AppStrings.noPendingOrders.tr()), findsOneWidget);
      expect(find.byType(OrderCard), findsNothing);
    });
  });

  group('HomeScreen - error', () {
    testWidgets('shows the error state and retries when the button is tapped', (
      tester,
    ) async {
      when(
        mockUseCase.call(page: anyNamed('page')),
      ).thenAnswer((_) async => ErrorBaseResponse('network error'));

      await pumpHomeScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(CustomErrorState), findsOneWidget);
      expect(find.text('network error'), findsOneWidget);

      // The initial load already consumed one call; tapping retry triggers
      // another fetch.
      await tester.tap(find.text(AppStrings.retry.tr()));
      await tester.pumpAndSettle();

      verify(mockUseCase.call(page: anyNamed('page'))).called(2);
    });
  });

  group('HomeScreen - orders list', () {
    testWidgets('renders a card per pending order', (tester) async {
      when(
        mockUseCase.call(page: anyNamed('page')),
      ).thenAnswer((_) async => SuccessBaseResponse(ordersEntity));

      await pumpHomeScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(OrderCard), findsNWidgets(2));
      expect(find.text('Flower Store'), findsOneWidget);
      expect(find.text('Rose Shop'), findsOneWidget);
      expect(find.text('Ahmed Ali'), findsOneWidget);
    });

    testWidgets('removes a card locally when reject is tapped', (tester) async {
      when(
        mockUseCase.call(page: anyNamed('page')),
      ).thenAnswer((_) async => SuccessBaseResponse(ordersEntity));

      await pumpHomeScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(OrderCard), findsNWidgets(2));

      // Reject the first order; it should disappear from the list without
      // re-fetching from the server.
      await tester.tap(find.text(AppStrings.reject.tr()).first);
      await tester.pumpAndSettle();

      expect(find.byType(OrderCard), findsOneWidget);
      verify(mockUseCase.call(page: anyNamed('page'))).called(1);
    });
  });
}
