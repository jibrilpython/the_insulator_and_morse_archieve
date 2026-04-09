import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insulator_and_morse_archieve/providers/user_provider.dart';
import 'package:insulator_and_morse_archieve/utils/const.dart';

class InitialScreen extends ConsumerStatefulWidget {
  const InitialScreen({super.key});

  @override
  ConsumerState<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<InitialScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _meshController;

  @override
  void initState() {
    super.initState();
    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _meshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProv = ref.watch(userProvider);
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // 1. Kinetic Mesh Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _meshController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _InitialMeshPainter(_meshController.value),
                );
              },
            ),
          ),

          // 2. Main Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 40.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: kAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Archive Repository',
                        style: GoogleFonts.dmSans(
                          color: kAccent,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  // Hero Text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'The Grid\nKinetic.',
                        style: GoogleFonts.dmSans(
                          color: kPrimaryText,
                          fontSize: 64.sp,
                          fontWeight: FontWeight.w300,
                          height: 0.9,
                          letterSpacing: -3.0,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        'A high-fidelity digital repository for the hardware of the early telegraph and electrical infrastructure.',
                        style: GoogleFonts.inter(
                          color: kSecondaryText,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w300,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 48.h),
                      // Feature list with subtle glass
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          _tag('Hemingray'),
                          _tag('CD Series'),
                          _tag('Morse Bugs'),
                        ],
                      ),
                    ],
                  ),

                  // Action
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      userProv.setFirstTimeUser(false);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: Container(
                      width: double.infinity,
                      height: 64.h,
                      decoration: BoxDecoration(
                        color: kAccent,
                        borderRadius: BorderRadius.circular(kRadiusXLarge),
                        boxShadow: const [kShadowCyan],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'OPEN ARCHIVE',
                            style: GoogleFonts.jetBrainsMono(
                              color: kBackground,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: kBackground,
                            size: 18.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: kPanelBg.withAlpha(100),
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: kOutline),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          color: kSecondaryText,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InitialMeshPainter extends CustomPainter {
  final double animationValue;
  _InitialMeshPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Deep background
    paint.color = kBackground;
    canvas.drawRect(rect, paint);

    // Large soft glow moving slow
    final x = math.sin(animationValue * 2 * math.pi) * 0.2;
    final y = math.cos(animationValue * 2 * math.pi) * 0.1;

    final grad = RadialGradient(
      center: Alignment(0.4 + x, -0.1 + y),
      radius: 1.5,
      colors: [kAccent.withAlpha(20), Colors.transparent],
    );
    paint.shader = grad.createShader(rect);
    canvas.drawRect(rect, paint);

    // Amber glow
    final x2 = math.cos(animationValue * 2 * math.pi * 0.5) * 0.3;
    final grad2 = RadialGradient(
      center: Alignment(-0.5 + x2, 0.8),
      radius: 1.2,
      colors: [kAccentAmber.withAlpha(15), Colors.transparent],
    );
    paint.shader = grad2.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
