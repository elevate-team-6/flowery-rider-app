import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/di/di.dart';
import 'package:flowery_rider_app/core/utils/app_assets.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/mainLayout/presentation/view_model/main_layout_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/home_screen.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../profile/presentation/screens/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [const HomeScreen(), const OrdersScreen(), const ProfileScreen()];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MainLayoutCubit>(),
      child: BlocBuilder<MainLayoutCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            body: IndexedStack(index: currentIndex, children: _pages),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.black10, width: 1),
                ),
              ),
              child: NavigationBar(
                selectedIndex: currentIndex,
                elevation: 0,
                onDestinationSelected: (index) {
                  context.read<MainLayoutCubit>().changeIndex(index);
                },
                destinations: [
                  NavigationDestination(
                    icon: SvgPicture.asset(
                      AppIcons.home,
                      colorFilter: const ColorFilter.mode(
                        AppColors.black30,
                        BlendMode.srcIn,
                      ),
                    ),
                    selectedIcon: SvgPicture.asset(
                      AppIcons.home,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: AppStrings.home.tr(),
                  ),
                  NavigationDestination(
                    icon: SvgPicture.asset(
                      AppIcons.orders,
                      colorFilter: const ColorFilter.mode(
                        AppColors.black30,
                        BlendMode.srcIn,
                      ),
                    ),
                    selectedIcon: SvgPicture.asset(
                      AppIcons.orders,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: AppStrings.orders.tr(),
                  ),
                  NavigationDestination(
                    icon: SvgPicture.asset(
                      AppIcons.profile,
                      colorFilter: const ColorFilter.mode(
                        AppColors.black30,
                        BlendMode.srcIn,
                      ),
                    ),
                    selectedIcon: SvgPicture.asset(
                      AppIcons.profile,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: AppStrings.profile.tr(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
