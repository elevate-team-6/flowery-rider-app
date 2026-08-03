import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/services/location_service.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_order_shipping_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_route_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/open_communication_use_case.dart';
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
import 'package:latlong2/latlong.dart';
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
  GetRouteUseCase,
  GetOrderShippingUseCase,
])
void main() {
  late MapCubit cubit;
  late MockLocationService mockLocationService;
  late MockOpenCommunicationUseCase mockOpenCommunicationUseCase;
  late MockGetRouteUseCase mockGetRouteUseCase;
  late MockGetOrderShippingUseCase mockGetOrderShippingUseCase;
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
        AppStrings.yourLocation: 'Your location',
        AppStrings.locationPermissionRequired:
            'Location permission is required to show your location.',
      },
    };
  });

  setUp(() {
    mockLocationService = MockLocationService();
    mockOpenCommunicationUseCase = MockOpenCommunicationUseCase();
    mockGetRouteUseCase = MockGetRouteUseCase();
    mockGetOrderShippingUseCase = MockGetOrderShippingUseCase();
    when(mockGetOrderShippingUseCase(any)).thenAnswer((_) async => null);

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
      mockGetRouteUseCase,
      mockGetOrderShippingUseCase,
    );
  });

  tearDown(() => cubit.close());

  Position makePosition(double lat, double lng) => Position(
    latitude: lat,
    longitude: lng,
    timestamp: DateTime(2024, 1, 1),
    accuracy: 1,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  // Re-stubs the location service for the happy path: permission granted, a
  // known position available, and an empty live stream (so no fix ever arrives
  // after the first and the test stays free of pending timers). Call before
  // pumpMapScreen to exercise the map/route rendering instead of the error card.
  void stubGrantedLocation() {
    when(
      mockLocationService.checkPermission(),
    ).thenAnswer((_) async => LocationPermission.whileInUse);
    when(
      mockLocationService.getLastKnownPosition(),
    ).thenAnswer((_) async => makePosition(29.0, 30.0));
    when(
      mockLocationService.getCurrentPosition(settings: anyNamed('settings')),
    ).thenAnswer((_) async => makePosition(29.0, 30.0));
    when(
      mockLocationService.getPositionStream(settings: anyNamed('settings')),
    ).thenAnswer((_) => const Stream<Position>.empty());
    when(
      mockGetRouteUseCase(any, any),
    ).thenAnswer((_) async => const [LatLng(29.0, 30.0), LatLng(30.1, 31.1)]);
  }

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
                  args: MapArgs(
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
      ),
    );
    // Let the async location flow resolve (no pumpAndSettle: FlutterMap + the
    // draggable sheet keep frames scheduled).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
  }

  testWidgets('renders the map and both address cards', (tester) async {
    await pumpMapScreen(tester);

    expect(find.byType(FlutterMap), findsOneWidget);
    // Locate the cards by key: the store/rider names also render on the map
    // markers, so matching on the text would be ambiguous.
    expect(find.byKey(MapScreen.storeAddressCardKey), findsOneWidget);
    expect(find.byKey(MapScreen.userAddressCardKey), findsOneWidget);
  });

  testWidgets('renders the pickup and user address sections', (tester) async {
    await pumpMapScreen(tester);

    expect(find.text('Pickup address'), findsOneWidget);
    expect(find.text('User address'), findsOneWidget);
    expect(find.text('Store Addr'), findsOneWidget);
    expect(find.text('Street, Giza'), findsOneWidget);
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

  testWidgets('tapping retry on the error card re-runs the location flow', (
    tester,
  ) async {
    await pumpMapScreen(tester);

    // One resolve attempt happened on init; tapping retry triggers another.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(
      mockLocationService.checkPermission(),
    ).called(greaterThanOrEqualTo(2));
  });

  testWidgets('draws the route and live pill once location is granted', (
    tester,
  ) async {
    stubGrantedLocation();

    await pumpMapScreen(tester);

    expect(find.byType(LocationErrorCard), findsNothing);
    expect(find.text('Your location'), findsOneWidget);
    expect(find.byType(PolylineLayer), findsOneWidget);
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

  testWidgets('tapping the WhatsApp icon triggers a WhatsApp contact', (
    tester,
  ) async {
    when(mockOpenCommunicationUseCase(any, any)).thenAnswer((_) async => true);

    await pumpMapScreen(tester);

    final whatsappIcon = find.byIcon(Icons.chat_outlined).first;
    await tester.ensureVisible(whatsappIcon);
    await tester.tap(whatsappIcon);
    await tester.pump();

    verify(
      mockOpenCommunicationUseCase('01000000000', CommunicationType.whatsapp),
    ).called(1);
  });
}
