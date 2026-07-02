import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/services/location_service.dart';
import 'package:flowery_rider_app/config/services/osrm_routing_service.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/open_communication_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/map_view_model/map_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/map_view_model/map_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'map_cubit_test.mocks.dart';

@GenerateMocks([LocationService, OpenCommunicationUseCase, OsrmRoutingService])
void main() {
  late MapCubit cubit;
  late MockLocationService mockLocationService;
  late MockOpenCommunicationUseCase mockOpenCommunicationUseCase;
  late MockOsrmRoutingService mockRoutingService;

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

  const store = StoreEntity(
    name: 'Store',
    image: '',
    address: 'Addr',
    phoneNumber: '0100',
    lat: '30.0',
    long: '31.0',
  );
  const user = UserEntity(id: 'u1', fullName: 'Cust', phone: '0111', photo: '');
  const shipping = ShippingAddressEntity(
    street: 'St',
    city: 'City',
    phone: '0122',
    lat: '30.1',
    long: '31.1',
  );
  final tOrder = OrderEntity(
    id: '1',
    orderNumber: 'ORD-1',
    totalPrice: 100,
    state: 'inProgress',
    createdAt: '',
    paymentType: 'cash',
    user: user,
    store: store,
    orderItems: const [],
    shippingAddress: shipping,
  );

  MapInitializeEvent initEvent({
    String lat = '30.0',
    String long = '31.0',
    LocationType type = LocationType.user,
  }) => MapInitializeEvent(
    order: tOrder,
    locationType: type,
    targetLat: lat,
    targetLong: long,
  );

  void stubLocationGranted() {
    when(
      mockLocationService.isLocationServiceEnabled(),
    ).thenAnswer((_) async => true);
    when(
      mockLocationService.checkPermission(),
    ).thenAnswer((_) async => LocationPermission.whileInUse);
    when(
      mockLocationService.getLastKnownPosition(),
    ).thenAnswer((_) async => makePosition(29.0, 30.0));
    when(
      mockLocationService.getCurrentPosition(settings: anyNamed('settings')),
    ).thenAnswer((_) async => makePosition(29.0, 30.0));
  }

  setUp(() {
    mockLocationService = MockLocationService();
    mockOpenCommunicationUseCase = MockOpenCommunicationUseCase();
    mockRoutingService = MockOsrmRoutingService();
    cubit = MapCubit(
      mockLocationService,
      mockOpenCommunicationUseCase,
      mockRoutingService,
    );
  });

  tearDown(() => cubit.close());

  group('initialize - location errors', () {
    test('service disabled → locationError, no tracking / route', () async {
      when(
        mockLocationService.isLocationServiceEnabled(),
      ).thenAnswer((_) async => false);

      cubit.doEvent(initEvent());
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(cubit.state.locationError, AppStrings.locationServicesDisabled);
      expect(cubit.state.locating, false);
      expect(cubit.state.currentLocation, isNull);
      verifyNever(
        mockLocationService.getCurrentPosition(settings: anyNamed('settings')),
      );
      verifyNever(mockRoutingService.getRoute(any, any));
    });

    test('permission denied → locationError, never reads position', () async {
      when(
        mockLocationService.isLocationServiceEnabled(),
      ).thenAnswer((_) async => true);
      when(
        mockLocationService.checkPermission(),
      ).thenAnswer((_) async => LocationPermission.denied);
      when(
        mockLocationService.requestPermission(),
      ).thenAnswer((_) async => LocationPermission.denied);

      cubit.doEvent(initEvent());
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(cubit.state.locationError, AppStrings.locationPermissionRequired);
      verifyNever(mockLocationService.getLastKnownPosition());
    });
  });

  group('initialize - target parsing', () {
    test('parses target from valid coordinates', () {
      when(
        mockLocationService.isLocationServiceEnabled(),
      ).thenAnswer((_) async => false);

      cubit.doEvent(initEvent(lat: '30.5', long: '31.5'));

      expect(cubit.state.target, const LatLng(30.5, 31.5));
    });

    test('treats 0,0 as no destination → routeError after locating', () async {
      stubLocationGranted();

      cubit.doEvent(initEvent(lat: '0', long: '0'));
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(cubit.state.target, isNull);
      expect(cubit.state.routeError, true);
      expect(cubit.state.currentLocation, isNotNull);
      verifyNever(mockRoutingService.getRoute(any, any));
    });
  });

  group('routing', () {
    test('happy path loads the OSRM road route', () async {
      stubLocationGranted();
      when(mockRoutingService.getRoute(any, any)).thenAnswer(
        (_) async => const [LatLng(29, 30), LatLng(29.5, 30.5), LatLng(30, 31)],
      );

      cubit.doEvent(initEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.currentLocation, isNotNull);
      expect(cubit.state.routePoints.length, 3);
      expect(cubit.state.usingFallback, false);
      expect(cubit.state.routeLoading, false);
      verify(mockRoutingService.getRoute(any, any)).called(1);
    });

    test('empty OSRM result → straight-line fallback', () async {
      stubLocationGranted();
      when(
        mockRoutingService.getRoute(any, any),
      ).thenAnswer((_) async => const []);

      cubit.doEvent(initEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.usingFallback, true);
      expect(cubit.state.routePoints.length, 2);
      expect(cubit.state.routeLoading, false);
    });

    test('OSRM error → straight-line fallback', () async {
      stubLocationGranted();
      when(
        mockRoutingService.getRoute(any, any),
      ).thenThrow(Exception('network'));

      cubit.doEvent(initEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.usingFallback, true);
      expect(cubit.state.routePoints.length, 2);
    });
  });

  group('contact', () {
    test('empty phone emits error and skips the use case', () async {
      expectLater(cubit.eventStream, emits(isA<DisplayErrorEvent>()));

      cubit.doEvent(const MapContactEvent('', CommunicationType.phone));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      verifyNever(mockOpenCommunicationUseCase(any, any));
    });

    test('successful contact calls the use case', () async {
      when(
        mockOpenCommunicationUseCase(any, any),
      ).thenAnswer((_) async => true);

      cubit.doEvent(const MapContactEvent('0100', CommunicationType.phone));
      await untilCalled(mockOpenCommunicationUseCase(any, any));

      verify(
        mockOpenCommunicationUseCase('0100', CommunicationType.phone),
      ).called(1);
    });

    test('failed contact emits DisplayErrorEvent', () async {
      when(
        mockOpenCommunicationUseCase(any, any),
      ).thenAnswer((_) async => false);

      expectLater(cubit.eventStream, emits(isA<DisplayErrorEvent>()));

      cubit.doEvent(const MapContactEvent('0100', CommunicationType.whatsapp));
    });
  });
}
