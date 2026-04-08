import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insulator_and_morse_archieve/enum/my_enums.dart';
import 'package:insulator_and_morse_archieve/models/archive_item_model.dart';
import 'package:insulator_and_morse_archieve/providers/project_provider.dart';
import 'package:insulator_and_morse_archieve/utils/const.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _meshController;
  ConditionState? _selectedCondition;
  int? _selectedDecade;

  @override
  void initState() {
    super.initState();
    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _meshController?.dispose();
    super.dispose();
  }

  int? _parseYear(String era) {
    final digits = era.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 4) return int.tryParse(digits.substring(0, 4));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = ref.watch(projectProvider).entries;

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // 1. Kinetic Data Mesh
          if (_meshController != null)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _meshController!,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _DataMeshPainter(_meshController!.value),
                  );
                },
              ),
            ),

          // 2. Dashboard Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernAppBar(),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 140.h),
                sliver: allEntries.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      )
                    : SliverList(
                        delegate: SliverChildListDelegate([
                          _buildIntegrityHero(allEntries),
                          SizedBox(height: 32.h),
                          _sectionLabel('Condition Analysis'),
                          SizedBox(height: 16.h),
                          _buildInteractiveIntegrity(allEntries),
                          SizedBox(height: 32.h),
                          _sectionLabel('Temporal Distribution'),
                          SizedBox(height: 16.h),
                          _buildEraScrubber(allEntries),
                          SizedBox(height: 32.h),
                          _sectionLabel('Maker Dominance'),
                          SizedBox(height: 16.h),
                          _buildSignatureStack(allEntries),
                        ]),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar() {
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
                      'METRIC REGISTRY // ANALYTICS',
                      style: GoogleFonts.jetBrainsMono(
                        color: kAccent,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'THE\nMETRICS',
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
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: kPanelBg.withAlpha(150),
                    shape: BoxShape.circle,
                    border: Border.all(color: kOutline),
                  ),
                  child: Icon(
                    Icons.query_stats_rounded,
                    color: kAccent,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            // Status Pill
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
                    'PULSE // STABLE',
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

  Widget _buildIntegrityHero(List<ArchiveItemModel> entries) {
    return Container(
      decoration: BoxDecoration(
        color: kPanelBg.withAlpha(150),
        borderRadius: BorderRadius.circular(kRadiusLarge),
        border: Border.all(color: kOutline),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Metric
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL SPECIMENS',
                      style: GoogleFonts.dmSans(
                        color: kSecondaryText,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      entries.length.toString().padLeft(2, '0'),
                      style: GoogleFonts.dmSans(
                        color: kPrimaryText,
                        fontSize: 40.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            VerticalDivider(
              color: kOutline,
              width: 1,
              indent: 20.h,
              endIndent: 20.h,
            ),
            // Right Metric
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'GROWTH RATE',
                      style: GoogleFonts.dmSans(
                        color: kSecondaryText,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '+12',
                          style: GoogleFonts.dmSans(
                            color: kAccent,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          '%',
                          style: GoogleFonts.dmSans(
                            color: kAccent.withAlpha(150),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
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

  Widget _buildInteractiveIntegrity(List<ArchiveItemModel> entries) {
    final counts = <ConditionState, int>{};
    for (var e in entries) {
      counts[e.conditionState] = (counts[e.conditionState] ?? 0) + 1;
    }

    final activeState = _selectedCondition ?? ConditionState.values.first;
    final activeCount = counts[activeState] ?? 0;
    final pct = (activeCount / entries.length * 100).toInt();

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: kPanelBg.withAlpha(150),
        borderRadius: BorderRadius.circular(kRadiusLarge),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 140.w,
                height: 140.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(140.w, 140.w),
                      painter: _OrbitalIntegrityPainter(
                        counts: counts,
                        total: entries.length,
                        selected: _selectedCondition,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$pct%',
                          style: GoogleFonts.dmSans(
                            color: kPrimaryText,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'INTEGRITY',
                          style: GoogleFonts.jetBrainsMono(
                            color: kSecondaryText,
                            fontSize: 8.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ConditionState.values.map((s) {
                    final isSelected = _selectedCondition == s;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCondition = s),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? getConditionColor(s).withAlpha(30)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(kRadiusSubtle),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  color: getConditionColor(s),
                                  shape: BoxShape.circle,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: getConditionColor(s),
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  s.label,
                                  style: GoogleFonts.inter(
                                    color: isSelected
                                        ? kPrimaryText
                                        : kSecondaryText,
                                    fontSize: 12.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEraScrubber(List<ArchiveItemModel> entries) {
    final Map<int, List<ArchiveItemModel>> decadeMap = {};
    for (var e in entries) {
      final year = _parseYear(e.eraOfProduction);
      if (year != null) {
        final dec = (year ~/ 10) * 10;
        decadeMap.putIfAbsent(dec, () => []).add(e);
      }
    }

    if (decadeMap.isEmpty) return _emptyModule('No chronological data found.');

    final sortedDecades = decadeMap.keys.toList()..sort();
    _selectedDecade ??= sortedDecades.first;

    return Column(
      children: [
        SizedBox(
          height: 60.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: sortedDecades.length,
            itemBuilder: (context, index) {
              final dec = sortedDecades[index];
              final isSelected = _selectedDecade == dec;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDecade = dec);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? kAccent.withAlpha(40)
                        : kPanelBg.withAlpha(100),
                    borderRadius: BorderRadius.circular(kRadiusPill),
                    border: Border.all(
                      color: isSelected ? kAccent : kOutline,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${dec}s',
                    style: GoogleFonts.dmSans(
                      color: isSelected ? kAccent : kSecondaryText,
                      fontSize: 14.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20.h),
        // Maker Spotlight for selected era
        if (_selectedDecade != null)
          _buildMakerSpotlight(decadeMap[_selectedDecade!]!),
      ],
    );
  }

  Widget _buildMakerSpotlight(List<ArchiveItemModel> eraEntries) {
    final counts = <String, int>{};
    for (var e in eraEntries) {
      if (e.manufacturerAndShopMark.isNotEmpty) {
        counts[e.manufacturerAndShopMark] =
            (counts[e.manufacturerAndShopMark] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return const SizedBox();

    final topMaker = counts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: kPanelBg.withAlpha(150),
        borderRadius: BorderRadius.circular(kRadiusLarge),
        border: Border.all(color: kOutline),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: const BoxDecoration(
              color: kBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: kAccent,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ERA DOMINANCE',
                  style: GoogleFonts.jetBrainsMono(
                    color: kSecondaryText,
                    fontSize: 8.sp,
                  ),
                ),
                Text(
                  topMaker,
                  style: GoogleFonts.dmSans(
                    color: kPrimaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureStack(List<ArchiveItemModel> entries) {
    final counts = <String, int>{};
    for (var e in entries) {
      if (e.manufacturerAndShopMark.isNotEmpty) {
        counts[e.manufacturerAndShopMark] =
            (counts[e.manufacturerAndShopMark] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return _emptyModule('No manufacturer data found.');

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.first.value;

    return Column(
      children: sorted.take(5).map((e) {
        final factor = e.value / max;
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: kPanelBg.withAlpha(150),
              borderRadius: BorderRadius.circular(kRadiusLarge),
              border: Border.all(color: kOutline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: GoogleFonts.dmSans(
                        color: kPrimaryText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${e.value} Specimens',
                      style: GoogleFonts.jetBrainsMono(
                        color: kAccent,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Stack(
                  children: [
                    Container(
                      height: 4.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: kBackground,
                        borderRadius: BorderRadius.circular(kRadiusPill),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      height: 4.h,
                      width: (ScreenUtil().screenWidth - 72.w) * factor,
                      decoration: BoxDecoration(
                        color: kAccent,
                        borderRadius: BorderRadius.circular(kRadiusPill),
                        boxShadow: [kShadowCyan],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 2.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: kSecondaryText,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Container(width: 40.w, height: 1, color: kOutline),
      ],
    );
  }

  Widget _emptyModule(String msg) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: kPanelBg.withAlpha(50),
        borderRadius: BorderRadius.circular(kRadiusLarge),
        border: Border.all(color: kOutline, style: BorderStyle.solid),
      ),
      child: Center(
        child: Text(
          msg.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            color: kSecondaryText.withAlpha(120),
            fontSize: 10.sp,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.query_stats_outlined, color: kOutline, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            'NO ARCHIVE DATA',
            style: GoogleFonts.jetBrainsMono(
              color: kSecondaryText,
              fontSize: 12.sp,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataMeshPainter extends CustomPainter {
  final double animationValue;
  _DataMeshPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Deep tech background
    final x = math.sin(animationValue * 2 * math.pi) * 0.15;
    final y = math.cos(animationValue * 2 * math.pi) * 0.1;

    final gradient = RadialGradient(
      center: Alignment(0.4 + x, -0.2 + y),
      radius: 1.8,
      colors: [kAccent.withAlpha(25), kBackground],
      stops: const [0.0, 1.0],
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Subtle data grid lines
    final gridPaint = Paint()
      ..color = kOutline.withAlpha(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        gridPaint,
      );
    }
    for (var i = 0; i < size.height; i += 40) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DataMeshPainter oldDelegate) => true;
}

class _OrbitalIntegrityPainter extends CustomPainter {
  final Map<ConditionState, int> counts;
  final int total;
  final ConditionState? selected;

  _OrbitalIntegrityPainter({
    required this.counts,
    required this.total,
    this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    double startAngle = -math.pi / 2;

    for (var state in ConditionState.values) {
      if (!counts.containsKey(state)) continue;
      final sweepAngle = (counts[state]! / total) * 2 * math.pi;
      final isSelected = selected == state;

      final paint = Paint()
        ..color = getConditionColor(state).withAlpha(isSelected ? 255 : 100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 12 : 8
        ..strokeCap = StrokeCap.round;

      if (isSelected) {
        final glowPaint = Paint()
          ..color = getConditionColor(state).withAlpha(50)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - 10),
          startAngle + 0.1,
          sweepAngle - 0.2,
          false,
          glowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        startAngle + 0.1,
        sweepAngle - 0.2,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Static decorative inner ring
    final innerPaint = Paint()
      ..color = kOutline.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 25, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
