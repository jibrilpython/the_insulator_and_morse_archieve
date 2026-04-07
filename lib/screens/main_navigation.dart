import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insulator_and_morse_archieve/screens/home_screen.dart';
import 'package:insulator_and_morse_archieve/screens/showcase_screen.dart';
import 'package:insulator_and_morse_archieve/screens/stats_screen.dart';
import 'package:insulator_and_morse_archieve/utils/const.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatsScreen(),
    const ShowcaseScreen(),
  ];

  void _onTap(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.mediumImpact();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      extendBody: true,
      body: Stack(
        children: [
          // Content
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Floating Command Hub
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 30.h,
            child: _buildCommandHub(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandHub() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(kRadiusXLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 72.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: kPanelBg.withAlpha(180),
            borderRadius: BorderRadius.circular(kRadiusXLarge),
            border: Border.all(
              color: Colors.white.withAlpha(20),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _hubItem(0, Icons.grid_view_rounded, 'ARCHIVE'),
              _hubItem(1, Icons.analytics_outlined, 'METRICS'),
              _hubItem(2, Icons.bubble_chart_outlined, 'MAPPING'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hubItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
          margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: isSelected ? kAccent.withAlpha(30) : Colors.transparent,
            borderRadius: BorderRadius.circular(kRadiusLarge),
            border: Border.all(
              color: isSelected ? kAccent.withAlpha(80) : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? kAccent : kSecondaryText,
                size: 20.sp,
              ),
              SizedBox(height: 2.h),
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  color: isSelected ? kAccent : kSecondaryText,
                  fontSize: 8.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
