import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/services/location_service.dart';
import 'package:flowery_rider_app/config/services/osrm_routing_service.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_order_shipping_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/open_communication_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/update_rider_location_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/map_screen.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/map_view_model/map_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/map/location_error_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'map_screen_test.mocks.dart';

class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);

  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

@GenerateMocks([
  LocationService,
  OpenCommunicationUseCase,
  OsrmRoutingService,
  GetOrderShippingUseCase,
  UpdateRiderLocationUseCase,
])
void main() {
  late MapCubit cubit;
  late MockLocationService mockLocationService;
  late MockOpenCommunicationUseCase mockOpenCommunicationUseCase;
  late MockOsrmRoutingService mockRoutingService;
  late MockGetOrderShippingUseCase mockGetOrderShippingUseCase;
  late MockUpdateRiderLocationUseCase mockUpdateRiderLocationUseCase;
  late Map<String, Map<String, dynamic>> translations;

  const surface = Size(700, 1400);

  const store = StoreEntity(
    name: 'Flowery store',
    image: '',
    address: 'Store Addr',
    phoneNumber: '01000000000',
    lat: '30.0',
    long: '31.0',
  );
  const user = UserEntity(
    id: 'u1',
    fullName: 'Nour mohamed',
    phone: '01111111111',
    photo: '',
  );
  const shipping = ShippingAddressEntity(
    street: 'Street',
    city: 'Giza',
    phone: '0122',
    lat: '30.1',
    long: '31.1',
  );
  final tOrder = OrderEntity(
    id: '1',
    orderNumber: 'ORD-1',
    totalPrice: 150,
    state: 'inProgress',
    createdAt: '',
    paymentType: 'cash',
    user: user,
    store: store,
    orderItems: const [],
    shippingAddress: shipping,
  );

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    translations = {
      'en': {
        AppStrings.pickupAddress: 'Pickup address',
        AppStrings.userAddress: 'User address',
        AppStrings.retry: 'Retry',
        AppStrings.locationPermissionRequired:
            'Location permission is required to show your location.',
      },
    };
  });

  setUp(() {
    mockLocationService = MockLocationService();
    mockOpenCommunicationUseCase = MockOpenCommunicationUseCase();
    mockRoutingService = MockOsrmRoutingService();
    mockGetOrderShippingUseCase = MockGetOrderShippingUseCase();
    mockUpdateRiderLocationUseCase = MockUpdateRiderLocationUseCase();
    when(mockGetOrderShippingUseCase(any)).thenAnswer((_) async => null);
    when(
      mockUpdateRiderLocationUseCase(
        orderId: anyNamed('orderId'),
        lat: anyNamed('lat'),
        long: anyNamed('long'),
      ),
    ).thenAnswer((_) async {});

    // Permission denied → the cubit fails fast and never starts the live
    // tracking timer, keeping the widget test free of pending timers.
    when(
      mockLocationService.isLocationServiceEnabled(),
    ).thenAnswer((_) async => true);
    when(
      mockLocationService.checkPermission(),
    ).thenAnswer((_) async => LocationPermission.denied);
    when(
      mockLocationService.requestPermission(),
    ).thenAnswer((_) async => LocationPermission.denied);

    cubit = MapCubit(
      mockLocationService,
      mockOpenCommunicationUseCase,
      mockRoutingService,
      mockGetOrderShippingUseCase,
      mockUpdateRiderLocationUseCase,
    );
  });

  tearDown(() => cubit.close());

  Future<void> pumpMapScreen(WidgetTester tester) async {
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
              home: BlocProvider<MapCubit>.value(
                value: cubit,
                child: MapScreen(
                  order: tOrder,
                  locationType: LocationType.user,
                  targetLat: tOrder.shippingAddress.lat,
                  targetLong: tOrder.shippingAddress.long,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // Let the async location flow resolve (no pumpAndSettle: FlutterMap + the
    // draggable sheet keep frames scheduled).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
  }

  testWidgets('renders the map and the address cards', (tester) async {
    await pumpMapScreen(tester);

    expect(find.byType(FlutterMap), findsOneWidget);
    // Names can appear both on the map marker and the address card.
    expect(find.text('Flowery store'), findsAtLeastNWidgets(1));
    expect(find.text('Nour mohamed'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows the location error card when permission is denied', (
    tester,
  ) async {
    await pumpMapScreen(tester);

    expect(find.byType(LocationErrorCard), findsOneWidget);
    expect(
      find.text('Location permission is required to show your location.'),
      findsOneWidget,
    );
  });

  testWidgets('tapping the phone icon triggers a contact call', (tester) async {
    when(mockOpenCommunicationUseCase(any, any)).thenAnswer((_) async => true);

    await pumpMapScreen(tester);

    final phoneIcon = find.byIcon(Icons.phone_outlined).first;
    await tester.ensureVisible(phoneIcon);
    await tester.tap(phoneIcon);
    await tester.pump();

    verify(
      mockOpenCommunicationUseCase('01000000000', CommunicationType.phone),
    ).called(1);
  });
}
