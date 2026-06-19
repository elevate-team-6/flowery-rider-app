import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/home_screen.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/orders_screen.dart';
import 'package:flutter/material.dart';

import '../../profile/presentation/screens/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.black10, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,

          elevation: 0,

          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: AppStrings.home.tr(),
            ),

            NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: const Icon(Icons.fact_check),
              label: AppStrings.orders.tr(),
            ),

            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: AppStrings.profile.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
