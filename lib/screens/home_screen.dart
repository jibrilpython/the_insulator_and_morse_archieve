import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insulator_and_morse_archieve/enum/my_enums.dart';
import 'package:insulator_and_morse_archieve/models/archive_item_model.dart';
import 'package:insulator_and_morse_archieve/providers/image_provider.dart';
import 'package:insulator_and_morse_archieve/providers/input_provider.dart';
import 'package:insulator_and_morse_archieve/providers/project_provider.dart';
import 'package:insulator_and_morse_archieve/providers/search_provider.dart';
import 'package:insulator_and_morse_archieve/utils/const.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  HardwareCategory? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _meshController;

  @override
  void initState() {
    super.initState();
    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _meshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = ref.watch(searchProvider);
    final projectProv = ref.watch(projectProvider);
    final allEntries = projectProv.entries;

    final filteredByType = _selectedFilter == null
        ? allEntries
        : allEntries.where((e) => e.itemCategory == _selectedFilter).toList();
    final entries = searchProv.filteredList(filteredByType);

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
                  painter: _MeshGradientPainter(_meshController.value),
                );
              },
            ),
          ),

          // 2. Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(allEntries.length),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                  child: Column(children: [_buildSearchAndFilters()]),
                ),
              ),
              entries.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  : SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 140.h),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final entry = entries[index];
                          final mainIndex = allEntries.indexOf(entry);
                          return _buildSpecimenCapsule(entry, mainIndex);
                        }, childCount: entries.length),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(int count) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20.w, 64.h, 20.w, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ARCHIVE REGISTER // MASTER',
                      style: GoogleFonts.jetBrainsMono(
                        color: kAccent,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'THE\nARCHIVE',
                      style: GoogleFonts.dmSans(
                        color: kPrimaryText,
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w900,
                        height: 0.9,
                        letterSpacing: -2.0,
                      ),
                    ),
                  ],
                ),
                // Floating Add Button (Sleeker integration)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(inputProvider).clearAll();
                    ref.read(imageProvider).clearImage();
                    Navigator.pushNamed(context, '/add_screen');
                  },
                  child: Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: kAccent,
                      borderRadius: BorderRadius.circular(kRadiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: kAccent.withAlpha(50),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: kBackground,
                      size: 28.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            // Specimen Count Pill
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: kPanelBg.withAlpha(150),
                borderRadius: BorderRadius.circular(kRadiusPill),
                border: Border.all(color: kOutline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      color: kAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    '${count.toString().padLeft(2, '0')} TOTAL SPECIMENS',
                    style: GoogleFonts.jetBrainsMono(
                      color: kPrimaryText,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // Search
        Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: kPanelBg.withAlpha(150),
            borderRadius: BorderRadius.circular(kRadiusStandard),
            border: Border.all(color: kOutline),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: kSecondaryText, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      ref.read(searchProvider.notifier).setSearchQuery(v),
                  style: GoogleFonts.inter(
                    color: kPrimaryText,
                    fontSize: 15.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by CD or maker...',
                    hintStyle: GoogleFonts.inter(
                      color: kSecondaryText.withAlpha(100),
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    ref.read(searchProvider.notifier).clearSearchQuery();
                    setState(() {});
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: kSecondaryText,
                    size: 18.sp,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Filter Chips
        SizedBox(
          height: 38.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _filterChip('All Items', null),
              ...HardwareCategory.values.map((c) => _filterChip(c.label, c)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, HardwareCategory? cat) {
    final isSelected = _selectedFilter == cat;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = cat);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          color: isSelected ? kAccent.withAlpha(40) : kPanelBg.withAlpha(150),
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(
            color: isSelected ? kAccent.withAlpha(120) : kOutline,
            width: 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? kAccent : kSecondaryText,
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecimenCapsule(ArchiveItemModel entry, int index) {
    final imagePath = ref.watch(imageProvider).getImagePath(entry.photoPath);
    final catColor = getCategoryColor(entry.itemCategory);
    final glassColor = entry.glassColorOrGlazeType.isNotEmpty
        ? getGlassSwatchColor(entry.glassColorOrGlazeType)
        : null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.pushNamed(
          context,
          '/info_screen',
          arguments: {'index': index},
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        height: 160.h,
        decoration: BoxDecoration(
          color: kPanelBg.withAlpha(150),
          borderRadius: BorderRadius.circular(kRadiusXLarge),
          border: Border.all(color: kOutline, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Left: Image Module
            Container(
              width: 140.w,
              height: double.infinity,
              color: const Color(0xFF050505),
              child:
                  (imagePath != null &&
                      entry.photoPath.isNotEmpty &&
                      File(imagePath).existsSync())
                  ? Image.file(File(imagePath), fit: BoxFit.cover)
                  : Center(
                      child: Icon(
                        Icons.water_drop_outlined,
                        color: kOutline.withAlpha(100),
                        size: 32.sp,
                      ),
                    ),
            ),

            // Right: Info Module
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        if (glassColor != null) ...[
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: glassColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Text(
                          entry.itemCategory.label,
                          style: GoogleFonts.dmSans(
                            color: catColor,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      entry.manufacturerAndShopMark.isEmpty
                          ? 'Unknown Maker'
                          : entry.manufacturerAndShopMark,
                      style: GoogleFonts.dmSans(
                        color: kPrimaryText,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entry.cdOrStyleNumber.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        entry.cdOrStyleNumber,
                        style: GoogleFonts.jetBrainsMono(
                          color: kSecondaryText,
                          fontSize: 11.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: kBackground,
                              borderRadius: BorderRadius.circular(
                                kRadiusSubtle,
                              ),
                              border: Border.all(color: kOutline),
                            ),
                            child: Text(
                              entry.eraOfProduction.isEmpty
                                  ? 'Era Unknown'
                                  : entry.eraOfProduction,
                              style: GoogleFonts.dmSans(
                                color: kAccentAmber,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: kOutline,
                          size: 14.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: kPanelBg,
              shape: BoxShape.circle,
              border: Border.all(color: kOutline),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: kSecondaryText.withAlpha(50),
              size: 48.sp,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'EMPTY ARCHIVE',
            style: GoogleFonts.jetBrainsMono(
              color: kSecondaryText,
              fontSize: 12.sp,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start cataloging your collection.',
            style: GoogleFonts.jetBrainsMono(
              color: kSecondaryText.withAlpha(80),
              fontWeight: FontWeight.w500,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeshGradientPainter extends CustomPainter {
  final double animationValue;
  _MeshGradientPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Dynamic gradient movement
    final x = math.sin(animationValue * 2 * math.pi) * 0.1;
    final y = math.cos(animationValue * 2 * math.pi) * 0.1;

    final gradient = RadialGradient(
      center: Alignment(0.5 + x, -0.2 + y),
      radius: 1.5,
      colors: [kAccent.withAlpha(15), kBackground],
      stops: const [0.0, 1.0],
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Second soft glow
    final x2 = math.cos(animationValue * 2 * math.pi) * 0.15;
    final y2 = math.sin(animationValue * 2 * math.pi) * 0.15;

    final gradient2 = RadialGradient(
      center: Alignment(-0.8 + x2, 0.9 + y2),
      radius: 1.2,
      colors: [kAccentAmber.withAlpha(10), Colors.transparent],
    );

    paint.shader = gradient2.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _MeshGradientPainter oldDelegate) => true;
}
