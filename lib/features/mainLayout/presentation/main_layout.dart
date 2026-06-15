import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/home_screen.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/orders_screen.dart';
import 'package:flowery_rider_app/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';

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
          backgroundColor: AppColors.white,
          indicatorColor: Colors.transparent,
          elevation: 0,

          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: currentIndex == 0
                    ? AppColors.primary
                    : AppColors.black30,
              ),
              selectedIcon: const Icon(Icons.home, color: AppColors.primary),
              label: AppStrings.home,
            ),

            NavigationDestination(
              icon: Icon(
                Icons.fact_check_outlined,
                color: currentIndex == 1
                    ? AppColors.primary
                    : AppColors.black30,
              ),
              selectedIcon: const Icon(
                Icons.fact_check,
                color: AppColors.primary,
              ),
              label: AppStrings.orders,
            ),

            NavigationDestination(
              icon: Icon(
                Icons.person_outline,
                color: currentIndex == 2
                    ? AppColors.primary
                    : AppColors.black30,
              ),
              selectedIcon: const Icon(Icons.person, color: AppColors.primary),
              label: AppStrings.profile,
            ),
          ],
        ),
      ),
    );
  }
}
