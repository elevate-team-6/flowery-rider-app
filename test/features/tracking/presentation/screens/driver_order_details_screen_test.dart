import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/driver_order_details_screen.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/address_info_card.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/order_items_list.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/order_status_badge.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/order_summary_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tOrder = OrderEntity(
    id: '1',
    orderNumber: '123456',
    totalPrice: 3000,
    state: 'completed',
    createdAt: '2023-10-10',
    paymentType: 'Cash on delivery',
    user: UserEntity(
      id: 'u1',
      fullName: 'Nour mohamed',
      phone: '0123456789',
      photo: 'user_photo_url',
    ),
    store: StoreEntity(
      name: 'Flowery store',
      image: 'store_logo_url',
      address: '20th st, Sheikh Zayed, Giza',
      phoneNumber: '0100000000',
      lat: '30.0',
      long: '31.0',
    ),
    orderItems: [
      OrderItemEntity(
        productName: 'Red roses',
        productImage: 'product_url',
        price: 600,
        quantity: 1,
      ),
    ],
    shippingAddress: ShippingAddressEntity(
      street: '20th st',
      city: 'Sheikh Zayed, Giza',
      phone: '0123456789',
      lat: '30.1',
      long: '31.1',
    ),
  );

  const tCancelledOrder = OrderEntity(
    id: '2',
    orderNumber: '654321',
    totalPrice: 1500,
    state: 'canceled',
    createdAt: '2023-10-11',
    paymentType: 'Credit Card',
    user: UserEntity(
      id: 'u2',
      fullName: 'Ahmed Ali',
      phone: '0111111111',
      photo: '',
    ),
    store: StoreEntity(
      name: 'Flower Shop',
      image: '',
      address: 'Cairo, Egypt',
      phoneNumber: '0122222222',
      lat: '30.0',
      long: '31.0',
    ),
    orderItems: [],
    shippingAddress: ShippingAddressEntity(
      street: 'Nasr City',
      city: 'Cairo',
      phone: '0111111111',
      lat: '30.2',
      long: '31.2',
    ),
  );

  Widget createWidget(OrderEntity order) {
    return MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(
          1000,
          2000,
        ), // Larger size to prevent overflow in tests
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => DriverOrderDetailsScreen(order: order),
      ),
    );
  }

  group('DriverOrderDetailsScreen Tests', () {
    testWidgets('should display correct order details and widgets', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(tOrder));
      await tester.pump();

      // Verify AppBar title and Section header
      expect(find.text('order_details'), findsNWidgets(2));

      // Verify Header details
      expect(find.text('completed'), findsOneWidget);
      expect(find.text('# 123456'), findsOneWidget);

      // Verify correct badge usage
      expect(find.byType(OrderStatusBadge), findsOneWidget);

      // Verify AddressInfoCards existence
      expect(find.byType(AddressInfoCard), findsNWidgets(2));
      expect(find.text('Flowery store'), findsOneWidget);
      expect(find.text('Nour mohamed'), findsOneWidget);

      // Verify OrderItemsList
      expect(find.byType(OrderItemsList), findsOneWidget);

      // Verify OrderSummarySection
      expect(find.byType(OrderSummarySection), findsOneWidget);
    });

    testWidgets('should show correct color for each status', (tester) async {
      // Test Completed
      await tester.pumpWidget(createWidget(tOrder));
      await tester.pump();

      // Note: The screen explicitly passes AppTextStyles.black16600 to OrderStatusBadge
      // which overrides the status color. So we expect black.
      final completedText = tester.widget<Text>(find.text('completed'));
      expect(completedText.style?.color, AppColors.black);

      // Test Cancelled
      await tester.pumpWidget(createWidget(tCancelledOrder));
      await tester.pump();

      // In OrderStatusBadge: case DriverOrderState.canceled returns AppStrings.cancelledStatus.tr()
      // Since localization is not initialized, it uses the key 'cancelled_status'
      final cancelledText = tester.widget<Text>(find.text('cancelled_status'));
      expect(cancelledText.style?.color, AppColors.black);

      // Test Pending/Other
      final tPendingOrder = OrderEntity(
        id: '3',
        orderNumber: '111',
        totalPrice: 100,
        state: 'pending',
        createdAt: '',
        paymentType: '',
        user: tOrder.user,
        store: tOrder.store,
        orderItems: const [],
        shippingAddress: tOrder.shippingAddress,
      );
      await tester.pumpWidget(createWidget(tPendingOrder));
      await tester.pump();
      final pendingText = tester.widget<Text>(find.text('pending'));
      expect(pendingText.style?.color, AppColors.black);
    });

    testWidgets('should navigate back when back button is pressed', (
      tester,
    ) async {
      final routes = {
        '/': (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/details'),
              child: const Text('Go'),
            ),
          ),
        ),
        '/details': (context) => DriverOrderDetailsScreen(order: tOrder),
      };

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1000, 2000),
          builder: (context, child) =>
              MaterialApp(initialRoute: '/', routes: routes),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(DriverOrderDetailsScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(DriverOrderDetailsScreen), findsNothing);
    });

    group('Boundary Rules & Zero Nullability Verification', () {
      testWidgets('should handle empty image strings gracefully', (
        tester,
      ) async {
        final orderWithEmptyImages = OrderEntity(
          id: tOrder.id,
          orderNumber: tOrder.orderNumber,
          totalPrice: tOrder.totalPrice,
          state: tOrder.state,
          createdAt: tOrder.createdAt,
          paymentType: tOrder.paymentType,
          user: UserEntity(
            id: tOrder.user.id,
            fullName: tOrder.user.fullName,
            phone: tOrder.user.phone,
            photo: '',
          ),
          store: StoreEntity(
            name: tOrder.store.name,
            image: '',
            address: tOrder.store.address,
            phoneNumber: tOrder.store.phoneNumber,
            lat: tOrder.store.lat,
            long: tOrder.store.long,
          ),
          orderItems: tOrder.orderItems,
          shippingAddress: tOrder.shippingAddress,
        );

        await tester.pumpWidget(createWidget(orderWithEmptyImages));
        await tester.pump();

        expect(find.byType(DriverOrderDetailsScreen), findsOneWidget);
      });
    });
  });
}
