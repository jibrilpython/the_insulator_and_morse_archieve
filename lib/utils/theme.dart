import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insulator_and_morse_archieve/utils/const.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kBackground,
  primaryColor: kAccent,
  colorScheme: const ColorScheme.dark(
    primary: kAccent,
    secondary: kAccentAmber,
    surface: kPanelBg,
    error: kError,
    outline: kOutline,
  ),

  // Typography overhaul for 2026 Premium
  textTheme: TextTheme(
    // Display - For large, airy headers
    displayLarge: GoogleFonts.dmSans(
      color: kPrimaryText,
      fontSize: 40.sp,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.0,
    ),
    displayMedium: GoogleFonts.dmSans(
      color: kPrimaryText,
      fontSize: 32.sp,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.5,
    ),
    displaySmall: GoogleFonts.dmSans(
      color: kPrimaryText,
      fontSize: 24.sp,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
    ),
    // Title - For section headers
    titleLarge: GoogleFonts.dmSans(
      color: kPrimaryText,
      fontSize: 20.sp,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    ),
    titleMedium: GoogleFonts.dmSans(
      color: kPrimaryText,
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
    ),
    // Body - For general reading
    bodyLarge: GoogleFonts.inter(
      color: kPrimaryText,
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.inter(
      color: kSecondaryText,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    // Label - For small metadata
    labelLarge: GoogleFonts.jetBrainsMono(
      color: kPrimaryText,
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelMedium: GoogleFonts.jetBrainsMono(
      color: kSecondaryText,
      fontSize: 11.sp,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.3,
    ),
    labelSmall: GoogleFonts.jetBrainsMono(
      color: kSecondaryText,
      fontSize: 10.sp,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
    ),
  ),

  // Integrated Input Style: Clear, high-contrast surface
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kPanelBg.withAlpha(150),
    hintStyle: GoogleFonts.inter(
      color: kSecondaryText.withAlpha(100),
      fontSize: 14.sp,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusStandard),
      borderSide: BorderSide(color: kOutline, width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusStandard),
      borderSide: BorderSide(color: kOutline, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusStandard),
      borderSide: BorderSide(color: kAccent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusStandard),
      borderSide: BorderSide(color: kError, width: 1.0),
    ),
  ),

  // Icon Theme
  iconTheme: IconThemeData(
    color: kPrimaryText,
    size: 24.sp,
  ),

  // App Bar
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: GoogleFonts.dmSans(
      color: kPrimaryText,
      fontSize: 22.sp,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.5,
    ),
    iconTheme: const IconThemeData(color: kPrimaryText),
  ),

  // Divider Theme
  dividerTheme: const DividerThemeData(
    color: kOutline,
    thickness: 1.0,
    space: 24,
  ),

  // Card Theme (for liquid capsules)
  cardTheme: CardThemeData(
    color: kPanelBg,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kRadiusStandard),
      side: const BorderSide(color: kOutline),
    ),
    margin: EdgeInsets.zero,
  ),
);
